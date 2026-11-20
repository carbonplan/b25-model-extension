#!/usr/bin/env python3
"""Recover the mineralogy weight w that the paper used to form its N2 series.

The published outputs carry three columns per scenario, N1/N2/N3, and N2 is
exactly (N1+N3)/2. The natural reading -- that N1 and N3 are simply the two
per-state mineralogy runs -- does not seem to hold against the data. Instead
N1/N3 are a constructed confidence band, not the raw pair.

The raw pair is used to calculate N2. Given our own runs of cluster _1 and _2 at
the same driver point, feedstock state and start year, this solves

    N2(t) = w * run_1(t) + (1 - w) * run_2(t)

for w at each year. If our runs reproduce the paper's, w comes out constant --
which is a real constraint, not a fit, because the ratio run_1/run_2 changes
through the window. A drifting w means the harness is off.

w should also be a property of the SOURCE STATE (the sample counts behind each
mineralogy cluster, Extended Data Fig. 3), so the same value should appear for
every driver cluster sourcing that state.

Usage:
    python3 tools/mineralogy_weight.py results/E0_drv6_Virginia_1_5yr.mat \
                                       results/E0_drv6_Virginia_2_5yr.mat
"""
from __future__ import annotations

import argparse
import os
import pickle
import sys

import numpy as np
import scipy.io as sio

G_PER_M2_TO_T_PER_HA = 0.01


def unwrap(e):
    while isinstance(e, np.ndarray) and e.dtype == object and e.size >= 1:
        e = e.ravel()[0]
    return e


def load_clusters(run_strc):
    ml = sio.loadmat(run_strc, squeeze_me=False, struct_as_record=False)["mylist"][0]
    out = {}
    for i, e0 in enumerate(ml):
        e = unwrap(e0)
        crop = str(np.atleast_1d(e.Crop).ravel()[0])
        for lin in np.atleast_1d(e.lind).ravel():
            out[(crop, int(lin))] = i + 1  # 1-based, matching run_site
    return out


def cumulative(path):
    R = sio.loadmat(path, squeeze_me=True, struct_as_record=False)
    co2 = np.atleast_1d(R["CO2_mass"]).ravel().astype(float)
    nyr = (len(co2) - 1) // 12
    cum = np.array([co2[12 * k] for k in range(1, nyr + 1)]) * G_PER_M2_TO_T_PER_HA
    meta = dict(
        drv=int(np.atleast_1d(R["drv"]).ravel()[0]),
        basalt=str(np.atleast_1d(R["basalt"]).ravel()[0]),
        start=int(np.atleast_1d(R["start_year"]).ravel()[0]),
        experiment=str(np.atleast_1d(R["experiment"]).ravel()[0]),
    )
    return cum, meta


def published_n2(usa_erw, key2drv, drv, state, start, nyr):
    with open(os.path.join(usa_erw, "data",
                           "compiled_run_CO2_a_b_v6_varz.pkl"), "rb") as fh:
        db = pickle.load(fh)
    years = np.array([int(str(x)[:4]) for x in db[next(iter(db))]["CO2_a_b"].index])
    for v in db.values():
        crop = str(np.atleast_1d(v["nam"]).ravel()[0])
        if key2drv.get((crop, int(v["lind"]))) != drv:
            continue
        for S in (1, 2):
            if str(np.atleast_1d(v["bas"]).ravel()[S - 1]).replace(" ", "_") != state:
                continue
            if int(np.atleast_1d(v["yy"]).ravel()[S - 1]) != start:
                continue
            m = (years >= start) & (years < start + nyr)
            return np.cumsum(
                v["CO2_a_b"][f"S{S}_U1_N2_p100"].values[m] / float(v["ar"])
            )
    raise SystemExit(f"No published cell for drv={drv}, {state}, start={start}.")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("run_1", help="result for <State>_1 (bytownite cluster)")
    ap.add_argument("run_2", help="result for <State>_2 (labradorite cluster)")
    ap.add_argument("--usa-erw", default=os.path.expanduser("~/Downloads/USA_ERW"))
    ap.add_argument("--run-strc", default=None)
    args = ap.parse_args()

    a, ma = cumulative(args.run_1)
    b, mb = cumulative(args.run_2)
    for f in ("drv", "start", "experiment"):
        if ma[f] != mb[f]:
            raise SystemExit(f"The two runs differ in {f}: {ma[f]} vs {mb[f]}.")
    if not (ma["basalt"].endswith("_1") and mb["basalt"].endswith("_2")):
        raise SystemExit("Expected <State>_1 then <State>_2, in that order.")
    state = ma["basalt"].rsplit("_", 1)[0]
    nyr = min(len(a), len(b))

    run_strc = args.run_strc or os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        "..", "upstream", "weathering_model", "run_strc_6.mat",
    )
    n2 = published_n2(args.usa_erw, load_clusters(run_strc),
                      ma["drv"], state, ma["start"], nyr)

    a, b, n2 = a[:nyr], b[:nyr], n2[:nyr]
    w = (n2 - b) / (a - b)

    print(f"\n{ma['experiment']}  drv={ma['drv']}  {state}  start {ma['start']}")
    print(f"{'year':>6} {'run _1':>10} {'run _2':>10} {'pub N2':>10} "
          f"{'_1/_2':>8} {'w':>11}")
    for k in range(nyr):
        print(f"{ma['start'] + k:6d} {a[k]:10.4f} {b[k]:10.4f} {n2[k]:10.4f} "
              f"{a[k] / b[k]:8.4f} {w[k]:11.6f}")

    fit = w.mean() * a + (1 - w.mean()) * b
    err = np.abs(fit - n2) / n2

    # Cross-check against the Extended Data Fig. 3a sample counts. w is the
    # fraction of that state's rock analyses in cluster 1, so it is knowable
    # without running anything -- see data/mineralogy_cluster_counts.csv 
    counts = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                          "..", "data", "mineralogy_cluster_counts.csv")
    predicted = None
    if os.path.exists(counts):
        for line in open(counts):
            if line.startswith("#") or line.startswith("state"):
                continue
            row = line.rstrip("\n").split(",")
            if row and row[0].replace(" ", "_") == state:
                predicted = int(row[1]) / (int(row[1]) + int(row[2]))
                break
    print(f"\n  w = {w.mean():.6f}   spread over the window = {w.max() - w.min():.2e}")
    print(f"  _1/_2 ratio moves {a[0] / b[0]:.4f} -> {a[-1] / b[-1]:.4f}, so a constant w")
    print(f"  is a constraint on both trajectories, not a one-parameter fit.")
    print(f"  single-w residual vs published N2: max {err.max() * 100:.4f}%")
    verdict = "CONSISTENT" if (w.max() - w.min()) < 1e-3 and err.max() < 1e-3 else "DRIFTING -- harness suspect"
    print(f"  VERDICT: {verdict}")

    if predicted is not None:
        d = abs(predicted - w.mean())
        tag = "MATCH" if d < 1e-3 else "*** MISMATCH ***"
        print(f"  Fig. 3a sample count predicts w = {predicted:.6f}  "
              f"(diff {d:.1e})  {tag}")
    else:
        print(f"  no tabulated count for '{state}' in data/mineralogy_cluster_counts.csv")


if __name__ == "__main__":
    main()
