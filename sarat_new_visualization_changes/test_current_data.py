import xarray as xr
import numpy as np
import os

base_path = os.path.dirname(os.path.abspath(__file__))
nc_dir = os.path.join(os.path.dirname(base_path), "currentsncfiles_addedlater")
nc_path = os.path.join(nc_dir, "Current_6687.nc")

print("Checking NC file:", nc_path)
if not os.path.exists(nc_path):
    print("NC file does not exist!")
    exit(1)

ds = xr.open_dataset(nc_path)
print("Data vars:", list(ds.data_vars))
print("Coords:", list(ds.coords))

lon = ds['LON'].values
lat = ds['LAT'].values
print(f"Lon shape: {lon.shape}, Lat shape: {lat.shape}")
print(f"Lon range: {lon.min()} to {lon.max()}")
print(f"Lat range: {lat.min()} to {lat.max()}")

u_name = list(ds.data_vars)[0]
v_name = list(ds.data_vars)[1]
u = ds[u_name].values
v = ds[v_name].values
print(f"U shape: {u.shape}, V shape: {v.shape}")

# Sample a slice for first time step
u_t0 = u[0]
if u_t0.ndim == 3:
    u_t0 = u_t0[0]  # squeeze depth if present

# Let's count non-nans globally
non_nan_count = np.sum(~np.isnan(u_t0))
total_count = u_t0.size
print(f"Globally at t=0: {non_nan_count} non-NaN cells out of {total_count} ({non_nan_count/total_count*100:.1f}%)")

# Let's check region around LKP: lon=[68.8, 71.2], lat=[21.8, 23.1]
min_lon, max_lon = 68.8, 71.2
min_lat, max_lat = 21.8, 23.1

lon_mask = (lon >= min_lon) & (lon <= max_lon)
lat_mask = (lat >= min_lat) & (lat <= max_lat)

lon_sub = lon[lon_mask]
lat_sub = lat[lat_mask]
u_sub = u_t0[np.ix_(np.where(lat_mask)[0], np.where(lon_mask)[0])]

sub_non_nan = np.sum(~np.isnan(u_sub))
sub_total = u_sub.size
print(f"In map extent: {sub_non_nan} non-NaN cells out of {sub_total} ({sub_non_nan/sub_total*100:.1f}%)")
print(f"Sub-extent shape: {u_sub.shape}")
print("Sub-extent lon array length:", len(lon_sub))
print("Sub-extent lat array length:", len(lat_sub))
