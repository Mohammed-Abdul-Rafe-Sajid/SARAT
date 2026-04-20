# ⚡ Quick Start — 5 Minutes to Visualization

## TL;DR

```bash
# 1. Run analysis (generates hulls + PDF)
python saratv3visuals.py

# 2. Start map server
cd case6687/figure
python -m http.server 8000

# 3. Open browser
http://localhost:8000/map.html

# 4. View PDF
# Double-click: sarat_report_6687.pdf
```

**Done!** 🎉

---

## What You Get

✅ **Interactive Map**
- Blue polygon = search region
- Slider to change intervals
- Click polygon for details

✅ **PDF Bulletin**
- Title page with metadata
- One page per interval
- Professional formatting

✅ **GeoJSON Files**
- One per interval
- Ready for GIS tools
- Contains hull polygon

---

## Prerequisites

```bash
# Install dependencies (if not done)
pip install scipy reportlab numpy pandas
```

---

## Step-by-Step

### 1️⃣ Run Analysis
```bash
# From main directory
python saratv3visuals.py

# Expected output:
# --- Generating Convex Hull GeoJSON files ---
#   ✓ Interval 0 (0-24h): 145 points → interval_000_000_024.geojson
#   ✓ Interval 1 (24-48h): 152 points → interval_001_024_048.geojson
#   ...
# ✓ PDF Report generated: .../sarat_report_6687.pdf
```

### 2️⃣ Open Map
```bash
# Navigate to output directory
cd case6687/figure

# Start local server
python -m http.server 8000

# Open browser to:
# http://localhost:8000/map.html
```

### 3️⃣ Explore Map
- **See polygon:** Blue outlined region
- **Click it:** Popup with statistics
- **Drag slider:** Switch intervals
- **Zoom/Pan:** Standard map controls

### 4️⃣ View PDF
```bash
# Method 1: Direct open
# Double-click: case6687/figure/sarat_report_6687.pdf

# Method 2: Command line
# Mac
open case6687/figure/sarat_report_6687.pdf

# Windows
start case6687/figure/sarat_report_6687.pdf

# Linux
xdg-open case6687/figure/sarat_report_6687.pdf
```

---

## File Locations

```
case6687/figure/
├── map.html                        ← Open in browser
├── geojson_index.json              ← Map discovery
├── interval_000_000_024.geojson    ← Polygon 1
├── interval_001_024_048.geojson    ← Polygon 2
└── sarat_report_6687.pdf           ← PDF bulletin
```

---

## Common Commands

### Check if files exist
```bash
ls -lh case6687/figure/interval_*.geojson
ls -lh case6687/figure/sarat_report_6687.pdf
```

### Validate GeoJSON
```bash
python -m json.tool case6687/figure/interval_000_000_024.geojson
```

### Check PDF
```bash
ls -lh case6687/figure/sarat_report_6687.pdf
file case6687/figure/sarat_report_6687.pdf
```

---

## Customization

### Change probability threshold
Edit `saratv3visuals.py`, line ~125:
```python
probability_threshold=0.05  # Change this (in %)
```

### Custom case info in PDF
Edit `saratv3visuals.py`, line ~145:
```python
case_info = {
    "num_trajectories": 500,
    "grid_size": 0.1,
    "description": "Your custom text here"  # ← Edit this
}
```

### Map colors
Edit `map.html`, line ~287:
```javascript
function getColorForProbability(probability) {
    if (probability < 0.5) return '#e8f4f8';  // ← Light blue
    // ...
    return '#0052a3';  // ← Dark blue
}
```

---

## Troubleshooting

**Map shows nothing?**
- ✅ Check browser console (F12 → Console)
- ✅ Use `python -m http.server` (not file://)
- ✅ Verify `geojson_index.json` exists

**PDF not created?**
- ✅ Check PNG images exist: `ls case6687/figure/seeding*.png`
- ✅ Install reportlab: `pip install reportlab`
- ✅ Check terminal output for errors

**Files missing?**
- ✅ Verify analysis completed successfully
- ✅ Check output directory: `case6687/figure/`
- ✅ Check disk space (2+ GB)

---

## What's Different?

### vs. Old System
| Old | New |
|-----|-----|
| ❌ Points only | ✅ Search regions (polygons) |
| ❌ No PDF | ✅ Professional PDF reports |
| ❌ Manual map setup | ✅ Automatic map + PDF |

### Why Polygons?
- **Operational:** Responders need boundaries, not scattered points
- **Communication:** Easy to explain search area
- **Minimal:** 5-10 coordinates vs. 100+ for points
- **Standard:** GeoJSON Polygon is industry standard

---

## Next Steps

### To integrate with team:
1. Host on web server
2. Share URL with responders
3. Distribute PDF bulletins

### To analyze more cases:
1. Change `id_number = 6687` in code
2. Run: `python saratv3visuals.py`
3. Open corresponding `map.html`

### To customize further:
- See `CONVEX_HULL_PDF_GUIDE.md` for detailed options
- See `COMPLETE_SUMMARY.md` for technical details

---

## ✅ Verification

After running, you should have:

```
case6687/figure/
✓ interval_000_000_024.geojson   (~8 KB)
✓ interval_001_024_048.geojson   (~8 KB)
✓ interval_002_048_072.geojson   (~8 KB)
✓ geojson_index.json              (~200 B)
✓ sarat_report_6687.pdf           (~2.5 MB)
✓ map.html                        (unchanged)
```

**If all present:** System working! 🎉

---

## Support

Not working? Check in this order:

1. **Errors in terminal?** → Read the error message
2. **Files missing?** → Verify analysis completed
3. **Map blank?** → Check browser console (F12)
4. **PDF issues?** → Check PNG files exist
5. **Still stuck?** → See `CONVEX_HULL_PDF_GUIDE.md` troubleshooting section

---

**Time to working visualization: ~30 seconds** ⚡

Enjoy your SARAT analysis!
