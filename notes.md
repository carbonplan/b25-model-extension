# notes.md — Changes + additions and justifications

This repo re-runs the per-cell weathering model from **Beerling et al. (2025)**,
Nature, [doi:10.1038/s41586-024-08429-2](https://doi.org/10.1038/s41586-024-08429-2).

The repo tweaks the model in two ways. First, it updates it to run with Octave, 
an open-source alternative to Matlab. Second, it outputs more data than the original 
code to facilitate certain analyses.

A primary goal of the repo is to test the model against carbonate closure. 
Some of our preliminary analysis suggests that it may not close the carbonate system, 
but it relied on assumptions about the model state. This repo lets us repeat the analysis on direct model outputs. 

**A note on changes to the model:** We used Claude (Opus 4.8) to help us rewrite the 
model for Octave and identify other necessary changes. We wanted to make sure Claude's
changes are easy to detect and scrutinize. The `upstream/` directory is the original paper's
Zenodo deposit of the model, and we do not edit it. Everything we write is in `src/`. Files 
that we had to change have their updated version in `src/shim/` under the same name as they 
are in `upstream/`. This way, the changes are easily found with diff. For example:

```
diff upstream/weathering_model/particle_weathering_300123/solution2pH.m src/shim/solution2pH.m
```

This notebook also outlines the changes we made, provides justification, and discuss whether
the change affect the geochemistry or not. 

---

## Contents

- [Provenance](#provenance)
- [Layout](#layout)
- [Overriding the source code selectively](#overriding-the-source-code-selectively)
- [A. Files that are missing from the deposit](#a-files-that-are-missing-from-the-deposit)
- [B. Files we had to override](#b-files-we-had-to-override)
- [C. Files we added that have no upstream counterpart](#c-files-we-added-that-have-no-upstream-counterpart)
- [D. Minor upstream bugs and traps we found but did NOT change](#d-minor-upstream-bugs-and-traps-we-found-but-did-not-change)
- [E. Facts about the released data that the plan depends on](#e-facts-about-the-released-data-that-the-plan-depends-on)
- [F. The experiments](#f-the-experiments)
- [Status of the code](#status-of-the-code)

---

## Provenance

| What | Source | Where it lives here |
|------|--------|---------------------|
| Weathering model (MATLAB) | Zenodo 10940280 | `upstream/weathering_model/` |
| Published per-cell outputs | Zenodo 14755423 | *not in this repo* |
| Data Files S1–S6 | Nature SI, `41586_2024_8429_MOESM<2–7>_ESM` | *not in this repo* |

Note that large binaries in `upstream/` are git-ignored (see `.gitignore`);
but `how-to-run.md` says how to restore them.

---

## Layout
```
upstream/weathering_model/     untouched Zenodo deposit — never edit
src/
  setup_paths.m                path + staging setup (ours)
  run_site.m                   driver, replaces upstream run_1_v5.m (ours)
  shim/                        overrides and missing functions
    mod5.m                     OVERRIDE of upstream/weathering_model/mod5.m
    fd15.m                     OVERRIDE (records the effective q(t))
    run_simple4.m              OVERRIDE (surfaces carbonate state, q, per-mineral B/C)
    solution2pH.m              OVERRIDE
    solution2CaSat.m           OVERRIDE
    mk_interp2d.m              ADDED
    PSD_*.m, make_particles.m  ADDED — stubs for functions absent upstream
    octave/
      contains.m               ADDED — Octave only, never on MATLAB's path
data/
  mineralogy_cluster_counts.csv  ADDED — hand-transcribed from Extended Data Fig. 3a
work/                          generated staging dir; safe to delete
results/                       run outputs (.mat)
tools/                         Python helpers for comparing against published data
logs/                          per-job run logs
```

`data/` is for values we transcribed ourselves. It is deliberately separate from
`upstream/` (byte-identical deposit) and `src/` (code) because everything in it is a
judgement call by us about what a published figure says, and has to be checkable
as such.

---

## Overriding the source code selectively

`src/setup_paths.m` builds the search path so that **`src/shim/` outranks
`upstream/`**. A file of the same name in `src/shim/` therefore replaces the
upstream one, and `diff` between the two shows exactly what we changed.


---

## A. Files that are missing from the deposit

Five functions and one data directory are referenced by `fd15.m` but are not in
Zenodo 10940280. We did not find a `PSD/` directory in the deposit.

| Missing | Called from | Our file | Reached in our runs? |
|---|---|---|---|
| `PSD_get` | `fd15.m:15` | `src/shim/PSD_get.m` | yes — stubbed |
| `PSD_make_basalt` | `fd15.m:31` | `src/shim/PSD_make_basalt.m` | yes — stubbed |
| `PSD_weather_discrete_basalt` | `fd15.m:281` | `src/shim/PSD_weather_discrete_basalt.m` | yes — stubbed |
| `PSD_transport_basalt` | `fd15.m:283` | `src/shim/PSD_transport_basalt.m` | no — **refuses** |
| `make_particles` | `fd15.m:24` | `src/shim/make_particles.m` | no — **refuses** |

### Why stubbing the first three is sound

The paper runs `run_params.model_P_or_C = 'C'`. In that
branch the PSD return values are computed but then discarded. 
For example, in `fd15.m`:

```
281  [PB_new,MW,SA,MB] = PSD_weather_discrete_basalt(PB,Delt,wP,z);
285  SAP = SA.*params.mf/delZ;        <- SA used only to build SAP
289  Mp  = MB(:,imin)/delZ;           <- MB used only to build Mp
312  if strcmp(run_params.model_P_or_C,'C')
318-324   SA recomputed from profiles(imin,iz)   <- NOT from SAp
325       RRt = w(imin,:)'.*SA;                  <- uses the recomputed SA
326       Mp  = Bt;                              <- Mp OVERWRITTEN, MB discarded
334  Bt = Mp;                                    <- therefore a no-op
     else
328       RRt = w(imin,:)'.*SAp;                 <- 'P' mode only: SAp WOULD matter
```

`MW` is never referenced. So the stubs need only return shape-correct arrays so
lines 285–292 don't error: `MB` and `SA` are `(p-1) x nmin`, because line 290
turns a length-*n* vector into a length-*(n+1)* one and the result must have
`p = 31` nodes. Actual particle-size evolution in `'C'` mode comes from the
`profiles` struct via `SA_VOL_2` / `get_pdf_donkey` / `add_pdfs`, all of which
**do** ship.

The other two stubs **raise an error rather than fabricate values**, because in
their branches (`transport = 'yes'`, `test = 'yes'`) the returns *do* feed the
physics. We were unable to reproduce these configurations with the released code.


---

## B. Files we had to override

### B1. `mod5.m` — 2 hunks, 11 upstream lines replaced

`diff upstream/weathering_model/mod5.m src/shim/mod5.m`

**(i) Hard-coded cluster paths.** Upstream:

```matlab
dirr{1} = '/home/sm1epk/USA/marks/';
dirr{2} = '/home/sm1epk/USA/marks/model/particle_weathering_300123/';
cd(dirr{2})
```

Change the hard-coded HPC layout to resolve from the repo and `cd` into 
`work/` (see above). We also changed `run_params.data_dir` from the relative 
`'../particle_weathering_data'` to an absolute path, since the working 
directory is no longer the model directory.
*Significance: none scientifically -- model itself is untouched.*

**(ii) The three `griddedInterpolant` loads.** Upstream:

```matlab
load('alk2pH_function.mat');            % -> alk2pH
load('CaSatBuffered_function.mat')      % -> CaSat
load('CaSatNotBuffered_function.mat')   % -> CaSat
```

These `.mat` files contain **serialized MATLAB classdef objects** that Octave cannot
deserialize.

We rebuild the interpolants from the companion `*_data.mat` files using
`src/shim/mk_interp2d.m`. We confirmed that **this is exact**: the authors'
`make_gridded_interpolant_data.m` appears to have written those files from these same
objects —

```matlab
CO2 = alk2pH.GridVectors{1};  alk = alk2pH.GridVectors{2};
values = alk2pH.Values;       save('alk2pH_data','CO2','alk','values')
```

— so the grid vectors and values are the same, just the interpolation
rule had to be matched; `griddedInterpolant` defaults to `Method='linear'` with
`ExtrapolationMethod='linear'`, which `mk_interp2d` reproduces by padding each
grid vector with an extra node carrying the edge slope.

*Significance: high risk if skipped, zero scientific change given our validation.*

### B2. `run_simple4.m` — 2 hunks, 72 lines added, 1 upstream line replaced

`diff upstream/weathering_model/particle_weathering_300123/run_simple4.m src/shim/run_simple4.m`

Upstream computes the entire carbonate state and then discards it at two levels:

```
fd15          returns Ca_sol_t, Ca_sat_t, Ca_precip_t and the alkalinity budget
run_simple4   captures all four (line 33), returns only alk_sim
mod5          discards alk_sim with a `~`
```

Without `Ca_sat` and `Ca_sol` there is no way to evaluate Ω at the model's own
state, which we need for our analysis. `run_simple4.m:39` also
computes `pH_avg_sim` which we output.

B2 also now requests three more outputs from `fd15` — `profiles_t`,
`tolerences_t` and `q_eff_t`. 

**Updated fields added to totals.diag**
`totals.diag` now carries the following, on fd15's regular output grid (100 steps per
simulated year), 31 depth nodes over 0–0.15 m:

| field | shape | what |
|---|---|---|
| `pH` | 31 × nt | native-resolution profile (before the monthly re-interp) |
| `pH_avg` | 1 × nt | 0–15 cm column mean — the published reduction |
| `Ca_sol` | 31 × nt | dissolved Ca, mol/L |
| `Ca_sat` | 31 × nt | Ca at calcite saturation — the model's buffered ceiling |
| `Ca_precip` | 31 × nt | precipitated Ca (SIC), mol/L |
| `H_sol` | 31 × nt | nitrification acidity |
| `alk` | 9 × 31 × nt | the full alkalinity budget, rows per `calc_pH.m:18`: `[alk, alk0, −alk_acid, N_alk, 2Ca, 2Mg, K, Na, CO2]` |
| `soil_CO2` | 31 × 1 | spin-up-mean profile — the one that sets `alk0` |
| `q` | 1 × nt | **effective** post-bucket flux, m/yr — see B3 |
| `B` | nmin × 31 × nt | undissolved mineral mass, kg/m³ |
| `C` | nmin × 31 × nt | dissolved mineral-equivalent, kg/m³ ≡ g/L (so `C./mol_mass` is mol/L) |
| `mineral_names`, `mol_mass`, `mf`, `elements`, `phi`, `depth`, `b_mass`, `buffer` | — | enough to reconstruct concentrations downstream |

`B` and `C` are necessary to get per-mineral dissolution: `totals.Basalt` and
`totals.Solution` aggregate to elements and lose which phase supplied them.
Mineral order is `diag.mineral_names`.

*Significance: no change to any computed quantity — just instrumentation.
`totals` gains a field, the `fd15` call asks for three more return values, and
nothing that existed is altered.*


### B3. `fd15.m` — 6 hunks, 29 lines added, 1 upstream line replaced

`diff upstream/weathering_model/particle_weathering_300123/fd15.m src/shim/fd15.m`

**What it adds: the effective water flux `q(t)`.**

`calc_drivers` returns raw infiltration, but the bucket block at `fd15.m:224-237`
then *overwrites* `q` before it is used:

```matlab
if q < 0
  swvf_new = max(swvf + q*Delt, soil_volume_capacity_min);
  q = run_params.bucket_dampner;          % 0.5 m/yr
else
  if swvf + q*Delt < soil_volume_capacity
    swvf_new = swvf + q*Delt;
    q = run_params.bucket_dampner;        % 0.5 m/yr
  else
    q = (q*Delt - (soil_volume_capacity - swvf))/Delt;   % true drainage
```

That post-bucket value advects every solute through `findiff` and
accumulates the export at `fd15.m:492-496`. 

*Significance: no change to any computed quantity. `q` was already being used by
the solver on every timestep; this just outputs it.*

### B4. `solution2pH.m` and `solution2CaSat.m` — 1 hunk each

Both branch on a `griddedInterpolant` property:

```matlab
if size(CaSat.GridVectors) == 1
  Ca_sat = CaSat(delAlk);
else
  Ca_sat = CaSat(CO2+delAlk*0,delAlk);
end
```

Our `CaSat` is a plain function handle with no `.GridVectors`, so the test 
errors. Both shipped `CaSat` tables are 2-D (CO₂ × δAlk), so the `else`
branch is the only one ever taken; we call it directly.
*Significance: none — the removed branch is unreachable with the shipped data.*

---

## C. Files we added that have no upstream counterpart

| File | What it does | Significance |
|---|---|---|
| `src/setup_paths.m` | Path precedence + builds `work/` | Plumbing, but necessary for override scheme |
| `src/run_site.m` | Assembles `inps` and calls `mod5` | Replaces `run_1_v5.m`, which hard-codes SLURM, `/home/sm1epk/`, etc. Field-for-field identical to what `run_1_v5.m` builds |
| `src/shim/mk_interp2d.m` | `griddedInterpolant` replacement | See B1(ii) |
| `src/shim/octave/contains.m` | Octave lacks `contains` | See below |
| `data/mineralogy_cluster_counts.csv` | The Fig. 3a sample counts per mineralogy cluster, and the mixing weight `w` they imply | **Changes how results are aggregated — see below** |
| `tools/mineralogy_weight.py` | Recovers `w` from a run pair and cross-checks it against the table above | Turns the E0 validation into a self-checking step |
| `tools/run_batch.sh`, `tools/run_one.sh` | One Octave process per job, resumable, optional `-j N` | Replaces the SLURM harness in `run_1_v5.m` |

### `data/mineralogy_cluster_counts.csv` — required to aggregate anything

This is the only file in the repo that affects **how model output becomes a
published-comparable number**.

The model runs once per mineralogy cluster. Neither run is comparable to the
published series on its own: the published `N2` is a **weighted mixture**,

```
N2(t) = w * run_1(t) + (1 - w) * run_2(t)
```

and `w` is a property of the source state. Without `w` you cannot compare a run to
the published data, aggregate the six sites, or scale to a national number.

*Significance: large -- incorrect `w` numbers will lead to erroneous CDR scale estimates*

### `contains`

Octave 11.3 does not implement `contains` (confirmed: `exist('contains') == 0`).
Upstream calls it in three places, all in the mineral-formula parser reached
from `set_basalt` → `read_min_params`:

```
str_get_element.m:8   contains(Alpha, st1(1))
str_get_element.m:12  contains(alpha, st1(i))
str_get_number.m:10   contains(numeric, st1(i))
```

Every call is "does this char array contain this one character". Our shim covers
char and cellstr and **errors** on anything else.
*Significance: without it, `set_basalt` fails immediately — this is the first
hard stop in the Octave port.*

### `setup_paths` and the fresh-tree race

Addresses hard-coded paths and difference between upstream an shim. 

*Significance: no computed quantity changes*

---

## D. Minor upstream bugs and traps we found but did not change

Recorded because they matter for interpretation. All minor and do not appear to affect results.

### D1. Plagioclase base-mechanism sign flag

`particle_weathering_data/minerals/mineral_parameters4_USA.csv` gives
`n_Base = +0.572` for all six plagioclase rows. Data File S6 gives **-0.572**.
Follow data file convention for consistency with Palandri and Kharaka, 2004.

### D2. `@ph2alk_no_buffer` — case-sensitivity flag

`mod5.m:191` writes `pH2Alk_theoretical = @ph2alk_no_buffer;` (lowercase p-h)
while the file is `pH2Alk_no_buffer.m`. This resolves only on a case-insensitive
filesystem — it works on macOS and Windows and would break on Linux. Our
override uses the case-sensitive name.

### D6. Two files named `run_strc_6.mat` flag

The deposit contains two different driver files with the same name:

| Path | Clusters | Is it the paper's? |
|---|---|---|
| `weathering_model/run_strc_6.mat` (83 MB) | **437** | **yes** |
| `weathering_model/particle_weathering_data/driving_data_structure/run_strc_6.mat` (100 MB) | 525 | no |

Only the 437-cluster file reproduces the outputs: its per-cluster cell
memberships sum to exactly 5,483 (the point count in the output pickles) and map
all of them on `(crop, lind)`; the 525-cluster file misses 27.

They are the same CLM5 simulation but cells appear to be re-clustered.

`src/setup_paths.m` hard-points at the 437-cluster file.

---

## E. Facts about the released data that the plan depends on

**`N2` is exactly the mean of `N1` and `N3`** (to 6 × 10⁻¹⁶), so the three-member
uncertainty envelope is two mineralogy runs, not three.

**`N1`/`N3` are a sorted envelope, not a fixed label.** `N1 ≤ N3` holds in all
6,226 deployed (cell, scenario) series without exception. It has to be a sort:
the bytownite cluster has the higher CDR ceiling in 11 of 13 states, but
Connecticut and Minnesota run the other way. Recipe: run `_1` and `_2`, order
per series, take the mean for `N2`.

**Feedstock naming, confirmed against Data File S5 for all 26 to 5 × 10⁻⁹:**
`<State>_1` is the **bytownite** (calcic plagioclase) cluster, `<State>_2` the
**labradorite** one, in all 13 states. The `_3` tables in `Ceqs/` are unused
leftovers.

**Runs are keyed by start year.** Series are not time-shift invariant: two runs
of the same cluster and feedstock starting in different years can reach different
results. The published runs used calendar-sliced CLM5 drivers from the
deployment year onward, which is what `run_site.m`'s `start_year` reproduces.

**Rock is applied at exactly 40 t ha⁻¹ yr⁻¹** from the deployment year in every
cell, every year.

**Run matrix:** 437 clusters → 453 (cluster, source-state) pairs → 538
(cluster, source, start-year) keys → **1,076 runs** × median 26 yr = 28,166
simulated years. The allocation does not need re-solving: the output pickles
carry each cell's `bas` and `yy` directly.


---

## F. The experiments

The harness runs one configuration, **E0**: the published model, with the buffered
(Nelson & Su) pH relation and the buffered calcite ceiling, exactly as upstream
hard-codes them (`run_params.buffer = 'yes'`). `run_site`'s `'experiment'` option
is a label and accepts only `'E0'`.

| | pH relation | Calcite ceiling | What it is |
|---|---|---|---|
| **E0** | buffered (Nelson & Su sigmoid) | buffered | The published configuration. Validates the harness |

**E1** (the thermodynamic calcite ceiling, with E0's dissolution held fixed) and
**E2** (the exported alkalinity capped at the modelled pH and soil pCO₂) are
post-processes on E0's saved carbonate state — the fields B2 and B3 surface — and
live in b25-analysis. Neither changes the model, so we don't run either here.


---
