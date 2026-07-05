#!/usr/bin/env python3
"""
generate_current_vectors.py
Generates current_vectors_{id}.json sidecar for the Leaflet frontend,
then copies all required files to webapp/data/.
Run from: sarat_new_visualization_changes/
"""
import os, sys, json, shutil
import numpy as np

base_path = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, base_path)

from wind_utils import get_wind_info_for_case
from geojson_utils import create_current_vectors_json, save_geojson

# ── Config ────────────────────────────────────────────────────────────
id_number  = 6687
NC_DIR     = os.path.join(os.path.dirname(base_path), "currentsncfiles_addedlater")
inputpath  = os.path.join(base_path, f"case{id_number}")
webapp_data = os.path.join(os.path.dirname(base_path), "webapp", "data")

# ── Read interval_index to get intervals ──────────────────────────────
index_path = os.path.join(inputpath, f"interval_index_{id_number}.json")
with open(index_path) as f:
    index_data = json.load(f)
intervals = [tuple(iv) for iv in index_data["intervals"]]
print(f"Intervals: {intervals}")

# ── Read userinput for LKP ────────────────────────────────────────────
userinput_path = os.path.join(inputpath, f"userinput_{id_number}.txt")
with open(userinput_path) as f:
    parts = f.read().strip().split()
lkp_lat = float(parts[1])
lkp_lon = float(parts[2])
print(f"LKP: lon={lkp_lon}, lat={lkp_lat}")

# ── Compute wind/current info ─────────────────────────────────────────
print("Computing per-interval current vectors from NC file...")
wind_info = get_wind_info_for_case(
    case_id    = id_number,
    lkp_lon    = lkp_lon,
    lkp_lat    = lkp_lat,
    intervals  = intervals,
    nc_dir     = NC_DIR,
    sample_step= 4
)
if not wind_info:
    print("ERROR: Could not compute wind info. NC file missing?")
    sys.exit(1)
print(f"Got wind info for {len(wind_info)} intervals")

# ── Rebuild prob_grids + bins via allin1sarat ─────────────────────────
print("Running minimal SARAT analysis to get prob_grids...")
sys.path.append(inputpath)
import allin1sarat
results   = allin1sarat.run_sarat_analysis(
    id_number, input_path=inputpath,
    num_trajectories=500, interval_size=12,
    plot_sighted_positions=False, beacontrack=False
)
prob_grids = results["prob_grids"]
grid_meta  = results["grid_meta"]
lon_bins   = grid_meta["lon_bins"]
lat_bins   = grid_meta["lat_bins"]
print(f"prob_grids: {len(prob_grids)} intervals")

# ── Generate sidecar ──────────────────────────────────────────────────
print("Generating current_vectors sidecar...")
cv_data = create_current_vectors_json(
    wind_info     = wind_info,
    prob_grids    = prob_grids,
    lon_bins      = lon_bins,
    lat_bins      = lat_bins,
    intervals     = intervals,
    case_id       = id_number,
    target_arrows = 12
)
out_path = os.path.join(inputpath, f"current_vectors_{id_number}.json")
save_geojson(cv_data, out_path)
print(f"Saved: {out_path}")

# ── Copy all files to webapp/data/ ────────────────────────────────────
print(f"\nCopying to {webapp_data} ...")
os.makedirs(webapp_data, exist_ok=True)
files_to_copy = set([
    f"current_vectors_{id_number}.json",
    f"interval_index_{id_number}.json",
    f"lkp_{id_number}.geojson",
    f"meantrajectory_{id_number}.geojson",
    f"trajectories_{id_number}.geojson",
])
for i in range(len(intervals)):
    files_to_copy.add(f"interval_{i:03d}_{id_number}.geojson")

for fn in sorted(files_to_copy):
    src = os.path.join(inputpath, fn)
    dst = os.path.join(webapp_data, fn)
    if os.path.exists(src):
        shutil.copy2(src, dst)
        print(f"  OK  {fn}")
    else:
        print(f"  MISSING  {fn}")

print("\nDone!")
