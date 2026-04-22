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


print("✔ Starting GeoJSON generation...")

from geojson_utils import create_hull_geojson, save_geojson, create_geojson_index

# Generate GeoJSON for each interval
for interval_idx, prob_grid in enumerate(prob_grids):
    interval_label = f"{intervals[interval_idx][0]:.0f}-{intervals[interval_idx][1]:.0f}h"
    geojson_data = create_hull_geojson(prob_grid, lon_bins, lat_bins, interval_label)
    
    if geojson_data:
        filename = f"interval_{interval_idx:03d}_{int(intervals[interval_idx][0]):03d}_{int(intervals[interval_idx][1]):03d}.geojson"
        filepath = os.path.join(outputpath, filename)
        save_geojson(geojson_data, filepath)

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
xlow=80
xhigh=84
ylow=4
yhigh=6
# %%
##the variable name in the current file is differnet than usual, which are changed in the main function code.

# Plotting functions disabled (requires cartopy module)
# sarat_visuals.plot_individual(outputpath,intervals, trajectories, centroids, ds_hourly, 
#                              lon_bins, lat_bins, max_prob_global, 
#                              sighted_positions=sighted_positions,
#                              plot_beacon_track=False,plot_individual=True,xylimit=False,
#                              plot_sighted_positions=True,reference_vector_length = 0.5, 
#                              output_prefix="seeding")


# sarat_visuals.plot_individual(outputpath,intervals, trajectories, centroids, ds_hourly, 
#                              lon_bins, lat_bins,max_prob_global,beacon_time,beacon_lon,beacon_lat,
#                              xlow=xlow,xhigh=xhigh,ylow=ylow,yhigh=yhigh,
#                              plot_beacon_track=True,plot_individual=True,xylimit=True,
#                              plot_sighted_positions=False,reference_vector_length = 0.5, 
#                              output_prefix="seeding")

###if there is drifter plot_beacon_track=False--make this True and add beacon_time,beacon_lon,beacon_lat (in this seq) after max_prob_global
### check the actual function and change accordingly in different cases. 

# Plotting function disabled (requires cartopy module)
# sarat_visuals.plot_combined(outputpath,id_number,intervals, trajectories, centroids, ds_hourly, 
#                              lon_bins, lat_bins,max_prob_global,
#                              sighted_positions=sighted_positions,
#                              plot_beacon_track=False,plot_combined=True,xylimit=False,plot_sighted_positions=True,reference_vector_length = 0.5, 
#                              output_prefix="seeding")

# sarat_visuals.plot_combined(outputpath,id_number,intervals, trajectories, centroids, ds_hourly, 
#                              lon_bins, lat_bins,max_prob_global,beacon_time,beacon_lon,beacon_lat, 
#                              xlow=xlow,xhigh=xhigh,ylow=ylow,yhigh=yhigh, 
#                              plot_beacon_track=True,plot_combined=True,xylimit=True,
#                              plot_sighted_positions=False,reference_vector_length = 0.5, 
#                              output_prefix="seeding")

print("✔ Pipeline complete")


