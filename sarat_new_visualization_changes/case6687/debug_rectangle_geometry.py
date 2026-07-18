import json
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

CASE_DIR = Path(__file__).resolve().parent
GEOJSON_PATH = CASE_DIR / "interval_005_6687.geojson"
HULL_PATH = CASE_DIR / "finalconvexhull_6687.dat"
OUT_PATH = CASE_DIR / "debug_rectangle_geometry.png"


def load_hull(path: Path) -> np.ndarray:
    data = np.loadtxt(path)
    if data.ndim == 1:
        data = data.reshape(1, -1)
    return data


def point_in_polygon(point, polygon):
    polygon = np.asarray(polygon, dtype=float)
    if polygon.shape[0] < 3:
        return False

    x, y = point
    inside = False
    n = len(polygon)
    for i in range(n):
        x1, y1 = polygon[i]
        x2, y2 = polygon[(i + 1) % n]
        if ((y1 > y) != (y2 > y)):
            xinters = (x2 - x1) * (y - y1) / (y2 - y1) + x1
            if x < xinters:
                inside = not inside

    if not inside:
        return False

    for i in range(n):
        x1, y1 = polygon[i]
        x2, y2 = polygon[(i + 1) % n]
        cross = (x2 - x1) * (y - y1) - (y2 - y1) * (x - x1)
        if abs(cross) < 1e-12:
            if min(x1, x2) - 1e-12 <= x <= max(x1, x2) + 1e-12 and min(y1, y2) - 1e-12 <= y <= max(y1, y2) + 1e-12:
                return True

    return True


def polygon_within_polygon(subject, clipper):
    return all(point_in_polygon(point, clipper) for point in subject)


def load_interval_geojson(path: Path):
    data = json.loads(path.read_text())
    bbox_feature = None
    selected_cells = []
    for feat in data.get("features", []):
        props = feat.get("properties", {})
        feat_type = props.get("type")
        if feat_type == "bounding_box":
            bbox_feature = feat
        elif feat_type == "grid_cell":
            coords = feat.get("geometry", {}).get("coordinates", [[]])[0]
            lons = [p[0] for p in coords]
            lats = [p[1] for p in coords]
            selected_cells.append((min(lons), max(lons), min(lats), max(lats)))
    return bbox_feature, selected_cells


def compute_smallest_hull_contained_rect(cells, hull):
    hull_poly = np.asarray(hull, dtype=float)
    candidate_xs = [float(np.min(hull_poly[:, 0])), float(np.max(hull_poly[:, 0]))]
    candidate_ys = [float(np.min(hull_poly[:, 1])), float(np.max(hull_poly[:, 1]))]
    for min_lon, max_lon, min_lat, max_lat in cells:
        candidate_xs.extend([float(min_lon), float(max_lon)])
        candidate_ys.extend([float(min_lat), float(max_lat)])
    candidate_xs = sorted(set(candidate_xs))
    candidate_ys = sorted(set(candidate_ys))

    best = None
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
                    rect_points = np.asarray([
                        [x1, y1],
                        [x2, y1],
                        [x2, y2],
                        [x1, y2],
                        [x1, y1],
                    ], dtype=float)
                    if not polygon_within_polygon(rect_points, hull_poly):
                        continue
                    if not all(x1 <= cell[0] and x2 >= cell[1] and y1 <= cell[2] and y2 >= cell[3] for cell in cells):
                        continue
                    area = (x2 - x1) * (y2 - y1)
                    if best is None or area < best_area:
                        best = (x1, x2, y1, y2)
                        best_area = area
    return best, best_area


def main():
    hull = load_hull(HULL_PATH)
    bbox_feature, selected_cells = load_interval_geojson(GEOJSON_PATH)
    coords = bbox_feature["geometry"]["coordinates"][0]
    current_rect = [
        [coords[0][0], coords[0][1]],
        [coords[1][0], coords[1][1]],
        [coords[2][0], coords[2][1]],
        [coords[3][0], coords[3][1]],
        [coords[4][0], coords[4][1]],
    ]

    print("Current rectangle coordinates from interval_005_6687.geojson:")
    for point in current_rect:
        print(point)
    print()

    print("Interval cells used to generate the rectangle:")
    for idx, cell in enumerate(selected_cells):
        print(idx, cell)
    print()

    smallest_rect, smallest_area = compute_smallest_hull_contained_rect(selected_cells, hull)
    print("Smallest hull-contained axis-aligned rectangle that contains all selected cells:")
    if smallest_rect is None:
        print("None")
    else:
        x1, x2, y1, y2 = smallest_rect
        print([x1, x2, y1, y2])
        print("area", smallest_area)

    fig, ax = plt.subplots(figsize=(8, 8))
    ax.plot(hull[:, 0], hull[:, 1], color="black", linewidth=2, label="V2 hull")
    ax.fill(hull[:, 0], hull[:, 1], color="lightgray", alpha=0.25)

    for idx, cell in enumerate(selected_cells):
        min_lon, max_lon, min_lat, max_lat = cell
        poly = np.array([
            [min_lon, min_lat],
            [max_lon, min_lat],
            [max_lon, max_lat],
            [min_lon, max_lat],
            [min_lon, min_lat],
        ], dtype=float)
        ax.plot(poly[:, 0], poly[:, 1], color="tab:blue", linewidth=0.7, alpha=0.5)
        ax.fill(poly[:, 0], poly[:, 1], color="tab:blue", alpha=0.12)

    current_lons = [p[0] for p in current_rect[:-1]]
    current_lats = [p[1] for p in current_rect[:-1]]
    ax.add_patch(plt.Rectangle((min(current_lons), min(current_lats)), max(current_lons) - min(current_lons), max(current_lats) - min(current_lats), fill=False, edgecolor="royalblue", linewidth=2, label="current rectangle"))

    if smallest_rect is not None:
        x1, x2, y1, y2 = smallest_rect
        ax.add_patch(plt.Rectangle((x1, y1), x2 - x1, y2 - y1, fill=False, edgecolor="red", linewidth=2, linestyle="--", label="smallest containing rectangle"))

    ax.set_title("Interval 005: cells, V2 hull, and computed rectangle")
    ax.set_xlabel("longitude")
    ax.set_ylabel("latitude")
    ax.set_aspect("equal")
    ax.legend(loc="upper left")
    fig.tight_layout()
    fig.savefig(OUT_PATH, dpi=200)
    print(f"Saved debug plot to {OUT_PATH}")


if __name__ == "__main__":
    main()
