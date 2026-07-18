#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GeoJSON Utilities for SARAT v3
Handles convex hull computation and GeoJSON polygon generation
"""

import json
import os

import numpy as np
from scipy.spatial import ConvexHull

# Configurable cumulative-probability threshold for interval footprint selection.
# Cells are ranked by probability and retained until the cumulative mass reaches this fraction.
CUMULATIVE_PROBABILITY_THRESHOLD = 0.95


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


def load_hull_points_from_file(hull_path):
    """Load V2 hull points from an ASCII hull file."""
    if not hull_path or not os.path.exists(hull_path):
        return None

    points = []
    try:
        with open(hull_path, "r") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                parts = line.split()
                if len(parts) >= 2:
                    points.append([float(parts[0]), float(parts[1])])
    except Exception:
        return None

    if not points:
        return None

    arr = np.asarray(points, dtype=float)
    if arr.ndim != 2 or arr.shape[1] != 2:
        return None

    return arr


def _normalize_polygon(points):
    """Remove duplicate and degenerate points and return a clean polygon array."""
    if points is None:
        return None

    arr = np.asarray(points, dtype=float)
    if arr.ndim != 2 or arr.shape[1] != 2:
        return None

    cleaned = []
    for point in arr:
        if not cleaned or not np.allclose(cleaned[-1], point):
            cleaned.append(point)

    if len(cleaned) >= 2 and np.allclose(cleaned[0], cleaned[-1]):
        cleaned.pop()

    # Remove repeated interior points and any collinear duplicates that would distort clipping.
    if len(cleaned) >= 3:
        simplified = []
        for point in cleaned:
            if not simplified:
                simplified.append(point)
                continue
            if np.allclose(simplified[-1], point):
                continue
            if len(simplified) >= 2:
                prev = simplified[-2]
                curr = simplified[-1]
                nxt = point
                cross = (curr[0] - prev[0]) * (nxt[1] - prev[1]) - (curr[1] - prev[1]) * (nxt[0] - prev[0])
                if abs(cross) < 1e-12:
                    simplified[-1] = point
                    continue
            simplified.append(point)
        cleaned = simplified

    if len(cleaned) >= 2 and np.allclose(cleaned[0], cleaned[-1]):
        cleaned.pop()

    if len(cleaned) < 3:
        return None

    return np.asarray(cleaned, dtype=float)


def _polygon_area(points):
    """Signed polygon area for orientation normalization."""
    if points is None or len(points) < 3:
        return 0.0

    x = points[:, 0]
    y = points[:, 1]
    return 0.5 * np.sum(x * np.roll(y, -1) - y * np.roll(x, -1))


def _orient_polygon(points):
    """Ensure the polygon is oriented counter-clockwise for clipping."""
    area = _polygon_area(points)
    if area < 0:
        return points[::-1]
    return points


def _inside_edge(point, edge_start, edge_end):
    """Check whether a point lies inside the clipping half-plane."""
    cross = (edge_end[0] - edge_start[0]) * (point[1] - edge_start[1]) - (edge_end[1] - edge_start[1]) * (point[0] - edge_start[0])
    return cross >= -1e-12


def _point_in_polygon(point, polygon_points, include_boundary=True):
    """Point-in-polygon test for a simple polygon."""
    if polygon_points is None or len(polygon_points) < 3:
        return False

    x, y = point
    polygon = np.asarray(polygon_points, dtype=float)
    n = len(polygon)
    inside = False
    for i in range(n):
        x1, y1 = polygon[i]
        x2, y2 = polygon[(i + 1) % n]
        if ((y1 > y) != (y2 > y)):
            xinters = (x2 - x1) * (y - y1) / (y2 - y1) + x1
            if x < xinters:
                inside = not inside

    if include_boundary:
        for i in range(n):
            x1, y1 = polygon[i]
            x2, y2 = polygon[(i + 1) % n]
            if abs((x2 - x1) * (y - y1) - (y2 - y1) * (x - x1)) < 1e-12:
                if min(x1, x2) - 1e-12 <= x <= max(x1, x2) + 1e-12 and min(y1, y2) - 1e-12 <= y <= max(y1, y2) + 1e-12:
                    return True

    return inside


def _line_intersection(start, end, edge_start, edge_end):
    """Compute the intersection of two lines."""
    x1, y1 = start
    x2, y2 = end
    x3, y3 = edge_start
    x4, y4 = edge_end

    den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    if abs(den) < 1e-12:
        return np.array([x1, y1], dtype=float)

    px = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / den
    py = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / den
    return np.array([px, py], dtype=float)


def _clip_polygon(subject, clipper):
    """Clip a subject polygon by a convex clip polygon using Sutherland-Hodgman."""
    subject_poly = _normalize_polygon(subject)
    clip_poly = _normalize_polygon(clipper)
    if subject_poly is None or clip_poly is None:
        return None

    clip_poly = _orient_polygon(clip_poly)
    output = subject_poly.tolist()

    for edge_idx in range(len(clip_poly)):
        edge_start = clip_poly[edge_idx]
        edge_end = clip_poly[(edge_idx + 1) % len(clip_poly)]
        input_list = output
        output = []

        if not input_list:
            break

        start = input_list[-1]
        for end in input_list:
            start_inside = _inside_edge(start, edge_start, edge_end)
            end_inside = _inside_edge(end, edge_start, edge_end)

            if end_inside and not start_inside:
                output.append(_line_intersection(start, end, edge_start, edge_end))
            elif end_inside and start_inside:
                output.append(end)
            elif not end_inside and start_inside:
                output.append(_line_intersection(start, end, edge_start, edge_end))

            start = end

    if not output:
        return None

    return np.asarray(output, dtype=float)


def _is_polygon_within_polygon(subject, clipper):
    """Return True when the subject polygon lies fully inside the clip polygon."""
    if subject is None or clipper is None:
        return False

    subject_poly = _normalize_polygon(subject)
    clip_poly = _normalize_polygon(clipper)
    if subject_poly is None or clip_poly is None:
        return False

    # The hull supplied by SARAT is convex, so checking the rectangle corners against the hull is sufficient.
    for point in subject_poly:
        if not _point_in_polygon(point, clip_poly, include_boundary=True):
            return False

    return True


def _select_cumulative_probability_cells(prob_grid, threshold=CUMULATIVE_PROBABILITY_THRESHOLD, lon_bins=None, lat_bins=None, v2_hull_points=None):
    """Select cells by raw probability threshold for legacy callers or by cumulative-probability coverage for the new default."""
    if prob_grid is None:
        return None, 0.0, 0.0, 0, 0

    flat = np.asarray(prob_grid, dtype=float).ravel()
    if flat.size == 0:
        return None, 0.0, 0.0, 0, 0

    total_probability = float(np.sum(flat))
    if total_probability <= 0:
        return None, 0.0, 0.0, 0, 0

    if threshold <= 0.5:
        retained_mask = flat >= threshold
        retained_mask = retained_mask.reshape(prob_grid.shape)
        retained_prob = float(np.sum(flat[retained_mask.ravel()]))
        return retained_mask, total_probability, retained_prob, int(flat.size), int(np.count_nonzero(retained_mask))

    hull_poly = _normalize_polygon(v2_hull_points) if v2_hull_points is not None else None
    if hull_poly is not None and lon_bins is not None and lat_bins is not None:
        eligible_indices = []
        for i in range(prob_grid.shape[0]):
            for j in range(prob_grid.shape[1]):
                lon_center = 0.5 * (float(lon_bins[j]) + float(lon_bins[j + 1]))
                lat_center = 0.5 * (float(lat_bins[i]) + float(lat_bins[i + 1]))
                if _point_in_polygon((lon_center, lat_center), hull_poly, include_boundary=True):
                    eligible_indices.append(i * prob_grid.shape[1] + j)
        if not eligible_indices:
            return None, 0.0, 0.0, 0, 0
        eligible_indices = np.asarray(eligible_indices, dtype=int)
        eligible_flat = flat[eligible_indices]
        eligible_total_probability = float(np.sum(eligible_flat))
        if eligible_total_probability <= 0:
            return None, 0.0, 0.0, 0, 0

        order = eligible_indices[np.argsort(eligible_flat)[::-1]]
        cumulative = 0.0
        retained = []
        retained_prob = 0.0
        for idx in order:
            prob_value = float(flat[idx])
            retained.append(int(idx))
            cumulative += prob_value
            retained_prob += prob_value
            if cumulative / eligible_total_probability >= threshold:
                break
    else:
        eligible_total_probability = total_probability
        order = np.argsort(flat)[::-1]
        cumulative = 0.0
        retained = []
        retained_prob = 0.0
        for idx in order:
            prob_value = float(flat[idx])
            retained.append(int(idx))
            cumulative += prob_value
            retained_prob += prob_value
            if cumulative / eligible_total_probability >= threshold:
                break

    retained_mask = np.zeros_like(flat, dtype=bool)
    retained_mask[retained] = True
    retained_mask = retained_mask.reshape(prob_grid.shape)

    return retained_mask, total_probability, retained_prob, int(flat.size), int(np.count_nonzero(retained_mask))


def _compute_interval_bounds(prob_grid, lon_bins, lat_bins, threshold=CUMULATIVE_PROBABILITY_THRESHOLD, v2_hull_points=None):
    """Compute the minimum axis-aligned rectangle that fully contains the retained interval cells."""
    if prob_grid is None:
        return None

    retained_mask, total_probability, retained_prob, total_cells, retained_cells_count = _select_cumulative_probability_cells(
        prob_grid,
        threshold=threshold,
        lon_bins=lon_bins,
        lat_bins=lat_bins,
        v2_hull_points=v2_hull_points,
    )
    if retained_mask is None:
        return None

    selected_cells = []
    for i in range(prob_grid.shape[0]):
        for j in range(prob_grid.shape[1]):
            if retained_mask[i, j]:
                cell_min_lon = float(lon_bins[j])
                cell_max_lon = float(lon_bins[j + 1])
                cell_min_lat = float(lat_bins[i])
                cell_max_lat = float(lat_bins[i + 1])
                selected_cells.append([cell_min_lon, cell_max_lon, cell_min_lat, cell_max_lat])

    if not selected_cells:
        return None

    hull_poly = _normalize_polygon(v2_hull_points) if v2_hull_points is not None else None

    candidate_xs = []
    candidate_ys = []
    if hull_poly is not None:
        candidate_xs.extend([float(np.min(hull_poly[:, 0])), float(np.max(hull_poly[:, 0]))])
        candidate_ys.extend([float(np.min(hull_poly[:, 1])), float(np.max(hull_poly[:, 1]))])
    for cell in selected_cells:
        min_lon, max_lon, min_lat, max_lat = cell
        candidate_xs.extend([float(min_lon), float(max_lon)])
        candidate_ys.extend([float(min_lat), float(max_lat)])

    if not candidate_xs or not candidate_ys:
        return None

    candidate_xs = sorted(set(candidate_xs))
    candidate_ys = sorted(set(candidate_ys))

    best_rect = None
    best_area = None
    for i in range(len(candidate_xs)):
        for j in range(i + 1, len(candidate_xs)):
            x1 = candidate_xs[i]
            x2 = candidate_xs[j]
            if x2 <= x1:
                continue
            for k in range(len(candidate_ys)):
                for l in range(k + 1, len(candidate_ys)):
                    y1 = candidate_ys[k]
                    y2 = candidate_ys[l]
                    if y2 <= y1:
                        continue

                    if not all(
                        x1 <= cell[0] and x2 >= cell[1] and y1 <= cell[2] and y2 >= cell[3]
                        for cell in selected_cells
                    ):
                        continue

                    rect_points = np.asarray([
                        [x1, y1],
                        [x2, y1],
                        [x2, y2],
                        [x1, y2],
                        [x1, y1],
                    ], dtype=float)

                    if hull_poly is not None and not _is_polygon_within_polygon(rect_points, hull_poly):
                        continue

                    area = (x2 - x1) * (y2 - y1)
                    if best_rect is None or area < best_area:
                        best_rect = [x1, x2, y1, y2]
                        best_area = area

    if best_rect is not None:
        return [float(best_rect[0]), float(best_rect[1]), float(best_rect[2]), float(best_rect[3])]

    return None


def _filter_prob_grid_for_footprint(prob_grid, threshold=CUMULATIVE_PROBABILITY_THRESHOLD, lon_bins=None, lat_bins=None, v2_hull_points=None):
    """Return a boolean mask and summary stats for the retained cumulative-probability footprint."""
    return _select_cumulative_probability_cells(
        prob_grid,
        threshold=threshold,
        lon_bins=lon_bins,
        lat_bins=lat_bins,
        v2_hull_points=v2_hull_points,
    )


def _log_footprint_summary(interval_label, retained_mask, total_probability, retained_prob, total_cells, retained_cells_count):
    """Print a concise summary for the retained footprint selection."""
    if retained_mask is None:
        print(f"  Interval {interval_label}: no retained footprint")
        return

    if total_probability > 0:
        retained_percent = (retained_prob / total_probability) * 100.0
    else:
        retained_percent = 0.0

    print(
        f"  Interval {interval_label}: selected cells={retained_cells_count}, "
        f"retained probability={retained_percent:.1f}%"
    )


def create_hull_geojson(prob_grid, lon_bins, lat_bins, interval_label, threshold=CUMULATIVE_PROBABILITY_THRESHOLD, max_prob_global=None, v2_hull_points=None):
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

    points_included = 0
    max_prob = 0
    
    grid_features = []
    retained_mask, total_probability, retained_prob, total_cells, retained_cells_count = _filter_prob_grid_for_footprint(
        prob_grid,
        threshold=threshold,
        lon_bins=lon_bins,
        lat_bins=lat_bins,
        v2_hull_points=v2_hull_points,
    )
    _log_footprint_summary(interval_label, retained_mask, total_probability, retained_prob, total_cells, retained_cells_count)
    if retained_mask is None:
        retained_mask = np.zeros_like(prob_grid, dtype=bool)
        total_probability = float(np.sum(prob_grid)) if prob_grid is not None else 0.0
        retained_prob = 0.0
        total_cells = int(np.prod(prob_grid.shape)) if prob_grid is not None else 0
        retained_cells_count = 0
    
    for i in range(prob_grid.shape[0]):  # lat dimension
        for j in range(prob_grid.shape[1]):  # lon dimension
            prob_value = prob_grid[i][j]
            
            if retained_mask[i, j]:
                cell_min_lon = lon_bins[j]
                cell_max_lon = lon_bins[j+1]
                cell_min_lat = lat_bins[i]
                cell_max_lat = lat_bins[i+1]
                
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
    
    # Compute an adaptive axis-aligned rectangle feature
    try:
        bounds = _compute_interval_bounds(prob_grid, lon_bins, lat_bins, threshold=threshold, v2_hull_points=v2_hull_points)
        if bounds is None:
            if v2_hull_points is not None:
                print(f"  ⚠️  Interval {interval_label}: no hull-constrained rectangle exists that fully contains all selected cells; skipping bounding box")
            else:
                print(f"  ⚠️  Interval {interval_label}: no enclosing rectangle found; skipping bounding box")
            features = grid_features
            geojson = {
                "type": "FeatureCollection",
                "properties": {
                    "interval": interval_label,
                    "points_included": points_included,
                    "max_probability": round(float(max_prob), 4),
                    "total_probability": round(float(total_probability), 6),
                    "retained_probability": round(float(retained_prob), 6),
                    "retained_probability_percent": round(float(retained_prob / total_probability * 100.0) if total_probability > 0 else 0.0, 2),
                    "total_cells": int(total_cells),
                    "retained_cells": int(retained_cells_count),
                    "bbox_status": "skipped"
                },
                "features": features
            }
            return geojson

        min_lon, max_lon, min_lat, max_lat = bounds
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
                "max_probability": round(float(max_prob), 4),
                "total_probability": round(float(total_probability), 6),
                "retained_probability": round(float(retained_prob), 6),
                "retained_probability_percent": round(float(retained_prob / total_probability * 100.0) if total_probability > 0 else 0.0, 2),
                "total_cells": int(total_cells),
                "retained_cells": int(retained_cells_count)
            },
            "features": features
        }
        
        return geojson
    
    except Exception as e:
        print(f"  ✗ Error computing rectangle for {interval_label}: {e}")
        return None


def create_grid_geojson(prob_grid, lon_bins, lat_bins, interval_label, threshold=CUMULATIVE_PROBABILITY_THRESHOLD):
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
    
    retained_mask, total_probability, retained_prob, total_cells, retained_cells_count = _filter_prob_grid_for_footprint(
        prob_grid,
        threshold=threshold,
        lon_bins=lon_bins,
        lat_bins=lat_bins,
        v2_hull_points=None,
    )
    if retained_mask is None:
        retained_mask = np.zeros_like(prob_grid, dtype=bool)
        total_probability = float(np.sum(prob_grid)) if prob_grid is not None else 0.0
        retained_prob = 0.0
        total_cells = int(np.prod(prob_grid.shape)) if prob_grid is not None else 0
        retained_cells_count = 0

    # Calculate max probability for normalization
    max_prob = np.max(prob_grid) if np.max(prob_grid) > 0 else 1.0
    
    for i in range(prob_grid.shape[0]):  # lat dimension
        for j in range(prob_grid.shape[1]):  # lon dimension
            prob = prob_grid[i, j]
            
            # Normalize probability (0–1 scale)
            norm_prob = prob / max_prob if max_prob > 0 else 0
            
            # Use cumulative-probability footprint selection instead of a fixed normalized threshold
            if not retained_mask[i, j]:
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
                                 target_arrows=12, v2_hull_points=None):
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
        # Derive an adaptive bbox from the interval footprint
        # ----------------------------------------------------------
        bbox = {"min_lon": None, "max_lon": None, "min_lat": None, "max_lat": None}
        if idx < len(prob_grids):
            pg = prob_grids[idx]
            bounds = _compute_interval_bounds(pg, lon_bins, lat_bins, threshold=CUMULATIVE_PROBABILITY_THRESHOLD, v2_hull_points=v2_hull_points)
            if bounds is not None:
                bbox["min_lon"], bbox["max_lon"], bbox["min_lat"], bbox["max_lat"] = bounds

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
