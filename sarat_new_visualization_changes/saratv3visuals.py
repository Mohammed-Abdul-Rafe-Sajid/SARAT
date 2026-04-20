#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 27 11:37:04 2026

@author: arkaprava
"""

id_number=6687

# %%####this will be required as input in the form of string [comment to run the code as function]
import sys
import os
import numpy as np
# path='/home/arkaprava/INCOIS_ARO/SARAT_V3_Visualization/'
path = os.path.dirname(os.path.abspath(__file__))

# inputpath= os.path.join(path, f"case{id_number}/")
inputpath = os.path.join(path, "case6687")


# inputpath=f'/home/arkaprava/INCOIS_ARO/may2025/combination3186/case7070_31_24_26_c7052/case{id_number}/'
sys.path.append(inputpath)

functionpath='/home/arkaprava/INCOIS_ARO/SARAT_V3_Visualization/pyfunc/'


# outputpath=os.path.join(path, f"case{id_number}/figure/")
outputpath = os.path.join(inputpath, "figure")


# outputpath=f'/home/arkaprava/INCOIS_ARO/may2025/combination3186/case7070_31_24_26_c7052/case{id_number}/figure/'


# sys.path.append(functionpath)
import sarat_visuals
import allin1sarat

# %%


# put all the names of files required to run the code
# currentfile= os.path.join(inputpath,"current9620.nc")
# drifterfile=os.path.join(inputpath,"drifter9428.txt")
# completetraj=os.path.join(inputpath,"complete_traj_9428.dat")



# %%
results=allin1sarat.run_sarat_analysis(id_number, input_path=inputpath,num_trajectories=500, interval_size=24, plot_sighted_positions=False,beacontrack=False)

for key, value in results.items():
    globals()[key] = value
    
for key, value in grid_meta.items():
    globals()[key] = value


# plot_beacon_track = beacon_lon is not None and beacon_lat is not None
plot_beacon_track = False

# %%=== GENERATE CONVEX HULL GEOJSON FILES FOR EACH INTERVAL ===
import json
from geojson_utils import create_hull_geojson, create_geojson_index, save_geojson
from pdf_utils import generate_pdf_report, generate_summary_stats

def generate_hull_geojson_files(outputpath, prob_grids, intervals, lon_bins, lat_bins, probability_threshold=0.05):
    """
    Generate convex hull GeoJSON files for each time interval.
    Each GeoJSON contains a polygon representing the search region.
    """
    print(f"\n--- Generating Convex Hull GeoJSON files ---")
    print(f"Probability threshold: {probability_threshold}%\n")
    
    geojson_files = []
    valid_intervals = []
    
    for idx, (start_hour, end_hour) in enumerate(intervals):
        prob_grid = prob_grids[idx]
        interval_label = f"{start_hour}-{end_hour}h"
        
        # Generate hull
        geojson_data = create_hull_geojson(
            prob_grid, lon_bins, lat_bins, 
            interval_label, 
            threshold=probability_threshold
        )
        
        if geojson_data:
            # Save GeoJSON file
            filename = f"interval_{idx:03d}_{start_hour:03d}_{end_hour:03d}.geojson"
            filepath = os.path.join(outputpath, filename)
            save_geojson(geojson_data, filepath)
            
            points_included = geojson_data['properties']['points_included']
            max_prob = geojson_data['properties']['max_probability']
            area = geojson_data['properties']['hull_area']
            
            print(f"  ✓ Interval {idx} ({start_hour}-{end_hour}h): {points_included} points → {filename}")
            print(f"    └─ Area: {area:.4f}°², Max Prob: {max_prob}%")
            
            geojson_files.append(filename)
            valid_intervals.append([start_hour, end_hour])
    
    print(f"\n--- Hull GeoJSON generation complete: {len(geojson_files)}/{len(intervals)} intervals processed ---\n")
    
    return geojson_files, valid_intervals

# Generate convex hull GeoJSON files
geojson_files, geojson_intervals = generate_hull_geojson_files(
    outputpath, prob_grids, intervals, lon_bins, lat_bins, 
    probability_threshold=0.05
)

# %%=== GENERATE GEOJSON INDEX FOR LEAFLET MAP ===
def save_geojson_index(outputpath, geojson_files, intervals, case_id):
    """
    Create a GeoJSON index file for the Leaflet map to discover all intervals.
    """
    index = create_geojson_index(geojson_files, intervals, case_id)
    
    index_path = os.path.join(outputpath, "geojson_index.json")
    with open(index_path, "w") as f:
        json.dump(index, f, indent=2)
    
    print(f"✓ GeoJSON index created: {index_path}")
    print(f"  Geometry type: {index['geometry_type']}")
    print(f"  Time span: {intervals[0][0]}-{intervals[-1][1]} hours")
    print(f"  Total intervals: {len(intervals)}\n")

save_geojson_index(outputpath, geojson_files, geojson_intervals, id_number)

# %%=== GENERATE PDF REPORT ===
print("--- Generating PDF Report ---")
case_info = {
    "num_trajectories": 500,
    "grid_size": 0.1,
    "description": f"Search case analysis for ID {id_number}"
}

pdf_path = generate_pdf_report(
    outputpath, 
    id_number, 
    geojson_intervals,
    png_prefix="seeding",
    case_info=case_info
)

if pdf_path:
    print(f"  ✓ Multi-page PDF bulletin created with {len(geojson_intervals)} intervals\n")


# %%
xlow=80
xhigh=84
ylow=4
yhigh=6
# %%
##the variable name in the current file is differnet than usual, which are changed in the main function code.

sarat_visuals.plot_individual(outputpath,intervals, trajectories, centroids, ds_hourly, 
                             lon_bins, lat_bins, max_prob_global, 
                             sighted_positions=sighted_positions,
                             plot_beacon_track=False,plot_individual=True,xylimit=False,
                             plot_sighted_positions=True,reference_vector_length = 0.5, 
                             output_prefix="seeding")


# sarat_visuals.plot_individual(outputpath,intervals, trajectories, centroids, ds_hourly, 
#                              lon_bins, lat_bins,max_prob_global,beacon_time,beacon_lon,beacon_lat,
#                              xlow=xlow,xhigh=xhigh,ylow=ylow,yhigh=yhigh,
#                              plot_beacon_track=True,plot_individual=True,xylimit=True,
#                              plot_sighted_positions=False,reference_vector_length = 0.5, 
#                              output_prefix="seeding")

###if there is drifter plot_beacon_track=False--make this True and add beacon_time,beacon_lon,beacon_lat (in this seq) after max_prob_global
### check the actual function and change accordingly in different cases. 


sarat_visuals.plot_combined(outputpath,id_number,intervals, trajectories, centroids, ds_hourly, 
                             lon_bins, lat_bins,max_prob_global,
                             sighted_positions=sighted_positions,
                             plot_beacon_track=False,plot_combined=True,xylimit=False,plot_sighted_positions=True,reference_vector_length = 0.5, 
                             output_prefix="seeding")

# sarat_visuals.plot_combined(outputpath,id_number,intervals, trajectories, centroids, ds_hourly, 
#                              lon_bins, lat_bins,max_prob_global,beacon_time,beacon_lon,beacon_lat, 
#                              xlow=xlow,xhigh=xhigh,ylow=ylow,yhigh=yhigh, 
#                              plot_beacon_track=True,plot_combined=True,xylimit=True,
#                              plot_sighted_positions=False,reference_vector_length = 0.5, 
#                              output_prefix="seeding")


