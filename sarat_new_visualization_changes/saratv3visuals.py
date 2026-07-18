#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 27 11:37:04 2026

@author: arkaprava
"""

import sys

import os
import numpy as np

# -------- CLI + fallback logic --------
# Original dynamic extraction:
# if len(sys.argv) >= 2:
#     id_number = int(sys.argv[1])
# else:
#     id_number = 6687

# Hardcoded test case for manual verification:
id_number = 6687

# Base path of script
base_path = os.path.dirname(os.path.abspath(__file__))

# Input path (CLI or default)
# ORIGINAL DYNAMIC PATH RESOLUTION:
# if len(sys.argv) >= 3:
#     inputpath = sys.argv[2]
# else:
#     # Look for candidate case directories:
#     # 1. Under sarat_new_visualization_changes/caseXXXX
#     # 2. Under root/caseXXXX
#     # 3. Under root/XXXX (unprefixed, e.g. root/6915)
#     candidate_1 = os.path.join(base_path, f"case{id_number}")
#     candidate_2 = os.path.join(os.path.dirname(base_path), f"case{id_number}")
#     candidate_3 = os.path.join(os.path.dirname(base_path), str(id_number))
#     
#     if os.path.exists(candidate_1):
#         inputpath = candidate_1
#     elif os.path.exists(candidate_2):
#         inputpath = candidate_2
#     elif os.path.exists(candidate_3):
#         inputpath = candidate_3
#     else:
#         inputpath = candidate_1
# 
# # Ensure absolute path
# if not os.path.isabs(inputpath):
#     inputpath = os.path.abspath(inputpath)

# Hardcoded input path for testing:
inputpath = os.path.join(base_path, f"case{id_number}")
if not os.path.isabs(inputpath):
    inputpath = os.path.abspath(inputpath)

# Output path
outputpath = os.path.join(inputpath, "figure")
if not os.path.exists(outputpath):
    os.makedirs(outputpath)

# Add to system path
sys.path.append(inputpath)
import sarat_visuals
import allin1sarat
from wind_utils import get_wind_info_for_case

print("✔ Starting pipeline")

# %%


# put all the names of files required to run the code
# currentfile= os.path.join(inputpath,"current9620.nc")
# drifterfile=os.path.join(inputpath,"drifter9428.txt")
# completetraj=os.path.join(inputpath,"complete_traj_9428.dat")



# %%
print("✔ Running analysis...")
# First pass with default interval_size to determine trajectory length
results=allin1sarat.run_sarat_analysis(id_number, input_path=inputpath,num_trajectories=500, interval_size=24, plot_sighted_positions=False,beacontrack=False)
print("✔ Analysis complete")

for key, value in results.items():
    globals()[key] = value
    
for key, value in grid_meta.items():
    globals()[key] = value

# Handle beacon track variables safely
beacon_lon = results.get("beacon_lon", None)
beacon_lat = results.get("beacon_lat", None)

plot_beacon_track = beacon_lon is not None and beacon_lat is not None

# Diagnostic: Check trajectory length and intervals
print(f"\n🔍 DIAGNOSTIC INFO:")
print(f"  Trajectory length: {trajectory_length} hours")
print(f"  Current intervals: {intervals}")
print(f"  Total intervals: {len(prob_grids)}")

# Dynamic interval_size based on trajectory_length (rule-based)
if trajectory_length <= 24:  # 1 day or less
    new_interval_size = 6
else:  # More than 1 day
    new_interval_size = 12

print(f"\n🔧 INTERVAL SIZE ADJUSTMENT:")
print(f"  Recommended interval_size: {new_interval_size} hours")

# If interval_size changed, re-run analysis with correct intervals
if new_interval_size != 24:
    print(f"  Re-running analysis with interval_size={new_interval_size}...")
    results=allin1sarat.run_sarat_analysis(id_number, input_path=inputpath,num_trajectories=500, interval_size=new_interval_size, plot_sighted_positions=False,beacontrack=False)
    print(f"  ✔ Analysis re-run complete")
    
    # Re-populate globals with new results (CRITICAL FIX)
    print("\n✔ Reassigning updated results...")
    for key, value in results.items():
        globals()[key] = value
        if key == "grid_meta":
            print(f"  → Updated {key}")
    
    # Re-extract grid_meta from globals and update it
    if "grid_meta" in results:
        grid_meta = results["grid_meta"]
    
    for key, value in grid_meta.items():
        globals()[key] = value
    
    # Verify variables were updated
    print(f"  → Updated prob_grids: {len(prob_grids)} intervals")
    print(f"  → Updated intervals: {len(intervals)} tuples")
    
    # Update beacon variables
    beacon_lon = results.get("beacon_lon", None)
    beacon_lat = results.get("beacon_lat", None)
    plot_beacon_track = beacon_lon is not None and beacon_lat is not None

print(f"\n✅ FINAL CONFIG:")
print(f"  Trajectory length: {trajectory_length} hours")
print(f"  Intervals: {intervals}")
print(f"  Total intervals: {len(prob_grids)}")

# Validation: Ensure intervals and prob_grids are in sync
print(f"\n[OK] Validated: {len(intervals)} intervals = {len(prob_grids)} probability grids")

# ──────────────────────────────────────────────────────────────
# Extract LKP from userinput file for wind annotation
# userinput format: case_type lkp_lat lkp_lon start end case_id email phone
# ──────────────────────────────────────────────────────────────
lkp_lon_wind = None
lkp_lat_wind = None
userinput_path = os.path.join(inputpath, f"userinput_{id_number}.txt")
if os.path.exists(userinput_path):
    try:
        with open(userinput_path) as _f:
            _parts = _f.read().strip().split()
        # col 1 = lat, col 2 = lon  (0-indexed)
        lkp_lat_wind = float(_parts[1])
        lkp_lon_wind = float(_parts[2])
        print(f"  LKP for wind: lon={lkp_lon_wind}, lat={lkp_lat_wind}")
    except Exception as e:
        print(f"  Could not parse userinput: {e}")

# ──────────────────────────────────────────────────────────────
# Load current NC and compute per-interval wind/current vectors
# ──────────────────────────────────────────────────────────────
NC_DIR = os.path.join(os.path.dirname(base_path), "currentsncfiles_addedlater")
print(f"\n[>>] Computing per-interval current/wind vectors from {NC_DIR} ...")
wind_info = None
if lkp_lon_wind is not None and lkp_lat_wind is not None:
    wind_info = get_wind_info_for_case(
        case_id    = id_number,
        lkp_lon    = lkp_lon_wind,
        lkp_lat    = lkp_lat_wind,
        intervals  = intervals,
        nc_dir     = NC_DIR,
        sample_step= 4      # sample at 0h, 4h, 8h within each period
    )
    if wind_info:
        print(f"  [OK] Wind info computed for {len(wind_info)} intervals")
    else:
        print("  [WARN] Wind info could not be computed (NC file missing?)")
else:
    print("  [WARN] LKP not available; skipping wind extraction")

print("\n✔ Starting GeoJSON generation...")
print(f"  Processing {len(prob_grids)} intervals...")

from geojson_utils import create_grid_geojson, create_hull_geojson, save_geojson, create_geojson_index, load_hull_points_from_file

hull_path = os.path.join(inputpath, f"finalconvexhull_{id_number}.dat")
v2_hull_points = load_hull_points_from_file(hull_path)
if v2_hull_points is not None:
    print(f"  Loaded V2 hull geometry from {hull_path}")
else:
    print(f"  No V2 hull geometry loaded from {hull_path}")

# Generate GeoJSON for each interval with BOTH hull boundary and grid heatmap
geojson_filenames = []
for interval_idx, prob_grid in enumerate(prob_grids):
    interval_label = f"{intervals[interval_idx][0]:.0f}-{intervals[interval_idx][1]:.0f}h"
    # Check if grid has any data
    max_prob_in_grid = np.max(prob_grid) if prob_grid.size > 0 else 0
    print(f"  Interval {interval_idx} ({interval_label}): max probability = {max_prob_in_grid:.6f}")
    
    # Create BOTH layers: boundary hull and grid heatmap
    hull_geojson = create_hull_geojson(
        prob_grid,
        lon_bins,
        lat_bins,
        interval_label,
        v2_hull_points=v2_hull_points,
    )
    grid_geojson = create_grid_geojson(prob_grid, lon_bins, lat_bins, interval_label)
    
    # Combine both into single FeatureCollection
    geojson_data = {
        "type": "FeatureCollection",
        "features": []
    }
    
    # Add hull feature first (boundary layer)
    if hull_geojson:
        if hull_geojson.get("type") == "FeatureCollection" and hull_geojson.get("features"):
            geojson_data["features"].extend(hull_geojson["features"])
        elif hull_geojson.get("type") == "Feature":
            geojson_data["features"].append(hull_geojson)
    
    # Add grid features second (heatmap layer)
    if grid_geojson and grid_geojson.get("features"):
        geojson_data["features"].extend(grid_geojson["features"])
    
    if geojson_data and geojson_data.get("features"):
        filename = f"interval_{interval_idx:03d}_{id_number}.geojson"
        filepath = os.path.join(inputpath, filename)
        save_geojson(geojson_data, filepath)
        geojson_filenames.append(filename)
        
        hull_count = 1 if hull_geojson else 0
        grid_count = len(grid_geojson["features"]) if grid_geojson and grid_geojson.get("features") else 0
        print(f"  ✓ Interval {interval_idx}: 1 hull + {grid_count} cells → {filename}")
    else:
        print(f"  ⚠ Interval {interval_idx}: No features generated")

# Create index of all GeoJSON files
index_data = create_geojson_index(geojson_filenames, intervals, id_number)
index_filepath = os.path.join(inputpath, f"interval_index_{id_number}.json")
save_geojson(index_data, index_filepath)

# ── Generate current-vector sidecar for the Leaflet frontend ──────────
from geojson_utils import create_current_vectors_json
print("✔ Generating current-vector sidecar JSON ...")
cv_data = create_current_vectors_json(
    wind_info  = wind_info if wind_info else [],
    prob_grids = prob_grids,
    lon_bins   = lon_bins,
    lat_bins   = lat_bins,
    intervals  = intervals,
    case_id    = id_number,
    target_arrows = 12,
    v2_hull_points=v2_hull_points,
)
cv_filepath = os.path.join(inputpath, f"current_vectors_{id_number}.json")
save_geojson(cv_data, cv_filepath)
print(f"  ✓ Saved {cv_filepath}")


print("✔ Generating KML files...")
import convert_to_kml
convert_to_kml.convert_all(inputpath)
print("✔ KML generation complete")

print("✔ Generating PDF report...")

from pdf_utils import generate_pdf_report
generate_pdf_report(
    outputpath,
    id_number,
    intervals
)

print("✔ PDF generation complete")


# %%
# Plotting configuration
xlow=80
xhigh=84
ylow=4
yhigh=6

# %%
print("✔ Starting PNG generation...")

# Generate interval PNGs dynamically based on calculated intervals
# The plot_individual function uses the intervals parameter to generate PNGs with correct naming
if plot_beacon_track and beacon_time is not None:
    # With beacon track
    print("  Generating PNGs with beacon track overlay...")
    sarat_visuals.plot_individual(
        outputpath,
        intervals,
        trajectories,
        centroids,
        ds_hourly,
        lon_bins,
        lat_bins,
        max_prob_global,
        beacon_time=beacon_time,
        beacon_lon=beacon_lon,
        beacon_lat=beacon_lat,
        xlow=xlow,
        xhigh=xhigh,
        ylow=ylow,
        yhigh=yhigh,
        plot_beacon_track=True,
        plot_individual=True,
        xylimit=True,
        plot_sighted_positions=False,
        reference_vector_length=0.5,
        output_prefix="seeding"
    )
else:
    # Without beacon track
    print("  Generating PNGs without beacon track...")
    sarat_visuals.plot_individual(
        outputpath,
        intervals,
        trajectories,
        centroids,
        ds_hourly,
        lon_bins,
        lat_bins,
        max_prob_global,
        sighted_positions=sighted_positions,
        plot_beacon_track=False,
        plot_individual=True,
        xylimit=False,
        plot_sighted_positions=True,
        reference_vector_length=0.5,
        output_prefix="seeding",
        wind_info=wind_info
    )

print("✔ PNG generation complete")

# sarat_visuals.plot_individual(outputpath,intervals, trajectories, centroids, ds_hourly, 
#                              lon_bins, lat_bins,max_prob_global,beacon_time,beacon_lon,beacon_lat,
#                              xlow=xlow,xhigh=xhigh,ylow=ylow,yhigh=yhigh,
#                              plot_beacon_track=True,plot_individual=True,xylimit=True,
#                              plot_sighted_positions=False,reference_vector_length = 0.5, 
#                              output_prefix="seeding")

###if there is drifter plot_beacon_track=False--make this True and add beacon_time,beacon_lon,beacon_lat (in this seq) after max_prob_global
### check the actual function and change accordingly in different cases. 

# --- Generate paginated 2x2 combined probability images ---
# This generates one PNG per page of 4 intervals (2x2 grid).
# Output: seeding_duration_{id}_combined_page_1.png, _page_2.png, ...
sarat_visuals.plot_combined(
    outputpath, id_number, intervals, trajectories, centroids, ds_hourly,
    lon_bins, lat_bins, max_prob_global,
    sighted_positions=sighted_positions,
    plot_beacon_track=False, plot_combined=True,
    xylimit=False, plot_sighted_positions=False,
    reference_vector_length=0.5, output_prefix="seeding",
    wind_info=wind_info
)

# sarat_visuals.plot_combined(outputpath,id_number,intervals, trajectories, centroids, ds_hourly, 
#                              lon_bins, lat_bins,max_prob_global,beacon_time,beacon_lon,beacon_lat, 
#                              xlow=xlow,xhigh=xhigh,ylow=ylow,yhigh=yhigh, 
#                              plot_beacon_track=True,plot_combined=True,xylimit=True,
#                              plot_sighted_positions=False,reference_vector_length = 0.5, 
#                              output_prefix="seeding")

print("✔ Pipeline complete")


