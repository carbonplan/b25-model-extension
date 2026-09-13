#!/usr/bin/env bash
# What one Coiled VM does. Staged and launched by tools/coiled/submit.py, which has
# already downloaded and unpacked the code tarball into /work and put s5cmd on PATH.
#
# This is how-to-run.md §2 and §5.2 with the manual steps automated: restore the
# large upstream files, verify them against MANIFEST.sha256, then run the jobs with
# one Octave process each.
#
# Env (job-level, set by submit.py): UPSTREAM_S3 DRIVER_S3 RESULTS_S3 LOGS_S3
#                                    RUN_TAG NPROC
# Env (per-task):                    JOBS  -- ';'-separated run_one.sh job lines
set -euo pipefail
cd "$(dirname "$0")/../.."   # /work, the repo root

: "${JOBS:?no JOBS set for this task}"
TAG="${RUN_TAG:-coiled}"
NPROC="${NPROC:-1}"

echo "=== task $(hostname) $(date -u +%FT%TZ)"
echo "    $(nproc 2>/dev/null || echo '?') cpu, $(free -g 2>/dev/null | awk '/^Mem:/{print $2}') GB, ${NPROC} concurrent runs"

# Fail in the first ten seconds rather than after two hours of solver time: if the
# instance profile cannot write to the results bucket, every finished run would be
# thrown away at the end.
date -u +%FT%TZ > /tmp/.probe
if ! s5cmd cp /tmp/.probe "${LOGS_S3%/}/_probe_${COILED_BATCH_TASK_ID:-0}.txt" >/dev/null; then
  echo "FATAL: cannot write to ${LOGS_S3%/}/ — check the Coiled instance profile's S3 permissions" >&2
  exit 2
fi

# --- Octave -----------------------------------------------------------------------
# The container ships octave-cli as its CMD; --no-gui is an octave(1) flag and there
# is no display here, so run_one.sh's defaults are overridden rather than assumed.
# One BLAS thread per process, deliberately. This image builds Octave against
# OpenBLAS, which by default opens a thread per core — but the work here is a tight
# interpreted loop in fd15.m over small matrices, so extra threads buy nothing, and
# NPROC runs each claiming every core oversubscribes the box into spin-waiting
# (which shows up as system CPU time, not throughput). The local runs are one core
# per process; this makes the container match.
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1

if command -v octave-cli >/dev/null 2>&1; then
  export OCTAVE_BIN=octave-cli
  export OCTAVE_FLAGS="--quiet"
else
  export OCTAVE_BIN=octave
  export OCTAVE_FLAGS="--no-gui --quiet"
fi
echo "    $($OCTAVE_BIN --version | head -1)  [$OCTAVE_BIN $OCTAVE_FLAGS]"

# --- stage inputs -----------------------------------------------------------------
mkdir -p results logs
s5cmd cp "$UPSTREAM_S3" /work/upstream.tar.gz
tar xzf /work/upstream.tar.gz
s5cmd cp "$DRIVER_S3" upstream/weathering_model/run_strc_6.mat

# Not ceremony: this is the check that catches the wrong run_strc_6.mat, of which the
# deposit contains two with the same name and only one reproducing the published
# outputs (notes.md D6). --ignore-missing because the three unused big binaries are
# in the manifest but deliberately not staged.
echo "--- verifying against MANIFEST.sha256"
( cd upstream/weathering_model && sha256sum -c --ignore-missing --quiet ../MANIFEST.sha256 )
echo "    ok"

# --- resume -----------------------------------------------------------------------
# submit.py drops finished jobs at submit time, but a Coiled RETRY re-runs this task
# verbatim on a fresh VM, where results/ is empty again. Without this, one failed job
# in a chunk would drag its finished siblings through another hour of solver time on
# every retry. Pulling the .mat back down is enough: run_one.sh skips what exists.
echo "$JOBS" | tr ';' '\n' | sed '/^[[:space:]]*$/d' | while read -r drv basalt start tf exp; do
  name="${exp}_drv${drv}_${basalt}_${tf}yr.mat"
  if s5cmd cp "${RESULTS_S3%/}/${name}" "results/${name}" >/dev/null 2>&1; then
    echo "    resumed from S3: $name"
  fi
done

# --- run --------------------------------------------------------------------------
# One OS process per job (Octave has no parfor without the parallel package), and each
# result is pushed the moment it exists rather than at the end of the task: a spot
# preemption then costs only the job in flight, and re-submitting skips the rest.
# Nothing about a run is visible from outside until it finishes: run_one.sh redirects
# Octave to logs/, and `coiled batch logs` shows nothing for a task in flight. So push
# the in-flight logs every two minutes. A few KB, and it is the only window into a job
# that will not produce its .mat for another hour.
( while sleep 120; do s5cmd cp 'logs/*' "${LOGS_S3%/}/" >/dev/null 2>&1 || true; done ) &
heartbeat=$!
trap 'kill "$heartbeat" 2>/dev/null || true' EXIT

run_job() {
  set -u
  local line="$1"
  read -r drv basalt start tf exp <<< "$line"
  # These two names mirror tools/run_one.sh. If they change there, change them here.
  local out="results/${exp}_drv${drv}_${basalt}_${tf}yr.mat"
  local log="logs/${TAG}_drv${drv}_${basalt}_${exp}.log"

  local rc=0
  tools/run_one.sh "$line" "$TAG" || rc=$?

  [ -f "$out" ] && s5cmd cp "$out" "${RESULTS_S3%/}/" >/dev/null
  [ -f "$log" ] && s5cmd cp "$log" "${LOGS_S3%/}/" >/dev/null
  if [ "$rc" -ne 0 ] || [ ! -f "$out" ]; then
    echo "FAIL $line (rc=$rc)"
    return 1
  fi
  return 0
}
export -f run_job
export TAG RESULTS_S3 LOGS_S3 OCTAVE_BIN OCTAVE_FLAGS

# `|| rc=$?` because xargs returns 123 when any job failed, and set -e would
# otherwise abandon the task before it reported which ones.
rc=0
echo "$JOBS" | tr ';' '\n' | sed '/^[[:space:]]*$/d' \
  | xargs -P "$NPROC" -I{} bash -c 'run_job "$@"' _ {} || rc=$?

echo "=== task done rc=$rc $(date -u +%FT%TZ)"
exit $rc
