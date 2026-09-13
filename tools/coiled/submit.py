#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["coiled", "boto3"]
# ///
"""
Submit run_site jobs to Coiled Batch, N simulations per VM.

    uv run tools/coiled/submit.py tools/jobs_e0_sites.txt --tag e0 --jobs-per-vm 4

Each task on each VM does exactly what how-to-run.md says to do by hand — it just
does it in a container that already has Octave 11.3.0 rather than installing it:

    stage the code + upstream/ + run_strc_6.mat  ->  verify against MANIFEST.sha256
    ->  tools/run_one.sh per job  ->  push each .mat to S3 as soon as it lands

WHAT GOES WHERE, AND WHY

The VM needs 121 MB of inputs, which arrive from three places for three reasons:

  code      src/ + tools/, ~100 KB   uploaded on every submit — it changes constantly
  upstream  upstream/ minus the big  uploaded once, keyed by the sha of MANIFEST.sha256,
            git-ignored binaries,    so a submit that changes no upstream file re-uses it
            38 MB
  drivers   run_strc_6.mat, 83 MB    NOT uploaded — the Zenodo deposit is already staged
                                     at ew-workflows-data/beerling-2025-data/

The manifest check on the VM is not ceremony. It is the same command how-to-run.md
§2 tells a human to run, and it is what stops the D6 trap (two different files named
run_strc_6.mat, only one of which reproduces the published outputs) from ever
reaching the solver.

RESULTS come back through S3, one object per job, uploaded the moment that job
finishes rather than when the task finishes. A spot preemption at hour two of a
three-job chunk therefore costs the job in flight and nothing else: re-submitting
the same jobs file skips every result already in S3.

Fetch them with:

    aws s3 sync s3://<prefix>/results/<tag>/ results/
"""

import argparse
import gzip
import hashlib
import io
import os
import sys
import tarfile
import time
from pathlib import Path

import boto3
import coiled

REPO = Path(__file__).resolve().parents[2]

# Container: the ONLY published Octave that matches what the results so far were
# produced with (11.3.0). amd64 only, so arm=False and an x86 vm_type.
DEFAULT_CONTAINER = "docker.io/gnuoctave/octave:11.3.0"

DEFAULT_PREFIX = (
    "s3://carbonplan-carbon-removal/ew-workflows-data/beerling-2025-model-extension"
)
DEFAULT_DRIVER = (
    "s3://carbonplan-carbon-removal/ew-workflows-data/beerling-2025-data"
    "/weathering_model/run_strc_6.mat"
)
S5CMD_URL = "https://github.com/peak/s5cmd/releases/download/v2.3.0/s5cmd_2.3.0_Linux-64bit.tar.gz"

# 4 vCPU / 16 GiB, Zen 4. Measured on the smoke pair: Zen 4 (c7a) runs this model
# 1.45x faster than the Milan-generation m6a, and m7a is the same silicon at
# 4 GiB/core instead of c7a's 2 GiB/core. That ratio is what decides it — runs peak
# near 2 GB at 45 simulated years, so on c7a a fourth job would not fit in memory
# and a core would sit idle, giving back the speed. See README.md.
DEFAULT_VM_TYPE = "m7a.xlarge"

MAX_TASKS_PER_JOB = 300  # Coiled submission chunk, not a science quantity


# ----------------------------------------------------------------------------- jobs


def read_jobs(path):
    """Parse a jobs file: 'drv basalt start_year tf experiment' per line."""
    jobs = []
    for lineno, raw in enumerate(Path(path).read_text().splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        if len(parts) != 5:
            raise SystemExit(f"{path}:{lineno}: expected 5 fields, got {len(parts)}: {raw}")
        drv, basalt, start, tf, exp = parts
        jobs.append(
            {
                "line": " ".join(parts),
                "drv": int(drv),
                "basalt": basalt,
                "start": int(start),
                "tf": int(tf),
                "exp": exp,
                # Must match tools/run_one.sh, which builds the same name on the VM.
                "result": f"{exp}_drv{drv}_{basalt}_{tf}yr.mat",
            }
        )
    return jobs


def pack_chunks(jobs, per_vm):
    """Group jobs of similar length onto the same VM.

    Note what a chunk IS here: every job in it starts at once, because the task
    runs `xargs -P jobs_per_vm` over exactly jobs_per_vm jobs. Nothing queues. So a
    VM's wall time is its LONGEST job, not the sum, and the whole batch finishes
    with the longest job in it no matter how the chunks are arranged.

    What arrangement does change is wasted core-time. A VM billed until its 45-year
    job finishes, whose other three cores went idle after an hour, is paid for in
    full. Sorting by length and cutting consecutively puts the long jobs together,
    so cores on a given VM free up at roughly the same time and it shuts down.

    (This is the opposite of the balance-the-totals rule in jobs_e0_sites.txt, and
    for a good reason: that file is written for `run_batch.sh`, where nproc is less
    than the job count and lines genuinely queue behind each other.)
    """
    ordered = sorted(jobs, key=lambda j: -j["tf"])
    return [ordered[i : i + per_vm] for i in range(0, len(ordered), per_vm)]


# ------------------------------------------------------------------------------- s3


def split_s3(uri):
    if not uri.startswith("s3://"):
        raise SystemExit(f"expected an s3:// URI, got {uri}")
    bucket, _, key = uri[5:].partition("/")
    return bucket, key


def deterministic_tar_gz(members):
    """Tar the given (arcname, path) pairs reproducibly.

    Same inputs must give the same bytes, or the content hash in the object key
    changes on every submit and nothing is ever re-used. So: sorted order, no
    mtimes, no uid/gid/uname, and gzip's own mtime header zeroed.
    """
    raw = io.BytesIO()
    with tarfile.open(fileobj=raw, mode="w") as tar:
        for arcname, path in sorted(members):
            info = tar.gettarinfo(str(path), arcname=arcname)
            info.mtime = 0
            info.uid = info.gid = 0
            info.uname = info.gname = ""
            if info.isreg():
                with open(path, "rb") as fh:
                    tar.addfile(info, fh)
            else:
                tar.addfile(info)
    out = io.BytesIO()
    with gzip.GzipFile(fileobj=out, mode="wb", mtime=0) as gz:
        gz.write(raw.getvalue())
    return out.getvalue()


def collect(root, skip=()):
    """Every regular file under root, as (arcname relative to REPO, path)."""
    members = []
    skip = {Path(s).resolve() for s in skip}
    for path in sorted(Path(root).rglob("*")):
        if not path.is_file() or path.is_symlink():
            continue
        if path.resolve() in skip or path.name == ".DS_Store":
            continue
        if "__pycache__" in path.parts:
            continue
        members.append((str(path.relative_to(REPO)), path))
    return members


def upload_if_absent(s3, uri, body, label, force=False):
    bucket, key = split_s3(uri)
    if not force:
        try:
            s3.head_object(Bucket=bucket, Key=key)
            print(f"  {label}: re-using {uri} ({len(body) / 1e6:.1f} MB)")
            return uri
        except s3.exceptions.ClientError:
            pass
    print(f"  {label}: uploading {len(body) / 1e6:.1f} MB -> {uri}")
    s3.put_object(Bucket=bucket, Key=key, Body=body)
    return uri


def build_payloads(s3, prefix, force=False):
    """Upload the code and upstream tarballs; return their s3:// URIs."""
    code = collect(REPO / "src") + collect(REPO / "tools")
    code_tar = deterministic_tar_gz(code)
    code_sha = hashlib.sha256(code_tar).hexdigest()[:12]

    # upstream/ is never edited (the one rule in README.md) and MANIFEST.sha256 is a
    # hash of every file in it, so hashing the manifest identifies the tree without
    # re-reading 38 MB on every submit.
    manifest = REPO / "upstream" / "MANIFEST.sha256"
    if not manifest.exists():
        raise SystemExit(f"missing {manifest} — the VM has nothing to verify against")
    up_sha = hashlib.sha256(manifest.read_bytes()).hexdigest()[:12]

    code_uri = f"{prefix}/payload/code-{code_sha}.tar.gz"
    up_uri = f"{prefix}/payload/upstream-{up_sha}.tar.gz"

    upload_if_absent(s3, code_uri, code_tar, "code", force=force)

    bucket, key = split_s3(up_uri)
    exists = True
    try:
        s3.head_object(Bucket=bucket, Key=key)
    except s3.exceptions.ClientError:
        exists = False
    if exists and not force:
        print(f"  upstream: re-using {up_uri}")
    else:
        # The four big binaries are git-ignored and are not in the tarball: one is
        # staged separately (--driver-s3), the other three are unused. See
        # how-to-run.md §2.
        big = [
            REPO / "upstream/weathering_model/run_strc_6.mat",
            REPO / "upstream/weathering_model/particle_weathering_data/driving_data_structure/run_strc_6.mat",
            REPO / "upstream/weathering_model/particle_weathering_300123/Ceqs/Ceq_table_Kfeldspar.mat",
            REPO / "upstream/weathering_model/particle_weathering_300123/Ceqs/Copy_of_Ceq_table_Blue_Ridge.mat",
        ]
        up_tar = deterministic_tar_gz(collect(REPO / "upstream", skip=big))
        upload_if_absent(s3, up_uri, up_tar, "upstream", force=True)

    return code_uri, up_uri


def existing_results(s3, results_prefix):
    bucket, key = split_s3(results_prefix)
    key = key.rstrip("/") + "/"
    found = set()
    token = None
    while True:
        kw = {"Bucket": bucket, "Prefix": key}
        if token:
            kw["ContinuationToken"] = token
        resp = s3.list_objects_v2(**kw)
        for obj in resp.get("Contents", []):
            found.add(obj["Key"].rsplit("/", 1)[-1])
        if not resp.get("IsTruncated"):
            return found
        token = resp["NextContinuationToken"]


# --------------------------------------------------------------------------- submit

BOOTSTRAP = """
set -euo pipefail
command -v curl >/dev/null 2>&1 || { apt-get update -qq && apt-get install -y -qq curl ca-certificates; }
curl -sSfL "$S5CMD_URL" | tar xz -C /usr/local/bin s5cmd
mkdir -p /work && cd /work
s5cmd cp "$CODE_S3" /work/code.tar.gz
tar xzf /work/code.tar.gz
exec bash tools/coiled/task.sh
"""


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("jobs_file", help="one 'drv basalt start_year tf experiment' per line")
    p.add_argument("--tag", default=None, help="names the results/ and logs/ prefix (default: jobs file stem)")
    p.add_argument("--jobs-per-vm", type=int, default=4, help="simulations run concurrently on one VM (default 4, = vCPUs on m7a.xlarge)")
    p.add_argument("--vm-type", default=DEFAULT_VM_TYPE)
    p.add_argument("--container", default=DEFAULT_CONTAINER)
    p.add_argument("--prefix", default=DEFAULT_PREFIX, help="s3:// root for payload, results and logs")
    p.add_argument("--driver-s3", default=DEFAULT_DRIVER, help="s3:// URI of the 437-cluster run_strc_6.mat")
    p.add_argument("--region", default="us-west-2")
    p.add_argument("--spot-policy", default="spot_with_fallback", choices=["spot", "spot_with_fallback", "on-demand"])
    p.add_argument("--max-retries", type=int, default=2, help="Coiled retries per task (spot preemption)")
    p.add_argument("--job-timeout", default="12 hours")
    p.add_argument("--force", action="store_true", help="re-upload payloads and re-run jobs whose result exists")
    p.add_argument("--dry-run", action="store_true", help="print the plan; upload nothing, submit nothing")
    args = p.parse_args()

    tag = args.tag or Path(args.jobs_file).stem
    prefix = args.prefix.rstrip("/")
    results_s3 = f"{prefix}/results/{tag}"
    logs_s3 = f"{prefix}/logs/{tag}"

    jobs = read_jobs(args.jobs_file)
    print(f"{len(jobs)} jobs in {args.jobs_file}, {sum(j['tf'] for j in jobs)} simulated years total")

    s3 = boto3.client("s3", region_name=args.region)

    if not args.force:
        done = existing_results(s3, results_s3)
        skipped = [j for j in jobs if j["result"] in done]
        jobs = [j for j in jobs if j["result"] not in done]
        if skipped:
            print(f"  skipping {len(skipped)} already in {results_s3}/")
    if not jobs:
        print("nothing to do")
        return

    chunks = pack_chunks(jobs, args.jobs_per_vm)
    print(f"  -> {len(chunks)} tasks / VMs, {args.jobs_per_vm} concurrent runs each")
    for i, chunk in enumerate(chunks):
        print(f"     task {i}: {sum(j['tf'] for j in chunk):>3} yr  " + " | ".join(j["line"] for j in chunk))

    if args.dry_run:
        print("\n--dry-run: uploaded nothing, submitted nothing")
        return

    print("payload:")
    code_s3, upstream_s3 = build_payloads(s3, prefix, force=args.force)

    job_env = {
        "S5CMD_URL": S5CMD_URL,
        "CODE_S3": code_s3,
        "UPSTREAM_S3": upstream_s3,
        "DRIVER_S3": args.driver_s3,
        "RESULTS_S3": results_s3,
        "LOGS_S3": logs_s3,
        "RUN_TAG": tag,
        "NPROC": str(args.jobs_per_vm),
        "AWS_REGION": args.region,
        "AWS_DEFAULT_REGION": args.region,
    }
    task_dicts = [{"JOBS": ";".join(j["line"] for j in chunk)} for chunk in chunks]

    submitted = []
    for i in range(0, len(task_dicts), MAX_TASKS_PER_JOB):
        batch = task_dicts[i : i + MAX_TASKS_PER_JOB]
        res = coiled.batch.run(
            command=["bash", "-c", BOOTSTRAP],
            map_over_task_var_dicts=batch,
            name=f"beerling-{tag}-{i // MAX_TASKS_PER_JOB}"[:60],
            container=args.container,
            ignore_container_entrypoint=True,
            vm_type=args.vm_type,
            scheduler_vm_type=args.vm_type,
            arm=False,  # gnuoctave/octave publishes amd64 only
            region=args.region,
            spot_policy=args.spot_policy,
            max_retries=args.max_retries,
            job_timeout=args.job_timeout,
            allow_cross_zone=True,
            forward_aws_credentials=False,  # workers use the Coiled instance profile
            env=job_env,
            tag={"Project": "beerling-2025-model-extension"},
        )
        print("submitted:", res)
        submitted.append(res)
        time.sleep(1)

    print()
    print("watch:   coiled batch status")
    print(f"logs:    aws s3 sync {logs_s3}/ logs/{tag}/")
    print(f"results: aws s3 sync {results_s3}/ results/")


if __name__ == "__main__":
    main()
