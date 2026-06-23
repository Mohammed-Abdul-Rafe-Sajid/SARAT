#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
wind_utils.py  Wind / Current Direction Utility for SARAT v3
=============================================================
Extracts period-averaged ocean-current (or wind) fields from
Current_{id}.nc files and renders them as a quiver field
spread across the entire map extent of each period subplot.

Approach
--------
For each interval (e.g. 0-12 h):
  1. Sample U (CU) and V (CV) every SAMPLE_STEP hours within [start, end)
     e.g. for 0-12h with step=4 -> indices 0, 4, 8 -> V1, V2, V3
  2. Vector-average the sampled 2-D fields:
         U_2d_avg = mean(U_2d[0], U_2d[4], U_2d[8])
         V_2d_avg = mean(V_2d[0], V_2d[4], V_2d[8])
  3. Store the full 2-D averaged arrays alongside the scalar
     LKP-representative speed / direction.
  4. During plotting, subset the 2-D field to the map extent and
     draw a regular quiver grid spread across the whole panel.

NC file naming: Current_{case_id}.nc  in  currentsncfiles_addedlater/
Variables     : CU (eastward), CV (northward),  shape (T, 1, LAT, LON)
"""

import numpy as np
import xarray as xr
import os


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

CURRENT_NC_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "currentsncfiles_addedlater"
)

SAMPLE_STEP_HOURS  = 4      # sample at h=0, 4, 8 within each period
SPATIAL_RADIUS_DEG = 1.0    # fallback search radius for LKP scalar
MIN_VALID_FRACTION = 0.10   # fraction of time steps that must be non-NaN

# Quiver display settings
QUIVER_STRIDE     = None    # None triggers dynamic stride calculation
QUIVER_SCALE      = 15      # ax.quiver scale (larger = shorter arrows, default without scale_units)
QUIVER_WIDTH      = 0.003   # arrow shaft width
REF_VECTOR_SPEED  = 0.5     # m/s for the reference key arrow


# ---------------------------------------------------------------------------
# Loader
# ---------------------------------------------------------------------------

def load_current_nc(case_id, nc_dir=None):
    """
    Open Current_{case_id}.nc and return hourly-resampled dataset.

    Returns
    -------
    ds_hourly, ds_raw   or   None, None if file not found.
    """
    if nc_dir is None:
        nc_dir = CURRENT_NC_DIR

    nc_path = os.path.join(nc_dir, f"Current_{case_id}.nc")
    if not os.path.exists(nc_path):
        print(f"  [wind_utils] WARNING: NC file not found -> {nc_path}")
        return None, None

    ds_raw    = xr.open_dataset(nc_path)
    ds_hourly = ds_raw.resample(TAXNEW='1h').interpolate('linear')
    print(f"  [wind_utils] Loaded {os.path.basename(nc_path)}: "
          f"{len(ds_raw.TAXNEW)} steps -> {len(ds_hourly.TAXNEW)} hourly steps")
    return ds_hourly, ds_raw


# ---------------------------------------------------------------------------
# LKP scalar helper  (for speed/direction label only)
# ---------------------------------------------------------------------------

def _extract_uv_at_location(cu_3d, cv_3d, lon_arr, lat_arr,
                             lkp_lon, lkp_lat,
                             radius_deg=SPATIAL_RADIUS_DEG):
    """Return U/V time-series at (lkp_lon, lkp_lat), with spatial fallback."""
    T = cu_3d.shape[0]

    lon_idx = int(np.abs(lon_arr - lkp_lon).argmin())
    lat_idx = int(np.abs(lat_arr - lkp_lat).argmin())

    u_ts = cu_3d[:, lat_idx, lon_idx].copy()
    v_ts = cv_3d[:, lat_idx, lon_idx].copy()

    valid_u = np.sum(~np.isnan(u_ts)) / T
    valid_v = np.sum(~np.isnan(v_ts)) / T

    if valid_u >= MIN_VALID_FRACTION and valid_v >= MIN_VALID_FRACTION:
        return u_ts, v_ts

    # Spatial fallback
    print(f"  [wind_utils] Nearest cell mostly NaN; using {radius_deg} deg avg")
    lon_mask = np.abs(lon_arr - lkp_lon) <= radius_deg
    lat_mask = np.abs(lat_arr - lkp_lat) <= radius_deg
    li = np.where(lat_mask)[0]
    lo = np.where(lon_mask)[0]
    sub_u = cu_3d[np.ix_(range(T), li, lo)]
    sub_v = cv_3d[np.ix_(range(T), li, lo)]
    u_ts  = np.nanmean(sub_u.reshape(T, -1), axis=1)
    v_ts  = np.nanmean(sub_v.reshape(T, -1), axis=1)
    return u_ts, v_ts


# ---------------------------------------------------------------------------
# Compass helper
# ---------------------------------------------------------------------------

def _compass_label(deg):
    if np.isnan(deg):
        return 'N/A'
    dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW']
    return dirs[int(round(deg / 45)) % 8]


def _empty_wind_info(interval):
    return {
        'interval'  : interval,
        'u_avg'     : np.nan,
        'v_avg'     : np.nan,
        'speed'     : np.nan,
        'dir_to'    : np.nan,
        'dir_from'  : np.nan,
        'dir_label' : 'N/A',
        'n_samples' : 0,
        'valid'     : False,
        'u_field_2d': None,
        'v_field_2d': None,
        'lon_arr'   : None,
        'lat_arr'   : None,
    }


# ---------------------------------------------------------------------------
# Main computation
# ---------------------------------------------------------------------------

def compute_interval_wind(ds_hourly, lkp_lon, lkp_lat, intervals,
                           sample_step=SAMPLE_STEP_HOURS,
                           radius_deg=SPATIAL_RADIUS_DEG):
    """
    For each interval, compute:
      - Scalar speed / direction at LKP (for the text label)
      - 2-D period-averaged U/V field (for the full quiver plot)

    Returns
    -------
    wind_info : list of dicts (one per interval)
    """
    if ds_hourly is None:
        return [_empty_wind_info(iv) for iv in intervals]

    u_name = list(ds_hourly.data_vars)[0]
    v_name = list(ds_hourly.data_vars)[1]

    u_arr = ds_hourly[u_name].values
    v_arr = ds_hourly[v_name].values

    # Squeeze singleton depth dim
    if u_arr.ndim == 4 and u_arr.shape[1] < 10:
        u_arr = u_arr[:, 0, :, :]
        v_arr = v_arr[:, 0, :, :]

    lon_arr = ds_hourly['LON'].values
    lat_arr = ds_hourly['LAT'].values
    T       = u_arr.shape[0]

    # LKP time-series for scalar representative value
    u_ts, v_ts = _extract_uv_at_location(
        u_arr, v_arr, lon_arr, lat_arr, lkp_lon, lkp_lat, radius_deg
    )

    wind_info = []
    for (start, end) in intervals:
        # ── Sample indices ────────────────────────────────────────────
        sidx = [i for i in range(start, end, sample_step) if i < T]
        if not sidx:
            wind_info.append(_empty_wind_info((start, end)))
            continue

        # ── Scalar (LKP representative) ───────────────────────────────
        u_avg = float(np.nanmean(u_ts[sidx]))
        v_avg = float(np.nanmean(v_ts[sidx]))

        if np.isnan(u_avg) or np.isnan(v_avg):
            wind_info.append(_empty_wind_info((start, end)))
            continue

        speed    = float(np.sqrt(u_avg**2 + v_avg**2))
        dir_to   = float(np.degrees(np.arctan2(u_avg, v_avg)) % 360)
        dir_from = float((dir_to + 180) % 360)

        # ── 2-D period-averaged field ─────────────────────────────────
        # Average over sample time steps; shape (lat, lon)
        u_field_2d = np.nanmean(u_arr[sidx, :, :], axis=0)
        v_field_2d = np.nanmean(v_arr[sidx, :, :], axis=0)

        wind_info.append({
            'interval'  : (start, end),
            'u_avg'     : u_avg,
            'v_avg'     : v_avg,
            'speed'     : speed,
            'dir_to'    : dir_to,
            'dir_from'  : dir_from,
            'dir_label' : _compass_label(dir_to),
            'n_samples' : len(sidx),
            'valid'     : True,
            # 2-D field for full quiver
            'u_field_2d': u_field_2d,
            'v_field_2d': v_field_2d,
            'lon_arr'   : lon_arr,
            'lat_arr'   : lat_arr,
        })

        print(f"  [wind_utils] {start}-{end}h | "
              f"U={u_avg:.3f} V={v_avg:.3f} m/s | "
              f"spd={speed:.3f} m/s | {_compass_label(dir_to)} ({dir_to:.1f} deg)")

    return wind_info


# ---------------------------------------------------------------------------
# Quiver field plotter
# ---------------------------------------------------------------------------

def annotate_wind_on_ax(ax, winfo, ax_extent, transform,
                         arrow_color='black',
                         text_color='black',
                         stride=QUIVER_STRIDE,
                         quiver_scale=QUIVER_SCALE,
                         ref_speed=REF_VECTOR_SPEED,
                         label_prefix='Current'):
    """
    Plot a quiver field of period-averaged current/wind vectors spread
    across the entire map extent, plus a reference-speed key arrow.

    Parameters
    ----------
    ax           : Cartopy GeoAxes
    winfo        : dict from compute_interval_wind (one entry)
    ax_extent    : [min_lon, max_lon, min_lat, max_lat]
    transform    : ccrs.PlateCarree()
    arrow_color  : colour for arrows (default 'black')
    stride       : thin the grid by this factor (default None for dynamic calculation)
    quiver_scale : ax.quiver scale parameter (larger = shorter arrows)
    ref_speed    : speed of the reference arrow key (m/s)
    label_prefix : prefix for the ref-key label ('Current' or 'Wind')
    """
    if not winfo.get('valid', False):
        return

    u_2d    = winfo.get('u_field_2d')
    v_2d    = winfo.get('v_field_2d')
    lon_arr = winfo.get('lon_arr')
    lat_arr = winfo.get('lat_arr')

    if u_2d is None or lon_arr is None:
        return

    min_lon, max_lon, min_lat, max_lat = ax_extent

    # ── Subset to map extent ──────────────────────────────────────────
    lon_mask = (lon_arr >= min_lon) & (lon_arr <= max_lon)
    lat_mask = (lat_arr >= min_lat) & (lat_arr <= max_lat)

    lon_sub = lon_arr[lon_mask]
    lat_sub = lat_arr[lat_mask]
    u_sub   = u_2d[np.ix_(np.where(lat_mask)[0], np.where(lon_mask)[0])]
    v_sub   = v_2d[np.ix_(np.where(lat_mask)[0], np.where(lon_mask)[0])]

    if lon_sub.size == 0 or lat_sub.size == 0:
        return

    # ── Thin by stride dynamically if not specified ───────────────────
    if stride is None:
        # Target about 12-15 grid points along each axis to spread them nicely
        stride_lon = max(1, lon_sub.size // 12)
        stride_lat = max(1, lat_sub.size // 12)
    else:
        stride_lon = stride
        stride_lat = stride

    lon_thin = lon_sub[::stride_lon]
    lat_thin = lat_sub[::stride_lat]
    u_thin   = u_sub[::stride_lat, ::stride_lon]
    v_thin   = v_sub[::stride_lat, ::stride_lon]

    # Build mesh grids
    lon_grid, lat_grid = np.meshgrid(lon_thin, lat_thin)

    # ── Normalise to unit vectors so arrows are always visible ────────
    # (Uniform-length arrows clearly show DIRECTION across the whole map.
    #  The reference speed key tells the user the typical magnitude.)
    mag = np.sqrt(u_thin**2 + v_thin**2)
    
    # Mask out coordinates where magnitude is NaN or <= 1e-9 (land / invalid)
    valid_mask = (mag > 1e-9) & (~np.isnan(mag))
    
    if not np.any(valid_mask):
        return

    lon_grid_flat = lon_grid[valid_mask]
    lat_grid_flat = lat_grid[valid_mask]
    
    with np.errstate(invalid='ignore', divide='ignore'):
        u_norm = u_thin[valid_mask] / mag[valid_mask]
        v_norm = v_thin[valid_mask] / mag[valid_mask]

    # ── Plot quiver field ─────────────────────────────────────────────
    q = ax.quiver(
        lon_grid_flat, lat_grid_flat,
        u_norm,        v_norm,
        transform  = transform,
        color      = arrow_color,
        scale      = quiver_scale,
        width      = 0.003,
        headwidth  = 4,
        headlength = 5,
        zorder     = 6,
        alpha      = 0.80,
    )

    # ── Reference-speed key (upper-left, inside axes) ─────────────────
    # Use the LKP scalar speed for the representative label
    lkp_speed = winfo.get('speed', ref_speed)
    key_label  = f'{lkp_speed:.2f} m/s (LKP avg)'

    ax.quiverkey(
        q,
        X            = 0.10,    # axes-fraction from left
        Y            = 0.93,    # axes-fraction from bottom
        U            = 1.0,     # matches normalised unit vectors
        label        = key_label,
        labelpos     = 'E',
        fontproperties = {'size': 6, 'weight': 'bold'},
        color        = arrow_color,
        zorder       = 7,
    )



# ---------------------------------------------------------------------------
# Convenience one-call API
# ---------------------------------------------------------------------------

def get_wind_info_for_case(case_id, lkp_lon, lkp_lat, intervals,
                            nc_dir=None,
                            sample_step=SAMPLE_STEP_HOURS):
    """
    Load NC, compute per-interval wind/current info.

    Returns  list of dicts or None.
    """
    ds_hourly, ds_raw = load_current_nc(case_id, nc_dir)
    if ds_hourly is None:
        return None

    wind_info = compute_interval_wind(
        ds_hourly, lkp_lon, lkp_lat, intervals,
        sample_step=sample_step
    )

    if ds_raw is not None:
        ds_raw.close()

    return wind_info


# ---------------------------------------------------------------------------
# Standalone test
# ---------------------------------------------------------------------------

if __name__ == '__main__':
    import sys

    case_id = int(sys.argv[1])   if len(sys.argv) > 1 else 6687
    lkp_lon = float(sys.argv[2]) if len(sys.argv) > 2 else 69.833
    lkp_lat = float(sys.argv[3]) if len(sys.argv) > 3 else 22.581

    test_intervals = [(i, i + 12) for i in range(0, 72, 12)]

    print(f"\n=== Wind/Current extraction  case {case_id} ===")
    print(f"    LKP lon={lkp_lon}  lat={lkp_lat}")
    print(f"    Intervals: {test_intervals}\n")

    wind_info = get_wind_info_for_case(case_id, lkp_lon, lkp_lat, test_intervals)

    if wind_info:
        print(f"\n{'Interval':>12}  {'Speed':>8}  {'Dir_to':>8}  Label  2D_field")
        print("-" * 60)
        for w in wind_info:
            s, e = w['interval']
            has_2d = w['u_field_2d'] is not None
            if w['valid']:
                print(f"  {s:>3}-{e:<3}h  "
                      f"{w['speed']:>8.4f}  {w['dir_to']:>8.1f}  "
                      f"{w['dir_label']:>4}  {'yes' if has_2d else 'no'}")
            else:
                print(f"  {s:>3}-{e:<3}h  {'N/A':>8}")
