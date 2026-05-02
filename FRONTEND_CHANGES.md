# Frontend Changes & Upgrades Log

**Last Updated:** April 23, 2026

---

## 🔄 Change Log

### ✅ 2026-04-23 | Heatmap Grid Rendering Implementation

#### **Files Modified:**
- `webapp/Js/script.js`
- `webapp/Output_Test.jsp`

#### **Changes Made:**

##### 1. **Heatmap Rendering Functions** (script.js)
   - Added `getHeatmapColor(probability)` — Color scale mapping (0-100% → #FFEDA0 to #800026)
   - Added `getHeatmapStyle(feature)` — Grid cell styling (white borders, 0.7 opacity)
   - Added `onHeatmapEachFeature(feature, layer)` — Sticky hover tooltips with probability %
   - Added `renderHeatmapGeoJSON(data, map)` — Main renderer with layer replacement & bounds fitting
   - Added `loadHeatmapInterval(filepath, map)` — Async GeoJSON loader with error handling
   - Added `addHeatmapLegend(map)` — Legend display (probability scale visualization)

##### 2. **Heatmap Controls** (Output_Test.jsp)
   - Added `initHeatmapIntervals()` — Loads `data/geojson_index.json` on page init
   - Added `populateIntervalSelector(indexData)` — Populates dropdown with available intervals
   - Added `changeHeatmapInterval(filepath)` — Dynamic interval switching
   - Added `toggleHeatmapLayer()` — Show/hide heatmap visibility toggle

##### 3. **UI Components** (Output_Test.jsp)
   - Added **Interval Selector Dropdown** (hidden until index loads)
   - Added **Toggle Button** for heatmap layer visibility
   - Added **Heatmap Controls Section** above map with graceful degradation

#### **Features:**
- ✅ Grid-based probability heatmap (colored cells)
- ✅ Hover tooltips (probability percentage)
- ✅ Interval-based GeoJSON loading
- ✅ Dynamic interval switching
- ✅ Heatmap legend (probability scale)
- ✅ Backward compatible (existing polygon regions unaffected)
- ✅ Graceful fallback (hidden UI if no geojson_index.json)

#### **Backend Requirements:**
- GeoJSON files must contain `"properties": {"probability": <0-100>}`
- `data/geojson_index.json` with structure:
  ```json
  {
    "intervals": [
      { "name": "0-12h", "file": "interval_000_000_012.geojson" },
      { "name": "12-24h", "file": "interval_000_012_024.geojson" }
    ]
  }
  ```

---

## 📋 Documentation Template (for future changes)

### **YYYY-MM-DD | [Feature/Bug Fix/Enhancement]**

#### **Files Modified:**
- `path/to/file1.js`
- `path/to/file2.jsp`

#### **Changes Made:**
- **[Component/Section]** — Description
  - Sub-point 1
  - Sub-point 2

#### **Impact:**
- ✅ What works
- ⚠️ Dependencies/Requirements
- 🔄 Backward compatibility

---

## 📌 Quick Navigation

| Date | Change | Files | Status |
|------|--------|-------|--------|
| 2026-04-23 | Heatmap Grid Rendering | script.js, Output_Test.jsp | ✅ Complete |

