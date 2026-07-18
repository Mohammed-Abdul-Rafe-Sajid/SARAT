import os
import sys
import unittest

import numpy as np

sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from geojson_utils import create_hull_geojson, _compute_interval_bounds


class V3RectangleGeometryTest(unittest.TestCase):
    def test_rectangle_stays_within_v2_hull(self):
        prob_grid = np.array([
            [0.0, 0.0, 0.0],
            [0.0, 0.2, 0.0],
            [0.0, 0.0, 0.3],
        ], dtype=float)
        lon_bins = np.array([0.0, 1.0, 2.0, 3.0], dtype=float)
        lat_bins = np.array([0.0, 1.0, 2.0, 3.0], dtype=float)

        v2_hull_points = np.array([
            [0.0, 0.0],
            [3.0, 0.0],
            [3.0, 3.0],
            [0.0, 3.0],
        ], dtype=float)

        geojson = create_hull_geojson(
            prob_grid,
            lon_bins,
            lat_bins,
            "0-12h",
            threshold=0.05,
            v2_hull_points=v2_hull_points,
        )

        self.assertIsNotNone(geojson)
        self.assertGreaterEqual(len(geojson["features"]), 1)

        rect_coords = geojson["features"][0]["geometry"]["coordinates"][0]
        lons = [point[0] for point in rect_coords]
        lats = [point[1] for point in rect_coords]

        self.assertGreaterEqual(min(lons), -1e-9)
        self.assertLessEqual(max(lons), 3.0 + 1e-9)
        self.assertGreaterEqual(min(lats), -1e-9)
        self.assertLessEqual(max(lats), 3.0 + 1e-9)

    def test_diagonal_footprint_fits_inside_non_rectangular_hull(self):
        prob_grid = np.array([
            [0.2, 0.0],
            [0.0, 0.2],
        ], dtype=float)
        lon_bins = np.array([0.0, 1.0, 2.0], dtype=float)
        lat_bins = np.array([0.0, 1.0, 2.0], dtype=float)

        v2_hull_points = np.array([
            [0.0, 0.0],
            [2.0, 0.0],
            [1.0, 2.0],
        ], dtype=float)

        bounds = _compute_interval_bounds(
            prob_grid,
            lon_bins,
            lat_bins,
            threshold=0.05,
            v2_hull_points=v2_hull_points,
        )

        self.assertIsNone(bounds)

    def test_true_minimum_rectangle_contains_all_selected_cells(self):
        prob_grid = np.array([
            [0.2],
            [0.2],
        ], dtype=float)
        lon_bins = np.array([0.0, 1.0], dtype=float)
        lat_bins = np.array([0.0, 1.0, 2.0], dtype=float)

        v2_hull_points = np.array([
            [0.0, 0.0],
            [1.0, 0.0],
            [1.0, 2.0],
            [0.0, 2.0],
        ], dtype=float)

        bounds = _compute_interval_bounds(
            prob_grid,
            lon_bins,
            lat_bins,
            threshold=0.05,
            v2_hull_points=v2_hull_points,
        )

        self.assertIsNotNone(bounds)
        self.assertEqual(bounds, [0.0, 1.0, 0.0, 2.0])


if __name__ == "__main__":
    unittest.main()
