#!/usr/bin/env bash
# Run a list of run_site jobs, optionally several at a time.
#
# Usage:  tools/run_batch.sh <jobs-file> [tag] [nproc]
#   jobs-file: one "drv basalt start_year tf experiment" per line, # for comments
#   nproc:     concurrent Octave processes (default 1)
#
# One OS process per job, never threads: Octave has no parfor without the
# parallel package, and separate processes mean a crash or a kill loses only the
# job in flight. Every finished job is already on disk in results/, and run_one.sh
# skips anything that exists, so re-running the batch resumes rather than repeats.
#
# Memory is the binding constraint, not cores. A 5-yr run peaks near 0.5 GB and
# fd15 accumulates state per iteration, so cost scales with run LENGTH. Check
# actual RSS before going wide:  ps -o rss=,command= -p $(pgrep -d, -f octave)
set -u
cd "$(dirname "$0")/.."
JOBS="$1"; TAG="${2:-batch}"; NPROC="${3:-1}"
mkdir -p logs results
MAIN="logs/${TAG}.log"
{ echo "=== $TAG started $(date), nproc=$NPROC ==="; } >> "$MAIN"
grep -vE '^\s*(#|$)' "$JOBS" \
  | xargs -P "$NPROC" -I{} "$(pwd)/tools/run_one.sh" "{}" "$TAG" \
  >> "$MAIN" 2>&1
echo "=== $TAG finished $(date) ===" >> "$MAIN"
