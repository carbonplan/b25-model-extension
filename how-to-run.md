# how-to-run.md

Reproduce our runs from a clean checkout.

---

## 1. Requirements

**Octave 11.3+** (what we use), or **MATLAB R2019a+**.

```bash
brew install octave          # macOS; ~2 GB with dependencies
octave --version
```

No add-on toolboxes are required in either case. 

Octave additionally lacks `contains`, which upstream *does* call; that is
supplied by `src/shim/octave/contains.m` and needs no package.

Python is needed only for the helpers in `tools/` — the comparison scripts, job
generation, and the Coiled batch submitter — not to run the model. The
environment is managed with [pixi](https://pixi.sh) (`pixi.toml` + `pixi.lock`):

```bash
pixi install                 # creates .pixi/envs/default, git-ignored
pixi run python tools/compare_to_published.py --help
pixi shell                   # or drop into the env
```

Octave stays outside pixi — install it with brew as above.

For the notebook in `tools/`, select the kernel at
`.pixi/envs/default/bin/python`.

---

## 2. Restore the large upstream files

Four files are git-ignored for size. They are part of Zenodo
[10940280](https://doi.org/10.5281/zenodo.10940280) — download that deposit and
copy them in:

| File | Size | Needed for |
|---|---|---|
| `run_strc_6.mat` | 83 MB | **required** — the 437-cluster drivers |
| `particle_weathering_data/driving_data_structure/run_strc_6.mat` | 100 MB | not used; see notes.md D6 |
| `particle_weathering_300123/Ceqs/Ceq_table_Kfeldspar.mat` | 38 MB | not used by any state feedstock |
| `particle_weathering_300123/Ceqs/Copy_of_Ceq_table_Blue_Ridge.mat` | 5.7 MB | not used |

Only the first is required. Place it at
`upstream/weathering_model/run_strc_6.mat`.

> **Do not substitute the other `run_strc_6.mat`.** Two different files share
> that name and only the 437-cluster one reproduces the published outputs. See
> [notes.md § D6](notes.md#d6-two-files-named-run_strc_6mat).


---

## 3. Smoke test

From the repository root:

```bash
octave --no-gui --quiet --eval "
  addpath('src');
  o = run_site(5, 'Virginia_1', 'experiment','E0', 'tf',1, 'start_year',2043);
"
```

Expected, in about 100 seconds:

```
run_site: drv=5  Temperate Maize  Virginia_1  E0  1 yr from 2043
c2b ratio               = 12.530507%
run_site: done in 97.3 s | CDR/rock = 0.1253 tCO2/t | pH 6.90 -> 6.89
```

`setup_paths` builds `work/` on first call (a staging directory holding a symlink
to `Ceqs/` and empty `PSD/` directories). It is regenerated on demand and safe to
delete.


---

## 4. Running one site

```matlab
addpath('src');
o = run_site(drv, basalt, 'Name', value, ...);
```

| Argument | Meaning |
|---|---|
| `drv` | Driver cluster, 1–437, indexing `mylist` in `run_strc_6.mat` |
| `basalt` | e.g. `'Virginia_1'`. `_1` is the bytownite cluster, `_2` the labradorite one, in all 13 states |
| `'experiment'` | `'E0'` (default), `'E1'`, `'E2'` |
| `'tf'` | Run length in years (default 51) |
| `'start_year'` | First year of application, default 2020. Drivers are sliced from here — the published runs did the same, and results are **not** time-shift invariant |
| `'save_to'` | `.mat` path to write |

---

## 5. Reproducing the experiments

### 5.1 Validating E0 at a site

Run **both** mineralogy clusters for the site, at its published deployment year:

```bash
octave --no-gui --quiet --eval "addpath('src');
  run_site(6, 'Virginia_1', 'experiment','E0', 'tf',5, 'start_year',2043, \
           'save_to','results/E0_drv6_Virginia_1_5yr.mat');"
```

Then recover the mineralogy weight:

```bash
python3 tools/mineralogy_weight.py results/E0_drv6_Virginia_1_5yr.mat \
                                   results/E0_drv6_Virginia_2_5yr.mat
```

**What a pass looks like.** The published `N2` series is a weighted mixture of the
two runs, `N2 = w·run_1 + (1−w)·run_2`. The tool solves for `w` at each year and
prints its spread. A pass is a **constant** `w` — spread below ~1e-4.


### 5.2 Running a batch

```bash
tools/run_batch.sh tools/jobs_weight_check.txt weight_check
```

One line per job in the jobs file: `drv basalt start_year tf experiment`. The
runner uses one Octave process per job, skips any result already on disk, and
logs to `logs/<tag>.log`. Launch it detached (`nohup … & disown`) for anything long.


---

## 6. Scaling simulations to a national number

### 6.1 One simulation = one soil column

A `run_site` call runs a **1-D soil column**: 31 nodes over 0–15 cm, stepped
through time, with 40 t/ha of crushed basalt applied every year. It answers:

> given this climate, this soil, and this rock, how much CO₂ is removed **per
> hectare per year**?

A run is fully defined by:

| | argument | why it matters |
|---|---|---|
| climate + soil | `drv` | selects the driver cluster |
| rock | `basalt` | mineralogy only — `<State>_1` or `_2` |
| timing | `start_year` | drivers are calendar-sliced, so 2032 ≠ 2043 |

### 6.2 Points, cells, and clusters

Three nested things, easy to conflate:

| | count | what it is |
|---|---|---|
| grid cell | 2,907 | a CLM5 cell, 23 × 31 km |
| **point** | 5,483 | a *(grid cell, crop)* pair — one cell growing maize and soy is two points |
| **cluster** | 437 | a group of 1–30 points (median 12) sharing **one** driver set |

Every model input is stored once per cluster:
monthly temperature at 7 depths, infiltration, NPP, soil respiration, air CO₂, the
nitrogen-flux profile, the initial soil-pH profile, field capacity, one crop.

Verified that points in the same cluster receiving the same feedstock have
CDR **per hectare** identical to machine precision. 


What varies point-to-point *within* a cluster is only the accounting:

- **area** (median CV 27% across a cluster's points) — an accounting quantity
- **deployment** — which source state, and which first-application year

### 6.3 Recipient vs source states

- **Recipient state** — where rock is spread. Sets climate and soil, via the
  point's cluster. The ~20 farm states.
- **Source state** — where rock is quarried. Sets **mineralogy only**. 13 states
  × 2 representative basalts = **26 feedstocks**.


### 6.4 How many runs per cluster

A cluster can be deployed twice — the 1 Gt and 2 Gt scenarios may source it from 
different states, or start it in different years — and each combination is a separate run:


### 6.5 Scaling one run up to Fig. 1a

```
one run                          t CO2 per hectare per year
  |  mix the 2 mineralogies, fixed per-state weight w      (S5.1; Virginia 0.7798)
  |  copy to each of the cluster's member points
  |  x that point's area in hectares                       t CO2 per point per year
  |  apply the deployment schedule (not every point, not from year one)
  |  sum over all deployed points                          GtCO2/yr  <- Fig. 1a
  |  - mining/transport/spreading emissions
  |  + avoided fertiliser credits                          net CDR
```

Each point carries a source state (`bas`) and a first-application year
(`yy`), set by state quarry-production curves that ramp to exactly 1 or 2 Gt of
rock per year by 2070 (Data File S4), allocated to farmland by transport cost.
Points with `bas = NaN` never receive rock.

| | 1 Gt scenario | 2 Gt scenario |
|---|---|---|
| points deployed | 2,322 | 3,904 |
| area treated | 24.5 M ha | 49.2 M ha |
| share of the 69.5 M ha cropland | 35% | 71% |

Because application is fixed at 40 t/ha/yr, doubling the rock does not intensify
treatment — it **spreads onto more land**.

