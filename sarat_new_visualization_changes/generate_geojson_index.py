#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GeoJSON Index Generator
Scans directory for GeoJSON files and creates an index for the Leaflet map.
"""

import os
import json
import glob
import re

def generate_geojson_index(directory="."):
    """
    Scan directory for GeoJSON files matching the SARAT naming pattern.
    Create an index file for the Leaflet map.
    """
    
    print(f"🔍 Scanning directory: {directory}")
    
    # Find all GeoJSON files
    geojson_files = glob.glob(os.path.join(directory, "interval_*.geojson"))
    geojson_files.sort()
    
    if not geojson_files:
        print("❌ No GeoJSON files found!")
        return False
    
    print(f"✓ Found {len(geojson_files)} GeoJSON files")
    
    # Extract interval information from filenames
    intervals = []
    files_list = []
    
    pattern = r"interval_(\d+)_(\d+)_(\d+)\.geojson"
    
    for filepath in geojson_files:
        filename = os.path.basename(filepath)
        match = re.match(pattern, filename)
        
        if match:
            idx = int(match.group(1))
            start_hour = int(match.group(2))
            end_hour = int(match.group(3))
            
            intervals.append([start_hour, end_hour])
            files_list.append(filename)
            print(f"  • {filename}: hours {start_hour}-{end_hour}")
        else:
            print(f"  ⚠️  Skipping {filename} (doesn't match naming pattern)")
    
    # Create index
    index = {
        "version": "1.0",
        "case_id": "6687",
        "generated": str(__import__('datetime').datetime.now().isoformat()),
        "total_intervals": len(files_list),
        "files": files_list,
        "intervals": intervals
    }
    
    # Save index
    index_path = os.path.join(directory, "geojson_index.json")
    with open(index_path, "w") as f:
        json.dump(index, f, indent=2)
    
    print(f"\n✓ Index saved: {index_path}")
    print(f"  Total intervals: {len(intervals)}")
    
    # Print summary
    print("\n📊 Summary:")
    print(f"  Time span: {intervals[0][0]}-{intervals[-1][1]} hours")
    print(f"  Interval coverage: {intervals}")
    
    return True

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        directory = sys.argv[1]
    else:
        directory = "."
    
    success = generate_geojson_index(directory)
    sys.exit(0 if success else 1)
