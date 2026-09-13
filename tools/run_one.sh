#!/usr/bin/env bash
# Run ONE run_site job in its own Octave process. Called by run_batch.sh.
# Usage: tools/run_one.sh "<drv> <basalt> <start> <tf> <exp>" <tag>
#
# OCTAVE_BIN / OCTAVE_FLAGS are overridable because the container used by
# tools/coiled/ ships octave-cli and no display, where --no-gui does not apply.
set -u
cd "$(dirname "$0")/.."
read -r drv basalt start tf exp <<< "$1"
TAG="${2:-batch}"
OCTAVE_BIN="${OCTAVE_BIN:-octave}"
OCTAVE_FLAGS="${OCTAVE_FLAGS:---no-gui --quiet}"
out="results/${exp}_drv${drv}_${basalt}_${tf}yr.mat"
log="logs/${TAG}_drv${drv}_${basalt}_${exp}.log"
if [ -f "$out" ]; then echo "skip (exists): $out"; exit 0; fi
echo "$(date +%H:%M:%S) START drv=$drv $basalt $exp ${tf}yr from $start"
$OCTAVE_BIN $OCTAVE_FLAGS --eval "
  warning('off','all'); addpath('src');
  run_site($drv, '$basalt', 'experiment','$exp', 'tf',$tf, 'start_year',$start, 'save_to','$out');
" > "$log" 2>&1
rc=$?
if [ $rc -eq 0 ] && [ -f "$out" ]; then
  echo "$(date +%H:%M:%S) DONE  drv=$drv $basalt $exp -- $(grep -o 'done in .*' "$log" | tail -1)"
else
  echo "$(date +%H:%M:%S) FAIL  drv=$drv $basalt $exp (rc=$rc) -- see $log"
fi
