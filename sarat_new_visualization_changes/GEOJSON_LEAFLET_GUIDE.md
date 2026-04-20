# 🗺️ SARAT v3 GeoJSON + Leaflet Interactive Map

## Overview

This system generates **interval-wise probability GeoJSON files** from SARAT analysis and provides an **interactive Leaflet map** for visualization and analysis.

### ✨ Features

- ✅ **Automated GeoJSON Generation** — Each time interval gets its own GeoJSON file
- ✅ **Interactive Leaflet Map** — Web-based visualization with OpenStreetMap tiles
- ✅ **Interval Controls** — Toggle between time intervals with buttons or slider
- ✅ **Probability-based Colors** — Grid cells color-coded by probability percentage
- ✅ **Popup Info** — Click any point to see detailed probability data
- ✅ **Responsive Design** — Works on desktop and mobile devices

---

## 🚀 Quick Start

### Step 1: Run SARAT Analysis

Execute your analysis script as usual:

```bash
python saratv3visuals.py
```

**What happens:**
- SARAT runs the analysis
- `prob_grids` are computed for each interval
- GeoJSON files are generated automatically
- GeoJSON index is created

### Step 2: Open the Map

Navigate to the output directory:

```bash
cd case6687/figure/
```

Open the map in a web browser:

```bash
# Option A: Double-click map.html
# Option B: Use Python's built-in server
python -m http.server 8000
# Then visit http://localhost:8000/map.html
```

---

## 📂 Generated Files

### GeoJSON Files

Each interval produces a GeoJSON file:

```
interval_000_000_024.geojson  # Interval 0: hours 0-24
interval_001_024_048.geojson  # Interval 1: hours 24-48
interval_002_048_072.geojson  # Interval 2: hours 48-72
...
```

**File Structure:**
```json
{
  "type": "FeatureCollection",
  "properties": {
    "interval_idx": 0,
    "interval_hours": "0-24",
    "feature_count": 145,
    "max_probability": 12.34
  },
  "features": [
    {
      "type": "Feature",
      "properties": {
        "interval_idx": 0,
        "interval_hours": "0-24",
        "probability": 2.1450,
        "probability_percent": 2.15
      },
      "geometry": {
        "type": "Point",
        "coordinates": [80.15, 15.25]
      }
    },
    ...
  ]
}
```

### Index File

A `geojson_index.json` file is created for quick discovery:

```json
{
  "version": "1.0",
  "case_id": "6687",
  "generated": "2026-01-27T14:30:45.123456",
  "total_intervals": 3,
  "files": ["interval_000_000_024.geojson", "interval_001_024_048.geojson", ...],
  "intervals": [[0, 24], [24, 48], [48, 72]]
}
```

---

## 🎮 Map Controls

### Interval Selection

**Method 1: Time Slider**
- Drag the slider at the top to navigate through all intervals
- Real-time map update

**Method 2: Quick Buttons**
- Click hour range buttons (H0-24, H24-48, etc.)
- Shows first 5 intervals; use slider for rest

**Method 3: Programmatic**
```javascript
switchToInterval(2);  // Jump to interval 2
```

### Map Interactions

- **Pan**: Click and drag to move around
- **Zoom**: Scroll wheel or +/- buttons
- **Click Points**: See popup with probability data
- **Legend**: Check color scale for probability ranges

---

## 🎨 Color Scale

| Color | Probability |
|-------|------------|
| 🔵 Dark Blue | > 10% |
| 🔵 Blue | 5-10% |
| 🔵 Light Blue | 2-5% |
| 🟦 Lighter Blue | 1-2% |
| 🟦 Very Light Blue | 0.5-1% |
| ⬜ Pale Blue | < 0.5% |

---

## 🔧 Configuration

### In `saratv3visuals.py`

Modify the GeoJSON generation threshold:

```python
generate_geojson_files(
    outputpath, 
    prob_grids, 
    intervals, 
    lon_bins, 
    lat_bins, 
    probability_threshold=0.05  # ← Change this (0-100)
)
```

- **Lower threshold** (e.g., 0.01) → More points, larger files
- **Higher threshold** (e.g., 1.0) → Fewer points, smaller files

### In `map.html`

Modify map center and zoom:

```javascript
const MAP_CONFIG = {
    center: [15, 80],      // [latitude, longitude]
    zoom: 5,               // 1-18 (higher = zoomed in)
    tileLayer: '...'       // Tile provider URL
};
```

---

## 📊 Data Pipeline

```
saratv3visuals.py (runs SARAT)
    ↓
allin1sarat.run_sarat_analysis()
    ↓
prob_grids (one per interval)
    ↓
generate_geojson_files() [NEW]
    ↓
GeoJSON files created
    ↓
generate_geojson_index() [NEW]
    ↓
geojson_index.json created
    ↓
    Open map.html in browser
    ↓
Leaflet loads index
    ↓
User selects interval
    ↓
Leaflet fetches + displays GeoJSON
```

---

## 🐛 Troubleshooting

### Map shows "Loading data..." forever

**Cause**: GeoJSON files not found

**Solutions:**
1. Verify files exist: `ls case6687/figure/interval_*.geojson`
2. Check browser console (F12 → Console tab)
3. Use Python HTTP server for CORS:
   ```bash
   python -m http.server 8000
   ```

### No points visible on map

**Cause**: Probability threshold too high

**Solutions:**
1. Lower threshold in `saratv3visuals.py` (e.g., `probability_threshold=0.01`)
2. Re-run: `python saratv3visuals.py`
3. Refresh map in browser (Ctrl+F5)

### GeoJSON files too large

**Cause**: Threshold too low, many points

**Solutions:**
1. Increase threshold: `probability_threshold=0.5`
2. Re-run analysis
3. Consider compression or sampling

### Slider not working

**Cause**: JavaScript error

**Solutions:**
1. Check browser console for errors (F12)
2. Verify `geojson_index.json` exists
3. Clear browser cache (Ctrl+Shift+Delete)
4. Try different browser (Chrome/Firefox)

---

## 📈 Advanced Usage

### Custom Overlay

Add your own GeoJSON to the map:

```javascript
fetch('custom.geojson')
    .then(res => res.json())
    .then(data => L.geoJSON(data).addTo(map));
```

### Export Probability Data

Extract probabilities for specific interval:

```python
# In Python
import json

with open('case6687/figure/interval_000_000_024.geojson') as f:
    geojson = json.load(f)

for feature in geojson['features']:
    prob = feature['properties']['probability_percent']
    lon, lat = feature['geometry']['coordinates']
    print(f"Probability: {prob}% at ({lat}, {lon})")
```

### Multiple Cases

To visualize multiple cases:

1. Create separate directories per case
2. Run analysis for each case separately
3. Copy `map.html` to each
4. Modify to load from specific case's GeoJSON

---

## 📝 Example Workflow

```bash
# 1. Run analysis
python saratv3visuals.py

# Output:
# ✓ Running SARAT analysis...
# ✓ Generating GeoJSON files
#   • Interval 0 (0-24h): 145 features
#   • Interval 1 (24-48h): 152 features
#   • Interval 2 (48-72h): 138 features
# ✓ GeoJSON index created: case6687/figure/geojson_index.json
#   Total intervals: 3

# 2. Start web server
cd case6687/figure
python -m http.server 8000

# 3. Open browser
# Visit: http://localhost:8000/map.html

# 4. Interact with map
# - Use slider to navigate intervals
# - Click points for detailed info
# - Zoom/pan as needed
```

---

## 🔗 References

- **Leaflet Documentation**: https://leafletjs.com/
- **GeoJSON Spec**: https://tools.ietf.org/html/rfc7946
- **OpenStreetMap**: https://www.openstreetmap.org/

---

## 📞 Support

For issues:
1. Check browser console (F12)
2. Verify file paths are correct
3. Ensure Python packages installed: `numpy`, `pandas`
4. Try different browser
5. Check this README for troubleshooting section

---

## ✅ Checklist for First Run

- [ ] Run `python saratv3visuals.py`
- [ ] Check `case6687/figure/` for `interval_*.geojson` files
- [ ] Verify `geojson_index.json` exists
- [ ] Open `map.html` in browser
- [ ] See map with probability dots
- [ ] Slider or buttons control intervals
- [ ] Click a point, see popup
- [ ] Check status message at bottom

If all checked ✅, you're ready to explore your probability analysis!

---

**Version**: 1.0  
**Last Updated**: January 27, 2026
