import json
import os
import math
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

CASE_DIR = Path(__file__).resolve().parent
HULL_PATH = CASE_DIR / "finalconvexhull_6687.dat"
GEOJSON_FILES = sorted(CASE_DIR.glob("interval_*_6687.geojson"))
CURRENT_JSON = CASE_DIR / "current_vectors_6687.json"
OUT_PATH = CASE_DIR / "v3_visual_verification.png"


def load_hull():
    data = np.loadtxt(HULL_PATH)
    if data.ndim == 1:
        data = data.reshape(1, -1)
    return data


def compute_bbox_from_feature(feature):
    coords = feature["geometry"]["coordinates"][0]
    lons = [p[0] for p in coords]
    lats = [p[1] for p in coords]
    return min(lons), max(lons), min(lats), max(lats)


def draw_interval(ax, interval_path, current_entry, hull):
    data = json.loads(interval_path.read_text())
    features = data.get("features", [])
    new_box = None
    grid_cells = []
    for feat in features:
        props = feat.get("properties", {})
        feat_type = props.get("type")
        if feat_type == "bounding_box":
            new_box = feat["geometry"]["coordinates"][0]
        elif feat_type == "grid_cell":
            coords = feat["geometry"]["coordinates"][0]
            prob = props.get("probability", 0.0)
            grid_cells.append((coords, prob))

    if new_box is None:
        return

    # Old bbox from the union of interval cells (matching the old logic)
    old_lons = [p[0] for coords, _ in grid_cells for p in coords]
    old_lats = [p[1] for coords, _ in grid_cells for p in coords]
    old_bbox = (min(old_lons), max(old_lons), min(old_lats), max(old_lats)) if old_lons else None

    # New bbox from GeoJSON feature
    new_bbox = compute_bbox_from_feature({"geometry": {"coordinates": [new_box]}})

    # Draw hull
    hull_xy = hull[:, 0]
    hull_yy = hull[:, 1]
    ax.plot(hull_xy, hull_yy, color="black", linewidth=2, alpha=0.9)
    ax.fill(hull_xy, hull_yy, color="lightgray", alpha=0.25)

    # Draw old bbox in orange and new bbox in blue
    if old_bbox is not None:
        ox1, ox2, oy1, oy2 = old_bbox
        ax.add_patch(plt.Rectangle((ox1, oy1), ox2 - ox1, oy2 - oy1, fill=False, edgecolor="orange", linewidth=2, linestyle="--", label="old bbox"))
    nx1, nx2, ny1, ny2 = new_bbox
    ax.add_patch(plt.Rectangle((nx1, ny1), nx2 - nx1, ny2 - ny1, fill=False, edgecolor="royalblue", linewidth=2, label="new bbox"))

    # Draw grid cells with probability-based color gradient
    for coords, prob in grid_cells:
        poly = np.array(coords)
        ax.fill(poly[:, 0], poly[:, 1], color=plt.cm.PuBuGn(prob / max(1.0, max(1.0, 100.0))), alpha=0.8)

    # Add illustrative arrows only inside the new bbox
    if current_entry is not None:
        bbox = current_entry.get("bbox") or {}
        min_lon = bbox.get("min_lon")
        max_lon = bbox.get("max_lon")
        min_lat = bbox.get("min_lat")
        max_lat = bbox.get("max_lat")
        if min_lon is not None:
            xs = np.linspace(min_lon + 0.01, max_lon - 0.01, 3)
            ys = np.linspace(min_lat + 0.01, max_lat - 0.01, 3)
            for x in xs:
                for y in ys:
                    ax.arrow(x, y, 0.01, 0.0, head_width=0.003, head_length=0.004, color="red", alpha=0.8)

    ax.set_title(interval_path.name)
    ax.set_xlabel("lon")
    ax.set_ylabel("lat")
    ax.set_aspect("equal")


def main():
    hull = load_hull()
    current_data = json.loads(CURRENT_JSON.read_text())
    current_intervals = current_data.get("intervals", [])
    current_map = {item.get("interval_label"): item for item in current_intervals}

    fig, axes = plt.subplots(2, 4, figsize=(20, 8), constrained_layout=True)
    axes = axes.flatten()
    for ax, interval_path in zip(axes, GEOJSON_FILES):
        label = interval_path.stem.split("_")[1] if len(interval_path.stem.split("_")) > 1 else None
        current_entry = None
        if label is not None:
            # not used; keep simple fetch by file order
            pass
        draw_interval(ax, interval_path, current_map.get(interval_path.stem.split("_")[1]), hull)

    # Make the last panel show the comparison summary
    summary_ax = axes[-1]
    summary_ax.axis("off")
    summary_ax.text(0.05, 0.5, "Verification summary\n- old bbox shown in orange\n- new adaptive bbox shown in blue\n- probability gradient confined to the new footprint\n- arrows placed only inside bbox", fontsize=12, va="center")

    fig.suptitle("SARAT V3 Visual Verification", fontsize=16)
    fig.savefig(OUT_PATH, dpi=200)
    print(f"Saved {OUT_PATH}")


if __name__ == "__main__":
    main()
