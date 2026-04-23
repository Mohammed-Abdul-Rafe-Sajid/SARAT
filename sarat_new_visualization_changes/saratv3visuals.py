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

if len(sys.argv) >= 2:
    id_number = int(sys.argv[1])
else:
    id_number = 6687

# Base path of script
base_path = os.path.dirname(os.path.abspath(__file__))

# Input path (CLI or default)
if len(sys.argv) >= 3:
    inputpath = sys.argv[2]
else:
    inputpath = os.path.join(base_path, f"case{id_number}")

# Ensure absolute path
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
if trajectory_length >= 72:  # 3 days or more
    new_interval_size = 12
elif trajectory_length >= 24:  # 1 day or more
    new_interval_size = 6
else:
    new_interval_size = 4

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
if len(intervals) != len(prob_grids):
    print(f"\n⚠️  WARNING: Mismatch between intervals ({len(intervals)}) and prob_grids ({len(prob_grids)})")
    print(f"   This may indicate incomplete data reload!")
else:
    print(f"\n✅ Validated: {len(intervals)} intervals = {len(prob_grids)} probability grids ✓")

print("\n✔ Starting GeoJSON generation...")
print(f"  Processing {len(prob_grids)} intervals...")

from geojson_utils import create_grid_geojson, create_hull_geojson, save_geojson, create_geojson_index

# Generate GeoJSON for each interval with BOTH hull boundary and grid heatmap
for interval_idx, prob_grid in enumerate(prob_grids):
    interval_label = f"{intervals[interval_idx][0]:.0f}-{intervals[interval_idx][1]:.0f}h"
    # Check if grid has any data
    max_prob_in_grid = np.max(prob_grid) if prob_grid.size > 0 else 0
    print(f"  Interval {interval_idx} ({interval_label}): max probability = {max_prob_in_grid:.6f}")
    
    # Create BOTH layers: boundary hull and grid heatmap
    hull_geojson = create_hull_geojson(prob_grid, lon_bins, lat_bins, interval_label)
    grid_geojson = create_grid_geojson(prob_grid, lon_bins, lat_bins, interval_label)
    
    # Combine both into single FeatureCollection
    geojson_data = {
        "type": "FeatureCollection",
        "features": []
    }
    
    # Add hull feature first (boundary layer)
    if hull_geojson:
        geojson_data["features"].append(hull_geojson)
    
    # Add grid features second (heatmap layer)
    if grid_geojson and grid_geojson.get("features"):
        geojson_data["features"].extend(grid_geojson["features"])
    
    if geojson_data and geojson_data.get("features"):
        filename = f"interval_{interval_idx:03d}_{int(intervals[interval_idx][0]):03d}_{int(intervals[interval_idx][1]):03d}.geojson"
        filepath = os.path.join(outputpath, filename)
        save_geojson(geojson_data, filepath)
        hull_count = 1 if hull_geojson else 0
        grid_count = len(grid_geojson["features"]) if grid_geojson and grid_geojson.get("features") else 0
        print(f"  ✓ Interval {interval_idx}: 1 hull + {grid_count} cells → {filename}")
    else:
        print(f"  ⚠ Interval {interval_idx}: No features generated")

# Create index of all GeoJSON files
create_geojson_index(
    [f for f in os.listdir(outputpath) if f.endswith('.geojson')],
    intervals,
    id_number
)

print("✔ GeoJSON generation complete")


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
        output_prefix="seeding"
    )

print("✔ PNG generation complete")

print("✔ Pipeline complete")


