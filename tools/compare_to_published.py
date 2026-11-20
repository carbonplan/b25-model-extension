#!/usr/bin/env python3
"""Compare a run_site() result against the published per-cell outputs.

This is the E0 validation. It addresses whether our harness can reproduce
the numbers in Zenodo 14755423 for the same driver cluster, feedstock and
deployment year.

Units, traced through the model so the comparison is like-for-like:

  mass_balance.m:307   CO2_mass = interp1(t, CO2_mols*44, 0:1/12:t(end))
  run_simple4.m:85     C_molperl = 1000*outflow_t./mol_mass   % "mols per m^2"

so CO2_mass is grams CO2 per m^2, cumulative, on a monthly grid. 1 g/m^2 =
0.01 t/ha. 

The published side is cumulative tCO2 per cell divided by the cell's area in ha.
Cells in the same cluster with the same source state are identical per hectare to
machine precision, so any one of them will do; we check that and report the spread.

Usage:
    python3 tools/compare_to_published.py results/E0_drv5_Virginia_1_5yr.mat \\
        [--usa-erw ~/Downloads/USA_ERW] [--run-strc <path>]
"""
from __future__ import annotations

import argparse
import os
import pickle
import sys

import numpy as np
import scipy.io as sio

G_PER_M2_TO_T_PER_HA = 0.01
RECORD_START = 2020


def unwrap(e):
    while isinstance(e, np.ndarray) and e.dtype == object and e.size >= 1:
        e = e.ravel()[0]
    return e


def load_clusters(run_strc):
    """Map (crop, lind) -> cluster index for the 437-cluster driver file.

    Indices are 1-BASED, matching mylist{drv} in MATLAB/Octave and therefore the
    `drv` argument of run_site(). Getting this wrong is easy and quiet: a 0-based
    index silently compares the model's cluster N against the published cluster
    N+1, which looks like a 25-40% model discrepancy rather than a lookup error.
    """
    ml = sio.loadmat(run_strc, squeeze_me=False, struct_as_record=False)["mylist"][0]
    key2drv = {}
    for i, e0 in enumerate(ml):
        e = unwrap(e0)
        crop = str(np.atleast_1d(e.Crop).ravel()[0])
        for lin in np.atleast_1d(e.lind).ravel():
            key2drv[(crop, int(lin))] = i + 1  # 1-based
    if len(ml) != 437:
        print(
            f"WARNING: {run_strc} has {len(ml)} clusters, not 437. This is probably "
            "the wrong run_strc_6.mat -- see notes.md D6.",
            file=sys.stderr,
        )
    return key2drv


def published_series(usa_erw, key2drv, drv, state, start_year):
    """Cumulative published CDR (t/ha) for one cluster + source state + start year."""
    path = os.path.join(usa_erw, "data", "compiled_run_CO2_a_b_v6_varz.pkl")
    with open(path, "rb") as fh:
        db = pickle.load(fh)

    years = np.array([int(str(x)[:4]) for x in db[next(iter(db))]["CO2_a_b"].index])
    per_cluster = {1: [], 2: [], 3: []}
    n_cells = 0

    for v in db.values():
        crop = str(np.atleast_1d(v["nam"]).ravel()[0])
        d = key2drv.get((crop, int(v["lind"])))
        if d != drv:
            continue
        for S in (1, 2):
            bas = str(np.atleast_1d(v["bas"]).ravel()[S - 1])
            if bas.replace(" ", "_") != state:
                continue
            if int(np.atleast_1d(v["yy"]).ravel()[S - 1]) != start_year:
                continue
            area = float(v["ar"])
            n_cells += 1
            for N in (1, 2, 3):
                per_cluster[N].append(
                    v["CO2_a_b"][f"S{S}_U1_N{N}_p100"].values / area
                )

    if not n_cells:
        raise SystemExit(
            f"No published cell matches drv={drv}, source={state}, start={start_year}."
        )

    out = {}
    for N in (1, 2, 3):
        M = np.array(per_cluster[N])
        mx, mn = M.max(0), M.min(0)
        spread = np.nanmax(np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-30), 0.0))
        out[N] = dict(annual=M[0], spread=spread)
    return years, out, n_cells


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("result", help="a .mat written by run_site()")
    ap.add_argument("--usa-erw", default=os.path.expanduser("~/Downloads/USA_ERW"))
    ap.add_argument("--run-strc", default=None)
    args = ap.parse_args()

    R = sio.loadmat(args.result, squeeze_me=True, struct_as_record=False)
    drv = int(np.atleast_1d(R["drv"]).ravel()[0])
    basalt = str(np.atleast_1d(R["basalt"]).ravel()[0])
    start_year = int(np.atleast_1d(R["start_year"]).ravel()[0])
    experiment = str(np.atleast_1d(R["experiment"]).ravel()[0])
    state = basalt.rsplit("_", 1)[0]

    run_strc = args.run_strc or os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        "..", "upstream", "weathering_model", "run_strc_6.mat",
    )
    key2drv = load_clusters(run_strc)

    # ours: cumulative g CO2/m^2 on a monthly grid -> t/ha at each year end
    co2 = np.atleast_1d(R["CO2_mass"]).ravel().astype(float)
    nyr = (len(co2) - 1) // 12
    ours_cum = np.array([co2[12 * k] for k in range(1, nyr + 1)]) * G_PER_M2_TO_T_PER_HA

    years, pub, n_cells = published_series(
        args.usa_erw, key2drv, drv, state, start_year
    )
    m = years >= start_year

    print(f"\n{experiment}  drv={drv}  {basalt}  start {start_year}")
    print(f"published cells matching: {n_cells}   "
          f"per-ha spread within cluster: {pub[2]['spread']:.1e}")
    print(f"our run: {nyr} yr  ({float(np.atleast_1d(R['wall_seconds']).ravel()[0]):.0f} s wall)\n")

    # N1/N3 are a sorted envelope, so a single mineralogy cluster is not tied to
    # a fixed column. Report against both ends and the mean.
    hdr = f"{'year':>6} {'ours':>10} {'pub N1':>10} {'pub N2':>10} {'pub N3':>10} {'ours/N2':>9}"
    print(hdr)
    print("-" * len(hdr))
    for k in range(nyr):
        p = {N: np.cumsum(pub[N]["annual"][m])[k] for N in (1, 2, 3)}
        ratio = ours_cum[k] / p[2] if p[2] else np.nan
        print(f"{start_year + k:6d} {ours_cum[k]:10.4f} "
              f"{p[1]:10.4f} {p[2]:10.4f} {p[3]:10.4f} {ratio:9.3f}")

    p1 = np.cumsum(pub[1]["annual"][m])[nyr - 1]
    p3 = np.cumsum(pub[3]["annual"][m])[nyr - 1]
    lo, hi = min(p1, p3), max(p1, p3)
    inside = lo <= ours_cum[-1] <= hi
    print(f"\ncumulative at {start_year + nyr - 1}: ours {ours_cum[-1]:.4f} t/ha, "
          f"published envelope [{lo:.4f}, {hi:.4f}]")
    print("VERDICT:", "inside the N1-N3 envelope" if inside
          else "OUTSIDE the envelope -- harness does not reproduce E0")


if __name__ == "__main__":
    main()
