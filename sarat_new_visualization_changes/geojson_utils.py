#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GeoJSON Utilities for SARAT v3
Handles convex hull computation and GeoJSON polygon generation
"""

import json
import numpy as np
from scipy.spatial import ConvexHull


def truncate(val):
    """Truncate float to 6 decimal places"""
    s = str(val)
    if '.' in s:
        i = s.find('.')
        return float(s[:i+7])
    return float(s)

# ---------------------------------------------------------------------------
# Helper: Dynamically truncate a coordinate to max 6 decimal places cleanly
# operating purely on strings to avoid IEEE float auto-rounding artifacts
# like "69.832999999..." involuntarily rounding up to 69.833 natively.
# ---------------------------------------------------------------------------
def round_coord(value):
    """Truncate to up to 6 decimal places dynamically."""
    s = str(value)
    idx = s.find('.')
    if idx != -1 and len(s) > idx + 7:
        s = s[:idx+7]
    return float(s)


def create_hull_geojson(prob_grid, lon_bins, lat_bins, interval_label, threshold=0.05, max_prob_global=None):
    """
    Convert probability grid → FeatureCollection GeoJSON
    
    Creates a FeatureCollection containing:
    1. A bounding rectangle Feature
    2. Grid cell Features with calculated colors based on probability
    """
    
    # Optional: setup colormap for grid cells
    cmap = None
    norm = None
    if max_prob_global is not None and max_prob_global > 0:
        try:
            import matplotlib.cm as cm
            import matplotlib.colors as mcolors
            cmap = cm.get_cmap('PuBuGn')
            norm = mcolors.Normalize(vmin=0, vmax=max_prob_global)
        except ImportError:
            pass

    min_lon, max_lon = float('inf'), float('-inf')
    min_lat, max_lat = float('inf'), float('-inf')
    points_included = 0
    max_prob = 0
    
    grid_features = []
    
    for i in range(prob_grid.shape[0]):  # lat dimension
        for j in range(prob_grid.shape[1]):  # lon dimension
            prob_value = prob_grid[i][j]
            
            if prob_value > threshold:
                cell_min_lon = lon_bins[j]
                cell_max_lon = lon_bins[j+1]
                cell_min_lat = lat_bins[i]
                cell_max_lat = lat_bins[i+1]
                
                # Update bounding box
                min_lon = min(min_lon, cell_min_lon)
                max_lon = max(max_lon, cell_max_lon)
                min_lat = min(min_lat, cell_min_lat)
                max_lat = max(max_lat, cell_max_lat)
                
                points_included += 1
                max_prob = max(max_prob, prob_value)
                
                # Create grid cell geometry
                cell_coords = [
                    [round_coord(cell_min_lon), round_coord(cell_min_lat)],
                    [round_coord(cell_max_lon), round_coord(cell_min_lat)],
                    [round_coord(cell_max_lon), round_coord(cell_max_lat)],
                    [round_coord(cell_min_lon), round_coord(cell_max_lat)],
                    [round_coord(cell_min_lon), round_coord(cell_min_lat)]
                ]
                
                # Determine color
                fill_color = "#cccccc" # fallback
                if cmap and norm:
                    import matplotlib.colors as mcolors
                    rgba = cmap(norm(prob_value))
                    fill_color = mcolors.to_hex(rgba)
                    
                grid_feature = {
                    "type": "Feature",
                    "properties": {
                        "type": "grid_cell",
                        "probability": round(float(prob_value), 4),
                        "color": fill_color
                    },
                    "geometry": {
                        "type": "Polygon",
                        "coordinates": [cell_coords]
                    }
                }
                grid_features.append(grid_feature)
    
    # Need at least 1 point for bounding rectangle
    if points_included == 0:
        print(f"  ⚠️  Interval {interval_label}: 0 points above threshold - skipping rectangle")
        return None
    
    # Compute bounding rectangle feature
    try:
        polygon_coords = [
            [round_coord(min_lon), round_coord(min_lat)],
            [round_coord(max_lon), round_coord(min_lat)],
            [round_coord(max_lon), round_coord(max_lat)],
            [round_coord(min_lon), round_coord(max_lat)],
            [round_coord(min_lon), round_coord(min_lat)]
        ]
        
        box_area = (max_lon - min_lon) * (max_lat - min_lat)
        
        bbox_feature = {
            "type": "Feature",
            "properties": {
                "type": "bounding_box",
                "interval": interval_label,
                "points_included": points_included,
                "max_probability": round(float(max_prob), 4),
                "hull_area": round(float(box_area), 4)  # 2D box area
            },
            "geometry": {
                "type": "Polygon",
                "coordinates": [polygon_coords]
            }
        }
        
        # Combine bounding box and grid cells
        features = [bbox_feature] + grid_features
        
        geojson = {
            "type": "FeatureCollection",
            "properties": {
                "interval": interval_label,
                "points_included": points_included,
                "max_probability": round(float(max_prob), 4)
            },
            "features": features
        }
        
        return geojson
    
    except Exception as e:
        print(f"  ✗ Error computing rectangle for {interval_label}: {e}")
        return None


def create_grid_geojson(prob_grid, lon_bins, lat_bins, interval_label, threshold=0.05):
    """
    Convert probability grid → individual grid cell polygons FeatureCollection GeoJSON
    
    Creates a feature for each grid cell (colored by probability like a heatmap).
    Each feature is a small rectangular polygon representing one grid cell.
    
    Parameters
    ----------
    prob_grid : np.ndarray
        2D probability array (rows=lat, cols=lon)
    lon_bins : np.ndarray
        Longitude bin edges
    lat_bins : np.ndarray
        Latitude bin edges
    interval_label : str
        Interval label (e.g., "0-24h")
    threshold : float
        Skip cells below this normalized probability threshold (0-1 scale, default: 0.05)
    
    Returns
    -------
    dict
        FeatureCollection with Polygon features (one per grid cell)
    """
    
    features = []
    
    # Calculate max probability for normalization
    max_prob = np.max(prob_grid) if np.max(prob_grid) > 0 else 1.0
    
    for i in range(prob_grid.shape[0]):  # lat dimension
        for j in range(prob_grid.shape[1]):  # lon dimension
            prob = prob_grid[i, j]
            
            # Normalize probability (0–1 scale)
            norm_prob = prob / max_prob if max_prob > 0 else 0
            
            # Filter weak noise - only include cells above threshold
            if norm_prob < threshold:
                continue
            
            # Get grid cell boundaries
            min_lon = lon_bins[j]
            max_lon = lon_bins[j + 1]
            min_lat = lat_bins[i]
            max_lat = lat_bins[i + 1]
            
            # Create rectangular polygon with 5 points (closed)
            coords = [
                [round_coord(min_lon), round_coord(min_lat)],
                [round_coord(max_lon), round_coord(min_lat)],
                [round_coord(max_lon), round_coord(max_lat)],
                [round_coord(min_lon), round_coord(max_lat)],
                [round_coord(min_lon), round_coord(min_lat)]
            ]
            
            feature = {
                "type": "Feature",
                "properties": {
                    "probability": float(prob),
                    "normalized_probability": round(float(norm_prob), 4),
                    "probability_percent": round(float(prob * 100), 2),
                    "interval": interval_label,
                    "grid_i": int(i),
                    "grid_j": int(j)
                },
                "geometry": {
                    "type": "Polygon",
                    "coordinates": [coords]
                }
            }
            
            features.append(feature)
    
    return {
        "type": "FeatureCollection",
        "features": features
    }


def create_points_geojson(prob_grid, lon_bins, lat_bins, interval_label, threshold=0.05):
    """
    Convert probability grid → points FeatureCollection GeoJSON
    
    This is the fallback/alternative to hull - returns scattered points instead.
    Useful for comparison or when hull fails.
    
    Parameters
    ----------
    prob_grid : np.ndarray
        2D probability array
    lon_bins : np.ndarray
        Longitude bins
    lat_bins : np.ndarray
        Latitude bins
    interval_label : str
        Interval label
    threshold : float
        Probability threshold
    
    Returns
    -------
    dict
        FeatureCollection with Point features
    """
    
    features = []
    
    for i in range(prob_grid.shape[0]):
        for j in range(prob_grid.shape[1]):
            prob_value = prob_grid[i][j]
            
            if prob_value >= threshold:
                lon = (lon_bins[j] + lon_bins[j+1]) / 2.0
                lat = (lat_bins[i] + lat_bins[i+1]) / 2.0
                
                feature = {
                    "type": "Feature",
                    "properties": {
                        "interval": interval_label,
                        "probability": round(float(prob_value), 4),
                        "probability_percent": round(float(prob_value), 2)
                    },
                    "geometry": {
                        "type": "Point",
                        # Round coordinates to 6 decimal places
                        "coordinates": [round_coord(lon), round_coord(lat)]
                    }
                }
                features.append(feature)
    
    geojson = {
        "type": "FeatureCollection",
        "properties": {
            "interval": interval_label,
            "feature_count": len(features)
        },
        "features": features
    }
    
    return geojson


def save_geojson(geojson_data, filepath):
    """
    Save GeoJSON to file
    
    Parameters
    ----------
    geojson_data : dict
        GeoJSON object
    filepath : str
        Output file path
    """
    
    with open(filepath, "w") as f:
        json.dump(geojson_data, f, indent=2)


def create_geojson_index(geojson_files, intervals, case_id):
    """
    Create an index file for GeoJSON discovery
    
    Parameters
    ----------
    geojson_files : list
        List of GeoJSON filenames
    intervals : list
        List of [start, end] hour tuples
    case_id : str or int
        Case identifier
    
    Returns
    -------
    dict
        Index data structure
    """
    
    import datetime
    
    index = {
        "version": "1.0",
        "case_id": str(case_id),
        "generated": datetime.datetime.now().isoformat(),
        "total_intervals": len(geojson_files),
        "files": geojson_files,
        "intervals": intervals,
        "geometry_type": "polygon"  # Indicate hulls, not points
    }
    
    return index


def create_current_vectors_json(wind_info, prob_grids, lon_bins, lat_bins, intervals, case_id,
                                 target_arrows=12):
    """
    Generate a current-vector sidecar JSON for Leaflet rendering.
    Exports structured GRIB JSON format for leaflet-velocity.

    Parameters
    ----------
    wind_info   : list of dicts from wind_utils.compute_interval_wind
    prob_grids  : list of 2-D np.ndarray (one per interval)
    lon_bins    : 1-D np.ndarray – longitude bin edges
    lat_bins    : 1-D np.ndarray – latitude bin edges
    intervals   : list of (start, end) hour tuples
    case_id     : int or str
    target_arrows : int – ignored (used full subset grid for leaflet-velocity)

    Returns
    -------
    dict  ready to json.dump as  current_vectors_{case_id}.json
    """
    import datetime

    intervals_data = []

    for idx, (start, end) in enumerate(intervals):
        winfo = wind_info[idx] if idx < len(wind_info) else None
        interval_label = f"{start:.0f}-{end:.0f}h"

        # ----------------------------------------------------------
        # Derive bbox from probability grid
        # ----------------------------------------------------------
        bbox = {"min_lon": None, "max_lon": None, "min_lat": None, "max_lat": None}
        if idx < len(prob_grids):
            pg = prob_grids[idx]
            threshold_abs = float(np.max(pg)) * 0.05 if pg.size > 0 else 0
            for i in range(pg.shape[0]):
                for j in range(pg.shape[1]):
                    if pg[i, j] > threshold_abs:
                        lo = float(lon_bins[j])
                        hi_lo = float(lon_bins[j + 1])
                        la = float(lat_bins[i])
                        hi_la = float(lat_bins[i + 1])
                        if bbox["min_lon"] is None or lo < bbox["min_lon"]:
                            bbox["min_lon"] = lo
                        if bbox["max_lon"] is None or hi_lo > bbox["max_lon"]:
                            bbox["max_lon"] = hi_lo
                        if bbox["min_lat"] is None or la < bbox["min_lat"]:
                            bbox["min_lat"] = la
                        if bbox["max_lat"] is None or hi_la > bbox["max_lat"]:
                            bbox["max_lat"] = hi_la

        velocity_grib = None
        lkp_speed = None
        valid = False

        if winfo is not None and winfo.get("valid", False):
            lkp_speed = float(winfo.get("speed", 0.0))
            u_2d    = winfo.get("u_field_2d")
            v_2d    = winfo.get("v_field_2d")
            lon_arr = winfo.get("lon_arr")
            lat_arr = winfo.get("lat_arr")

            if u_2d is not None and lon_arr is not None and bbox["min_lon"] is not None:
                # Subset to bbox with a small buffer of 0.2 degrees to prevent edge interpolation issues in leaflet-velocity
                buf = 0.2
                lon_mask = (lon_arr >= (bbox["min_lon"] - buf)) & (lon_arr <= (bbox["max_lon"] + buf))
                lat_mask = (lat_arr >= (bbox["min_lat"] - buf)) & (lat_arr <= (bbox["max_lat"] + buf))

                lon_sub = lon_arr[lon_mask]
                lat_sub = lat_arr[lat_mask]

                # Ensure dimensions are valid
                if lon_sub.size > 1 and lat_sub.size > 1:
                    u_sub = u_2d[np.ix_(np.where(lat_mask)[0], np.where(lon_mask)[0])]
                    v_sub = v_2d[np.ix_(np.where(lat_mask)[0], np.where(lon_mask)[0])]

                    nx = int(lon_sub.size)
                    ny = int(lat_sub.size)
                    lo1 = float(lon_sub[0])
                    lo2 = float(lon_sub[-1])
                    la1 = float(lat_sub[-1]) # Top latitude (North)
                    la2 = float(lat_sub[0])  # Bottom latitude (South)
                    dx = float((lo2 - lo1) / (nx - 1))
                    dy = float((la1 - la2) / (ny - 1))

                    # Row-major ordering: from North to South, West to East
                    u_data = []
                    v_data = []
                    for r in range(ny - 1, -1, -1):
                        for c in range(nx):
                            u_val = u_sub[r, c]
                            v_val = v_sub[r, c]
                            # Fill NaNs with 0.0 so leaflet-velocity doesn't break
                            u_data.append(0.0 if np.isnan(u_val) else float(u_val))
                            v_data.append(0.0 if np.isnan(v_val) else float(v_val))

                    # Build GRIB JSON array
                    velocity_grib = [
                        {
                            "header": {
                                "parameterCategory": 2,
                                "parameterNumber": 2,
                                "parameterUnit": "m.s-1",
                                "nx": nx,
                                "ny": ny,
                                "lo1": lo1,
                                "la1": la1,
                                "lo2": lo2,
                                "la2": la2,
                                "dx": dx,
                                "dy": dy
                            },
                            "data": u_data
                        },
                        {
                            "header": {
                                "parameterCategory": 2,
                                "parameterNumber": 3,
                                "parameterUnit": "m.s-1",
                                "nx": nx,
                                "ny": ny,
                                "lo1": lo1,
                                "la1": la1,
                                "lo2": lo2,
                                "la2": la2,
                                "dx": dx,
                                "dy": dy
                            },
                            "data": v_data
                        }
                    ]
                    valid = True

        intervals_data.append({
            "interval_idx":   idx,
            "interval_label": interval_label,
            "start_h":        int(start),
            "end_h":          int(end),
            "bbox":           bbox,
            "lkp_speed_ms":   lkp_speed,
            "valid":          valid,
            "velocity_grib":  velocity_grib
        })

    return {
        "version":   "1.0",
        "case_id":   str(case_id),
        "generated": datetime.datetime.now().isoformat(),
        "intervals": intervals_data
    }


if __name__ == "__main__":

    """
    Quick test of convex hull generation
    """
    print("GeoJSON Utilities - SARAT v3")
    print("=" * 50)
    
    # Create dummy data
    prob_grid = np.random.rand(10, 10) * 5  # 0-5% probability
    lon_bins = np.linspace(80, 85, 11)
    lat_bins = np.linspace(10, 15, 11)
    
    # Test hull generation
    hull_geojson = create_hull_geojson(prob_grid, lon_bins, lat_bins, "0-24h")
    
    if hull_geojson:
        print("✓ Convex hull generated successfully")
        print(f"  Polygon has {len(hull_geojson['geometry']['coordinates'][0])} vertices")
    else:
        print("✗ Hull generation failed")
