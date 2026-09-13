# tools/coiled — running the model on Coiled Batch

The same runs as [`tools/run_batch.sh`](../run_batch.sh), on one VM per few jobs
instead of one laptop. Nothing about the model changes: each VM ends up executing
`tools/run_one.sh`, the same script, against the same `upstream/` and the same
`run_strc_6.mat`.

---

## Octave container
Octave 11.3.0 is published as a container image, `gnuoctave/octave:11.3.0`. This
lets the coiled VM skips the install Octave step, as we prescribe the container
instead. Note, the octave image is amd64-only (`arm=False`).


## VM workflow

```
container gnuoctave/octave:11.3.0
  install s5cmd                             (curl, ~10 MB)
  s5cmd cp  code-<sha>.tar.gz               src/ + tools/, ~100 KB
  s5cmd cp  upstream-<sha>.tar.gz           upstream/ minus the big binaries, 38 MB
  s5cmd cp  run_strc_6.mat                  83 MB, already staged on S3
  sha256sum -c MANIFEST.sha256              how-to-run.md §2, automated
  xargs -P N  tools/run_one.sh              N Octave processes, one per job
      -> each .mat pushed to S3 the moment it lands
```


## First run

```bash
# 1. see the plan; uploads nothing, submits nothing
uv run tools/coiled/submit.py tools/coiled/jobs_smoke.txt --dry-run

# 2. the smoke test: the cluster-6 Virginia pair
uv run tools/coiled/submit.py tools/coiled/jobs_smoke.txt --jobs-per-vm 2
coiled batch status
```


## Batch run

```bash
uv run tools/coiled/submit.py tools/jobs_e0_sites.txt --tag e0 --jobs-per-vm 3
```

Re-submitting the same jobs file is the resume: `submit.py` lists
`results/<tag>/` on S3 first and drops every job already finished. Combined with
per-job upload, a spot preemption at hour two of a three-job chunk loses only the
job in flight.

## Sizing

Runs are single-core and peak near 2 GB at 45 simulated years. The default
`m6a.xlarge` is 4 vCPU / 16 GiB, so `--jobs-per-vm 3` leaves headroom. 
