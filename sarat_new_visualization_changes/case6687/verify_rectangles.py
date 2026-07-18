import json
import glob
from pathlib import Path
import numpy as np

hull = np.loadtxt('finalconvexhull_6687.dat')

def pip(pt):
    x, y = pt
    inside = False
    n = len(hull)
    for i in range(n):
        xi, yi = hull[i]
        xj, yj = hull[(i + 1) % n]
        if ((yi > y) != (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi):
            inside = not inside
    return inside

for interval_file in sorted(glob.glob('interval_*_6687.geojson')):
    data = json.loads(Path(interval_file).read_text())
    new_box = None
    for feat in data['features']:
        props = feat.get('properties', {})
        if props.get('type') == 'bounding_box':
            new_box = feat['geometry']['coordinates'][0]
            break
    if new_box is None:
        continue
    box_points = [(p[0], p[1]) for p in new_box[:-1]]
    print(interval_file, 'box_inside_hull=', all(pip(p) for p in box_points), 'bbox=', [tuple([round(q, 6) for q in p]) for p in new_box[:-1]])
