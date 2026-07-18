# V3 Rectangle Geometry Update

## Goal
We improved the V3 rectangle generation so the rectangle is smaller, more accurate, and driven by the same probability footprint used by the visualization outputs.

## What changed

### 1. Rectangle logic became geometry-based and hull-aware
The rectangle is now computed as a strict minimum axis-aligned rectangle that:
- fully contains the selected interval cells,
- stays inside the V2 hull when a hull is available,
- avoids the earlier overlap-based heuristic that could make the box too large.

### 2. Footprint selection moved to cumulative probability
Instead of relying on a fixed raw threshold or a loose overlap rule, the retained footprint is now selected by cumulative probability.
- Default threshold: 0.95
- The retained cells are the smallest set whose cumulative probability reaches about 95% of the interval total.
- This removes the low-probability tail that was inflating the rectangle.

### 3. The same footprint is used everywhere
The shared logic now feeds the same retained cells into:
- rectangle fitting,
- GeoJSON cell generation,
- current-vector bounding box generation.

### 4. Per-interval logging was added
The pipeline now prints the retained footprint summary for each interval, including:
- selected cell count,
- retained probability percentage.

## Files involved
- sarat_new_visualization_changes/geojson_utils.py
- sarat_new_visualization_changes/saratv3visuals.py
- sarat_new_visualization_changes/sarat_visuals.py
- sarat_new_visualization_changes/tests/test_v3_rectangle_geometry.py

## Verification
We verified the change with the rectangle regression tests:
- 3 tests ran
- Result: all passed

We also reran the case generation pipeline for case 6687 and saw interval summaries such as:
- Interval 0-12h: selected cells=5, retained probability=97.2%
- Interval 12-24h: selected cells=5, retained probability=92.9%
- Interval 24-36h: selected cells=6, retained probability=95.0%

## Result
The rectangle is now smaller and more faithful to the meaningful footprint, while still respecting the V2 hull and the retained probability mass.

## Note
The full PNG rendering stage still depends on Cartopy in the environment. The geometry and GeoJSON generation work completed successfully, but the final plotting step requires that dependency to be installed.
