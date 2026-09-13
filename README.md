# beerling-2025-model-extension

Re-running the per-cell weathering model from **Beerling et al. (2025)**, 
Nature ([doi:10.1038/s41586-024-08429-2](https://doi.org/10.1038/s41586-024-08429-2)),
to test whether its empirical soil-pH buffer breaks carbonate speciation — and
by how much that changes the published CDR.


## Our main constraint

We used Claude (Opus 4.8) to help us rewrite the 
model for Octave (open source Matlab alternative) and identify other necessary changes. 
We wanted to make sure Claude's changes are easy to detect and scrutinize. The `upstream/` 
directory is the original paper's Zenodo deposit of the model, and we do not edit it. 
Everything we write is in `src/`. Files that we had to change have their updated version 
in `src/shim/` under the same name as they are in `upstream/`. This way, the changes are 
easily found with diff. For example:

```bash
diff upstream/weathering_model/particle_weathering_300123/solution2pH.m src/shim/solution2pH.m
```


## Getting started

| | |
|---|---|
| **[notes.md](notes.md)** | Every addition and change to the code, why it was needed, and what it does or does not affect. |
| **[how-to-run.md](how-to-run.md)** | Exact steps to reproduce a run. |

## Experiments

| | pH relation | Calcite ceiling | Purpose |
|---|---|---|---|
| **E0** | buffered | buffered | The published configuration — validates the harness |
| **E1** | buffered | thermodynamic | Calcite ceiling only; pH and kinetics identical to E0 |
| **E2** | thermodynamic | thermodynamic | Full carbonate closure |

## Status

The model **runs end-to-end under Octave 11.3**, and **E0 reproduces the
published model**.

## Provenance

- Model code — Zenodo [10940280](https://doi.org/10.5281/zenodo.10940280), vendored in `upstream/`
- Published outputs — Zenodo [14755423](https://doi.org/10.5281/zenodo.14755423), not vendored
- Data Files S1–S6 — Nature SI, not vendored

Large binaries in `upstream/` are git-ignored; `upstream/MANIFEST.sha256` keeps
them verifiable and [how-to-run.md](how-to-run.md) says how to restore them.
