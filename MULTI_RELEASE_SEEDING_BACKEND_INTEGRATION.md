# Multi-Release Seeding Models - Backend Integration Guide

## Overview
The frontend now supports three seeding modes:
1. **Single Release** - Object released from one position at one time (existing behavior)
2. **Multiple Location Release** - Particles seeded from multiple locations at same time
3. **Continuous Moving Source** - Particles seeded along trajectory during time interval

---

## Data Flow: Frontend → Backend

### Form Submission Payload

All data is submitted via `Store` servlet with mode-specific fields:

```
Form Name: input_form
Action: Store (servlet endpoint)
Method: POST
```

#### Common Fields (All Modes)
- `From_date` — Last Known Time (LKT format)
- `To_date` — Simulation End Time
- `object` — Object type ID
- `release_mode` — Mode selector value: `single`, `multi_location`, `continuous_source`

#### Mode: `single` (Existing)
```
latitude      → float (decimal degrees)
longitude     → float (decimal degrees)
release_mode  → "single"
```

#### Mode: `multi_location` (NEW)
```
release_mode     → "multi_location"
multi_lkt        → Release time (same for all locations)
locations[0].lat → Location 1 latitude
locations[0].lon → Location 1 longitude
locations[1].lat → Location 2 latitude
locations[1].lon → Location 2 longitude
... (more locations if added)
```

**Data Structure Note**: Multiple locations submitted as:
- Multiple input fields with class `.location-latitude` and `.location-longitude`
- JavaScript collects all elements by these classes
- Need to serialize in form submission (see below)

#### Mode: `continuous_source` (NEW)
```
release_mode       → "continuous_source"
cont_start_lat     → Start position latitude
cont_start_lon     → Start position longitude
cont_end_lat       → End position latitude
cont_end_lon       → End position longitude
cont_start_time    → Start release time (LKT1)
cont_end_time      → End release time (LKT2)
```

---

## Backend Implementation Requirements

### 1. Store Servlet Enhancement

**Current**: Receives single LKP, LKT
**Required**: Parse `release_mode` parameter and handle all three modes

```
if release_mode == "single":
    use_single_lkp(latitude, longitude, from_date, to_date)
elif release_mode == "multi_location":
    use_multi_lkp(multi_lkt, locations_array, from_date, to_date)
elif release_mode == "continuous_source":
    use_continuous_source(start_pos, end_pos, start_time, end_time, from_date, to_date)
```

### 2. InfilePreparationV2.sh Updates

**Task**: Modify to support multiple release points

Current flow:
```bash
# Single LKP
iplat=$(awk '{print $2}' userinput.txt)
iplon=$(awk '{print $3}' userinput.txt)
```

**New requirements**:
- For `multi_location`: Extract all LKP coordinates from input
- For `continuous_source`: Extract start_lat, start_lon, end_lat, end_lon
- Pass release_mode indicator to downstream scripts

### 3. lwseed Generation Updates

**File**: Likely in backend scripts that generate `.in` seed files

**Changes needed**:

#### Single Release (unchanged)
```
One set of seed particles from single (lat, lon)
```

#### Multiple Location Release
```
For each location in locations_array:
    Generate particles from (lat_i, lon_i)
    Use same release_time (multi_lkt)
    Divide particle count by N_locations

Total particles = same as before, distributed across N locations
```

**Example**:
- Single mode: 50,000 particles from 1 location
- Multi mode (2 locations): 25,000 particles from location 1 + 25,000 from location 2
- All released at same timestamp

#### Continuous Moving Source
```
For each time-step from start_time to end_time:
    Calculate interpolated position:
        lat(t) = start_lat + (end_lat - start_lat) * (t - start_time) / (end_time - start_time)
        lon(t) = start_lon + (end_lon - start_lon) * (t - start_time) / (end_time - start_time)
    
    Seed particles at (lat(t), lon(t)) at time t
    Divide release budget across time steps
```

### 4. RunSARInputCreationV2.sh Updates

**Current**: Processes single LKP
**Required**: Support multiple LKPs and continuous trajectory

```bash
if [ "$RELEASE_MODE" = "multi_location" ]; then
    # Process multiple LKPs
    for lkp in "${LKP_ARRAY[@]}"; do
        LLAT=$(echo $lkp | cut -d, -f1)
        LLON=$(echo $lkp | cut -d, -f2)
        # Validation for each LKP
    done
elif [ "$RELEASE_MODE" = "continuous_source" ]; then
    # Interpolation logic
    # Generate intermediate release positions
fi
```

### 5. HullSegmentV2.sh & Trajectory Generation

**Impact**: No fundamental changes
- Simulation engine receives particles regardless of source
- Trajectories computed end-to-end as before
- Multiple source particles naturally combine into unified probability field

### 6. CreateGeoJsons.py Updates

**Line 21**: Function signature may need mode awareness
```python
def createLKPGeoJson(uniqId, searchAndRescueRootDir, release_mode="single"):
    # Existing: displays single LKP point
    
    if release_mode == "multi_location":
        # Display multiple LKP points with different styling
    elif release_mode == "continuous_source":
        # Display start and end positions, possibly trajectory connecting them
```

---

## Input Validation by Backend

### Multi-Location Mode
- Minimum 2 locations required
- All coordinates must be valid ocean points (land check)
- Single release time (multi_lkt) applies to all
- Simulation duration measured from Simulation End Time (To_date)

### Continuous Mode
- Start time must be before end time
- Start time must be ≤ From_date in some contexts (depends on interpretation)
- Simulation duration: From_date to To_date (represents total simulation window)
- Continuous release window: cont_start_time → cont_end_time (subset or spanning)

---

## Request Payload Format Example

### Single Release Mode
```
POST /Store
Parameters:
  release_mode=single
  object=7
  From_date=2026-05-15 12:30:00
  To_date=2026-05-18 18:30:00
  latitude=14.5234
  longitude=71.2345
```

### Multiple Location Mode
```
POST /Store
Parameters:
  release_mode=multi_location
  object=7
  From_date=2026-05-15 12:30:00
  To_date=2026-05-18 18:30:00
  multi_lkt=2026-05-15 14:00:00
  locations[0].lat=14.5234
  locations[0].lon=71.2345
  locations[1].lat=14.6234
  locations[1].lon=71.3345
  locations[2].lat=14.7234
  locations[2].lon=71.4345
```

### Continuous Moving Source Mode
```
POST /Store
Parameters:
  release_mode=continuous_source
  object=7
  From_date=2026-05-15 12:30:00
  To_date=2026-05-18 18:30:00
  cont_start_lat=14.5234
  cont_start_lon=71.2345
  cont_end_lat=14.7234
  cont_end_lon=71.4345
  cont_start_time=2026-05-15 12:30:00
  cont_end_time=2026-05-15 18:30:00
```

---

## Critical Implementation Notes

### 1. Frontend-Backend Synchronization
- JavaScript sends `release_mode` field
- Backend MUST check this field to determine parsing logic
- Do NOT infer mode from presence/absence of fields
- Ensure Store servlet is updated before going live

### 2. Particle Budget Distribution
- Single mode: 100% particles from 1 location
- Multi-location: Budget ÷ N_locations per location
- Continuous: Budget distributed across time steps
- **Important**: Total particle count should remain roughly same across modes

### 3. Output Consistency
- All modes produce same output format: GeoJSON, PDF bulletin, images
- Probability maps should show combined regions for all modes
- Centroid/bounding box should reflect all particle sources

### 4. Simulation Engine Assumptions
- Existing particle tracking and trajectory computation unchanged
- Wind/ocean current fields applied universally
- Probability binning works on final end position

### 5. Testing Matrix

| Mode | Test Case | Expected Output |
|------|-----------|-----------------|
| Single | Existing test case | Unchanged |
| Multi-location | 2 locations at same LKT | 2 separate regions merging |
| Multi-location | 3+ locations | Multiple distinct bins initially, merged later |
| Continuous | Start A→End B over 6h | Elongated region along trajectory |

---

## Backward Compatibility

- Single release mode preserves existing behavior
- Default mode is `single` (Web UI default)
- Existing request format still works (defaults to single mode)
- No schema changes to output files

---

## Debugging Checklist

1. ✓ Verify `release_mode` value in request
2. ✓ Check all locations validated (ocean points)
3. ✓ Confirm time parameters in correct format
4. ✓ Verify particle distribution logic
5. ✓ Check lwseed file generation per mode
6. ✓ Validate combined trajectory output
7. ✓ Test PDF bulletin generation for all modes
8. ✓ Cross-check GeoJSON features count
