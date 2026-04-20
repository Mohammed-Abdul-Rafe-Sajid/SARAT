# SARAT Codebase - Complete Analysis

## Project Overview

**SARAT** = **Search and Rescue Aid Tool**

**Organization**: INCOIS (Indian National Centre for Ocean Information Services)  
**Ministry**: Ministry of Earth Sciences, Government of India  
**Certification**: ISO 9001:2008

An oceanographic particle-drift simulation system designed to predict locations of lost/missing maritime objects by integrating real-time ocean currents and wind fields to generate probability maps for search and rescue operations.

---

## Tech Stack & Languages

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Workflow Orchestration** | Bash Shell Scripts (.sh) | Coordinating entire pipeline |
| **Data Processing** | Ferret (Scientific DSL) | Extract ocean currents/wind from NetCDF |
| **Marine Model** | Leeway Particle Drift | Simulate object trajectories |
| **Post-Processing** | Fortran (.f) + Python | Calculate probabilities & trajectories |
| **Cartography** | GMT (Generic Mapping Tools) | Generate PDF bulletins/maps |
| **Output Formats** | GeoJSON, GRIB, NetCDF | Web visualization & data standards |
| **Land Validation** | Java + Ferret + ETOPO1 | Validate ocean locations |
| **Visualization** | Python + Gnuplot | Interactive analysis pipeline |
| **Data Format Conversion** | CDO (Climate Data Operators) | NetCDF ↔ GRIB conversion |
| **Remote Execution** | sshpass + SSH | Run model on remote server |

**Primary Languages**: Bash, Python, Fortran, Ferret, Java, GMT scripting

---

## Architecture & Complete Data Flow

### **Stage 1: User Input**
```
Input Parameters:
├─ Object location (latitude, longitude)
├─ Search window (start date, end date)
├─ Object class/type
└─ Unique ID for this search
```

### **Stage 2: Input Preparation** (`RunSARInputCreationV2.sh` - ENTRY POINT)

**Location**: `/home/osf/SearchAndRescueTool/`

**Functions**:
1. **Validation**: Check if lat/lon are in ocean (not on land)
   - Uses Ferret to query ETOPO1 bathymetric database
   - Commands: `ferret -nojnl` with rose variable
   - Output: `invalidlatlon.txt` (1=land, 0=ocean)

2. **Current Data Extraction**:
   - Reads CRSAR model files: `data/cursar_YYYYMMDD.nc`
   - Extracts surface currents: U (east), V (north)
   - Performs temporal interpolation to IST timezone
   - Handles 3-hourly timesteps from current model
   - Creates: `CurrentInput_<UniqId>.nc`

3. **Wind Data Extraction**:
   - Reads WSSAR model files: `data/wssar_YYYYMMDD.nc`
   - Extracts surface winds: WX (east), WY (north)
   - Same temporal alignment as currents
   - Land masking (sets wind to 0 over land)
   - Creates: `WindInput_<UniqId>.nc`

4. **Data Conversion**:
   - Uses CDO (Climate Data Operators) to convert:
     - `CurrentInput_*.nc` → `current<UniqId>.grb` (GRIB format)
     - `WindInput_*.nc` → `wind<UniqId>.grb` (GRIB format)
   - Parameter mapping for model compatibility

5. **Timezone Handling**:
   - Aligns IST (Indian Standard Time) with GMT
   - Calculates IST offsets using modulo 10800 (3 hours in seconds)
   - Supports multi-day simulations

### **Stage 3: Seeding/Configuration** (`InfilePreparationV2.sh`)

**Creates**: `lwseed<UniqId>.in` seed configuration file

**File Format**:
```ini
Leeway seeder - do not remove this lon
2.5                    # Leeway model version
76                     # startLon (degrees)
30.45                  # startLon (decimal minutes)
15                     # startLat (degrees)
22.15                  # startLat (decimal minutes)
76                     # endLon (degrees)
30.45                  # endLon (decimal minutes)
15                     # endLat (degrees)
22.15                  # endLat (decimal minutes)
10                     # startRad (search radius in km)
10                     # endRad (search radius in km)
GSHHS                  # Optional object description
<ObjectClass>          # Object classification ID (int)
2024                   # startDate [year]
3                      # startDate [month]
15                     # startDate [day]
10 30                  # startDate [hh mm]
2024                   # endDate [year]
3                      # endDate [month]
20                     # endDate [day]
14 30                  # endDate [hh mm]
0 0.0 0.0             # Constant current (east, north) [m/s] - false=0
0 0.0 0.0             # Constant wind (east, north) [m/s] - false=0
0                     # Particles strand on land? (true=1, false=0)
3600                  # Output timestep [seconds]
```

**Processing**:
- Extracts user inputs from `userinput_<UniqId>.txt`
- Converts decimal lat/lon to degrees + decimal minutes
- Formats timestamps for Leeway model
- One seed file per search request

### **Stage 4: Lwseed Conversion**

**Executable**: `lwseed` (compiled binary)

**Function**: `lwseed <lwseed<UniqId>.in> <leeway<UniqId>.in>`

**Output**: `leeway<UniqId>.in` (actual model input file)

**Parameters Configured** (via leeway*.in):
- Initial particle positions (radius-based seeding)
- Simulation duration and timesteps
- Output file format
- Physical parameters (buoyancy, uncertainty)
- Environmental forcing (currents, winds)

---

### **Stage 5: Drift Simulation** (Leeway Model - Remote Server)

**Remote Server**: `172.30.2.34` (incois@incois)

**Directory**: `/home/incois/SARAT_Leeway_Runs/`

**Execution Method**:
- Files synced via `sshpass` + `rsync`
- Command: `./leeway ./leeway<UniqId>.in ./leeway<UniqId>.out`
- Runs asynchronously
- Output retrieved: `leeway<UniqId>.out`

**Input Files**:
- `leeway<UniqId>.in` - Configuration
- `wind<UniqId>.grb` - Wind field
- `current<UniqId>.grb` - Current field

**Output**: `leeway<UniqId>.out`
- Format: Longitude, Latitude, Time triplets
- One line per particle position per timestep
- Blank lines separate individual particle trajectories

**Simulation Parameters**:
- 500-1000 particles per simulation
- 3-hourly output (configurable)
- Drift uncertainty: 10 km (configurable in RunSARInputCreationV2.sh)

---

### **Stage 6: Post-Processing** (`leeway_probV2.f` - Fortran Script)

**Execution**: Compiles and runs Fortran post-processor

**Input**: `leeway<UniqId>.out` (particle trajectories)

**Processing Steps**:

1. **Composite Data** (`composite_<UniqId>.dat`)
   - Aggregates all particle positions
   - Format: Longitude, Latitude, Count
   - Represents overall drift cloud

2. **Probability Grid** (`area_<UniqId>.dat`)
   - Bins particles into grid cells
   - Format: Cell Index, Probability Value (0-1)
   - Default grid: 0.1° resolution
   - Probability = (particles in cell) / (total particles)

3. **Hull Calculation** (`hull_<UniqId>.dat`)
   - Convex hull of all particle positions
   - Format: Longitude, Latitude
   - Defines outer boundary of search region
   - Line format: 3-point segments per hull vertex

4. **Mean Trajectory** (`meantrajectory_<UniqId>.dat`)
   - Mean/median drift path over time
   - Format: Longitude, Latitude (one per timestep)
   - Represents "most likely" object path

5. **Convex Hull Vertices** (`convex_hull_<UniqId>.dat`)
   - Explicit boundary coordinates
   - Format: Longitude, Latitude
   - Used for polygon-based search boundaries

6. **Visualization Scripts**:
   - `probability_<UniqId>.gnu` - Gnuplot script for contours
   - `complete_trajectory_<UniqId>.gnu` - Particle paths visualization
   - `.eps` outputs from Gnuplot (PostScript figures)

---

### **Stage 7: Land-Based Refinement** (`LandCheckingFromConvexHullV2.py`)

**Function**: Remove search area over land

**Input**:
- `hull_<UniqId>.dat` - Current convex hull
- `area_<UniqId>.dat` - Probability grid

**Processing**:
1. Iterates through each hull boundary point
2. Checks if point is ocean or land using Ferret:
   - Command: `ferret -script landoceancheck.jnl <lon> <lat>`
   - Uses ETOPO5 database
   - Returns: negative=ocean, positive=land

3. Removes land points from hull
4. Updates `area_<UniqId>.dat` to exclude land cells
5. Creates backup: `area_original_<UniqId>.dat`

**Outputs**:
- `finalconvexhull_<UniqId>.dat` - Refined boundary
- Updated `area_<UniqId>.dat` - Land-masked probabilities

---

### **Stage 8: Probability Contours** (`HullSegmentV2.sh`)

**Function**: Segment probability regions by threshold

**Processing**:

1. **Threshold Definition**:
   - Probability levels: 5%, 10%, 15%, 20%, 25%, ..., 90%, 100%
   - Array: `gt=( 0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.6 0.7 0.8 0.9 )`

2. **Contour Generation**:
   - For each threshold, extracts hull segments containing that probability
   - Creates separate coordinate file per threshold
   - Output: `proval-0.05-<UniqId>.xy`, `proval-0.10-<UniqId>.xy`, etc.

3. **GMT Region File**:
   - `gmtregion_<UniqId>.txt` - Probability values for mapping
   - Used by RunSARBulletinCreationV2.sh for visualization

4. **Last Known Position (LKP)**:
   - Extracted from first line of `hull_<UniqId>.dat`
   - Coordinates stored for bulletin

---

### **Stage 9: GeoJSON Output** (`CreateGeoJsons.py`)

**Function**: Export results in web-friendly format

**Outputs**:

1. **Last Known Position**: `lkp_<UniqId>.geojson`
   ```json
   {
     "type": "FeatureCollection",
     "features": [{
       "type": "Feature",
       "geometry": {
         "type": "Point",
         "coordinates": [77.5, 15.3]
       },
       "properties": {"name": "Last Known Position"}
     }]
   }
   ```

2. **Trajectories**: `trajectories_<UniqId>.geojson`
   ```json
   {
     "type": "FeatureCollection",
     "features": [{
       "type": "Feature",
       "geometry": {
         "type": "LineString",
         "coordinates": [[77.5, 15.3], [77.6, 15.4], ...]
       },
       "properties": {"name": "Trajectory_1"}
     }, ...]
   }
   ```

3. **Mean Trajectory**: `meantrajectory_<UniqId>.geojson`
   - Most probable drift path
   - Single LineString feature

**Processing**:
- Reads from `complete_traj_<UniqId>.dat`
- Parses coordinates
- Separates trajectories by blank lines
- Outputs GeoJSON FeatureCollections
- Suitable for web mapping (Leaflet, Mapbox, etc.)

---

### **Stage 10: Bulletin Generation** (`RunSARBulletinCreationV2.sh`)

**Function**: Create PDF search advisory with cartography

**Processing**:

1. **Map Setup** (GMT):
   - Region: Indian Ocean (76°E-98°E, 13°N-28°N)
   - Projection: Mercator (7.5 inch width)
   - Basemap: Plain

2. **Features Added**:
   - Probability region boundaries (from `proval-*.xy` files)
   - Color-coded by probability threshold
   - Last Known Position (LKP) marked
   - Mean trajectory overlay

3. **Text Annotations**:
   - Title: "Search and Rescue Advisory"
   - Organization: "ESSO-INCOIS"
   - Certification: "ISO 9001:2008"
   - Top probable regions with percentages
   - LKP coordinates (degrees, minutes, seconds format)
   - Generation timestamp (IST)
   - Valid until date

4. **Example Output**:
   ```
   Search and Rescue Advisory for Missing Object
   Based upon SARAT simulations:
   - REGION 1: 50% probability
   - REGION 2: 40% probability
   Last Known Position: 77°30'15" E, 15°18'06" N
   Generated: 15/03/2024 10:30 IST
   Valid Until: 20/03/2024 14:30 IST
   Uncertainty: 10 km in initial condition
   ```

5. **Output Format**:
   - `firstpage_<UniqId>.ps` (PostScript)
   - Convertible to PDF via `ps2pdf`
   - Printable advisory for search operators

---

### **Stage 11: Visualization Analysis** (New Suite)

**Scripts**:
- `allin1sarat.py` - Unified orchestrator
- `sarat_visuals.py` - Core visualization functions
- `saratv3visuals.py` - Version 3 enhancements

**Capabilities**:
- Trajectory property analysis
- Current field processing
- Probability grid generation
- Beacon/drifter track overlay
- Interactive scientific plots
- Time-series analysis
- Grid metadata tracking

**Usage**:
```python
result = run_sarat_analysis(
    id_number="6687",
    input_path="/path/to/data",
    num_trajectories=500,
    interval_size=24,  # hours
    plot_sighted_positions=True,
    beacontrack=False
)
```

**Returns**: Dictionary with all analysis data (trajectories, probabilities, grids, etc.)

---

## Complete Data File Reference

### **Input Files**

| File | Format | Source | Purpose |
|------|--------|--------|---------|
| `userinput_<UniqId>.txt` | Text | User form | Search parameters |
| `data/cursar_YYYYMMDD.nc` | NetCDF | CRSAR model | Current field data |
| `data/wssar_YYYYMMDD.nc` | NetCDF | WSSAR model | Wind field data |
| `lwseed<UniqId>.in` | Text config | Generated | Leeway seed file |
| `leeway<UniqId>.in` | Text config | lwseed tool | Model input |
| `wind<UniqId>.grb` | GRIB | Generated | Wind forcing |
| `current<UniqId>.grb` | GRIB | Generated | Current forcing |
| `etopo1.cdf` | NetCDF | Reference | Bathymetry/land mask |
| `etopo5.cdf` | NetCDF | Reference | Land/ocean mask |

### **Intermediate/Output Files**

| File | Format | Producer | Content |
|------|--------|----------|---------|
| `leeway<UniqId>.out` | ASCII | Leeway model | Particle trajectories (lon, lat, time) |
| `composite_<UniqId>.dat` | ASCII | Fortran | Aggregated particle positions |
| `area_<UniqId>.dat` | ASCII | Fortran | Probability grid cells (index, prob) |
| `hull_<UniqId>.dat` | ASCII | Fortran | Convex hull boundary points |
| `meantrajectory_<UniqId>.dat` | ASCII | Fortran | Mean drift path |
| `convex_hull_<UniqId>.dat` | ASCII | Fortran | Hull vertices |
| `finalconvexhull_<UniqId>.dat` | ASCII | Python | Land-refined hull |
| `area_original_<UniqId>.dat` | ASCII | Python | Backup (before land removal) |
| `proval-0.05-<UniqId>.xy` | ASCII | Bash | 5% probability contour |
| `proval-0.10-<UniqId>.xy` | ASCII | Bash | 10% probability contour |
| `proval-*.xy` | ASCII | Bash | Other probability thresholds |
| `gmtregion_<UniqId>.txt` | ASCII | Bash | Probability values for GMT |
| `lkp_<UniqId>.geojson` | GeoJSON | Python | Last Known Position (Point) |
| `trajectories_<UniqId>.geojson` | GeoJSON | Python | All trajectories (LineStrings) |
| `meantrajectory_<UniqId>.geojson` | GeoJSON | Python | Mean path (LineString) |
| `ObjectName_<UniqId>.txt` | ASCII | Java | Object class name |
| `firstpage_<UniqId>.ps` | PostScript | GMT | PDF bulletin |
| `probability_<UniqId>.gnu` | Gnuplot | Fortran | Contour visualization script |
| `complete_trajectory_<UniqId>.gnu` | Gnuplot | Fortran | Trajectory visualization script |
| `complete_traj_<UniqId>.dat` | ASCII | Fortran | Complete trajectory coordinates |

---

## How to Configure & Run

### **Prerequisites Installation**

**Linux/Unix System Required**:
```bash
# Core dependencies
sudo apt-get install ferret gmt cdo sshpass bc java

# Ferret setup
source /usr/local/ferret/bin/my_ferret_paths_template.sh

# GMT configuration
gmt gmtset BASEMAP_TYPE=plain
```


## EXISTING STRUCTURE
```
sarat/
├── BackendScripts/
│   ├── CreateGeoJsons.py
│   ├── GenerateXYpointsV2.sh
│   ├── HullSegmentV2.sh
│   ├── InfilePreparationV2.sh
│   ├── LandCheckingFromConvexHullV2.py
│   ├── LandCheckingFromConvexHullV2.sh
│   ├── RunSARBulletinCreationV2.sh
│   └── RunSARInputCreationV2.sh
├── sarat_new_visualization_changes/
│   ├── allin1sarat.py
│   ├── sarat_visuals.py
│   ├── saratv3visuals.py
│   └── case6687/
│       ├── 6687.json
│       ├── area_6687.dat
│       ├── area_original_6687.dat
│       ├── bounding_rect_and_centroid.txt
│       ├── bulletein-6687.pdf
│       ├── complete_trajectory_6687.gnu
│       ├── complete_traj_6687.dat
│       ├── complete_traj_tmp_6687.dat
│       ├── composite_6687.dat
│       ├── convex_hull_6687.dat
│       ├── creategeojsons_6687.log
│       ├── finalconvexhull_6687.dat
│       ├── final_6687.dat
│       ├── firstpage_6687.ps
│       ├── gmtregion_6687.txt
│       ├── hullsegment_6687.log
│       ├── hull_6687.dat
│       ├── landcheck_6687.log
│       ├── lat_6687.txt
│       ├── lkp_6687.dat
│       ├── lkp_6687.geojson
│       ├── lon_6687.txt
│       ├── lwseed6687.in
│       ├── meantrajectory_6687.dat
│       ├── meantrajectory_6687.geojson
│       ├── ObjectName_6687.txt
│       ├── probability_6687.gnu
│       ├── secondpage_6687.ps
│       ├── thirdpage_6687.ps
│       ├── trajectories_6687.geojson
│       ├── userinput_6687.txt
│       ├── dat_files/
│       │   ├── area_6687.dat
│       │   ├── area_original_6687.dat
│       │   ├── complete_traj_6687.dat
│       │   ├── complete_traj_tmp_6687.dat
│       │   ├── composite_6687.dat
│       │   ├── convex_hull_6687.dat
│       │   ├── finalconvexhull_6687.dat
│       │   ├── final_6687.dat
│       │   ├── hull_6687.dat
│       │   ├── lkp_6687.dat
│       │   └── meantrajectory_6687.dat
│       ├── figure/
│       │   ├── bounding_rect_and_centroid.txt
│       │   ├── seeding_0_24.png
│       │   ├── seeding_24_48.png
│       │   ├── seeding_48_72.png
│       │   ├── seeding_72_75.png
│       │   └── seeding_duration_6687_combined.png
│       ├── out_files/
│       │   └── leeway6687.out
│       └── xy_files/
│           ├── proval-0.05-6687.xy
│           ├── proval-0.10-6687.xy
│           ├── proval-0.15-6687.xy
│           └── proval-0.20-6687.xy
├── sarat-codebase-analysis.md
├── SARAT_CODEBASE_COMPLETE_ANALYSIS.md
├── SARAT_V3_IMPLEMENTATION_ROADMAP.md
└── SARAT_V3_2 (1).pdf
```
### **Directory Structure Required**

```
/home/osf/SearchAndRescueTool/
├── BackendScripts/
│   ├── RunSARInputCreationV2.sh       # MAIN ENTRY POINT
│   ├── InfilePreparationV2.sh
│   ├── GenerateXYpointsV2.sh
│   ├── HullSegmentV2.sh
│   ├── LandCheckingFromConvexHullV2.py
│   ├── CreateGeoJsons.py
│   ├── RunSARBulletinCreationV2.sh
│   └── leeway_probV2.f
├── model/leeway_india/build/leeway/
│   ├── lwseed/
│   │   └── lwseed (executable)
│   └── leeway/ (model executable directory)
├── data/
│   ├── cursar_YYYYMMDD.nc (current files)
│   └── wssar_YYYYMMDD.nc (wind files)
├── <output files generated during runs>
└── tmp_dir/ (temporary working directory)
```

### **Basic Execution - Step by Step**

#### **1. Prepare Inputs & Configuration**
```bash
cd /home/osf/SearchAndRescueTool

# Format:
# RunSARInputCreationV2.sh <ObjectID> <Lat> <Lon> <StartDate> <StartTime> <EndDate> <EndTime> <UniqID>

./RunSARInputCreationV2.sh "Ship ABC-123" 15.4 77.2 "2024-03-15" "10:30" "2024-03-20" "14:30" 6687
```

**This automatically**:
- Validates coordinates (ocean check)
- Extracts current and wind data
- Converts to GRIB format
- Creates lwseed file
- Calls lwseed converter
- Initiates remote leeway run

#### **2. Monitor Remote Execution**
```bash
# Check log file
tail -f leeway_6687.log

# Outputs show:
# "Creating '${remote_work_dir}' on '${remote_server_ip}' ..."
# "Syncing required files..."
# "Running leeway on remote server..."
# "Syncing output files..."
```

#### **3. Post-Process Results** (After leeway*.out is retrieved)
```bash
# Run Fortran post-processor (implicit in script)
# Generates: area_6687.dat, hull_6687.dat, meantrajectory_6687.dat, etc.

# Land checking
python3 LandCheckingFromConvexHullV2.py
# Generates: finalconvexhull_6687.dat

# Create probability contours
./HullSegmentV2.sh 6687
# Generates: proval-0.05-6687.xy, proval-0.10-6687.xy, etc.
```

#### **4. Generate Outputs**
```bash
# Create GeoJSON files
python3 CreateGeoJsons.py
# Generates: lkp_6687.geojson, trajectories_6687.geojson, meantrajectory_6687.geojson

# Create bulletin
./RunSARBulletinCreationV2.sh 6687 77.2 15.4 "Ship ABC-123"
# Generates: firstpage_6687.ps

# Convert to PDF
ps2pdf firstpage_6687.ps firstpage_6687.pdf
```

#### **5. Visualize (New Suite)**
```bash
python3 allin1sarat.py
# Or use sarat_visuals.py functions directly for custom analysis
```

---

## Understanding lwseed*.in Configuration

### **Coordinate Format**

Leeway uses degrees + decimal minutes format (NOT decimal degrees):

**Example**: Longitude 77.5°
```
Decimal degrees:  77.5
Degrees:          77
Decimal fraction: 0.5
Minutes (0.5 × 60): 30.0
Result in lwseed.in:
  77        # degrees
  30.0      # decimal minutes
```

### **Key Parameters Explained**

| Parameter | Range | Purpose |
|-----------|-------|---------|
| startLon/Lat | ±180/±90 | Initial search location |
| endLon/Lat | ±180/±90 | Search region extent (often same as start) |
| startRad/endRad | 1-100 km | Uncertainty radius for particle seeding |
| startDate/endDate | YYYY MM DD HH MM | Simulation timeframe |
| Constant current | 0/1 + m/s | Override wind/current with fixed values (0=disabled) |
| Particles strand | 0/1 | Stop particle motion on land? |
| Output timestep | seconds | How often to record particle positions (3600 s = 1 hour) |

### **Example Configurations**

**Quick Search (24 hours)**:
```ini
startDatum: 2024 3 15 10 30
endDate: 2024 3 16 10 30
startRad: 5 km
endRad: 5 km
Constant current: 0
Output timestep: 3600 (1 hourly)
```

**Extended Search (5 days, high uncertainty)**:
```ini
startDate: 2024 3 15 10 30
endDate: 2024 3 20 10 30
startRad: 15 km
endRad: 15 km
Constant current: 0
Output timestep: 3600 (1 hourly)
```

**Deterministic (fixed current, no uncertainty)**:
```ini
startDate: 2024 3 15 10 30
endDate: 2024 3 16 10 30
startRad: 1 km
Constant current: 1 0.5 0.2 (east=0.5 m/s, north=0.2 m/s)
Output timestep: 1800 (30 min for detail)
```

---

## Understanding Output Files

### **.dat Files Format**

**area_<UniqId>.dat**:
```
1 0.245
2 0.189
3 0.156
4 0.123
5 0.098
...
```
- Column 1: Grid cell index
- Column 2: Probability (0-1 scale)
- Sum ≈ 1.0 across all cells

**hull_<UniqId>.dat**:
```
77.234 15.456
77.245 15.467
77.256 15.478
77.234 15.456  # closes triangle
77.167 15.389  # next hull segment
77.178 15.400
77.189 15.411
77.167 15.389  # closes
...
```
- Triangular hull segments (3 points per segment)
- Latitude range: 13-28°N
- Longitude range: 76-98°E

**.xy Files (Probability Contours)**:
```
# proval-0.05-6687.xy
77.234 15.456
77.245 15.467
77.256 15.478
77.234 15.456

77.345 15.567
77.356 15.578
77.367 15.589
77.345 15.567
```
- One contour per probability threshold
- Blank lines separate polygons
- GMT-compatible format

### **.geojson Files**

**lkp_<UniqId>.geojson**:
```json
{
  "type": "FeatureCollection",
  "features": [{
    "type": "Feature",
    "geometry": {
      "type": "Point",
      "coordinates": [77.234, 15.456]
    },
    "properties": {
      "name": "Last Known Position"
    }
  }]
}
```

**trajectories_<UniqId>.geojson**:
```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [77.234, 15.456],
          [77.245, 15.467],
          [77.256, 15.478],
          ...
        ]
      },
      "properties": {"name": "Trajectory_1"}
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": [[...], [...], ...]
      },
      "properties": {"name": "Trajectory_2"}
    },
    ...
  ]
}
```

---

## Troubleshooting Common Issues

### **Issue: "invalidlatlon.txt contains 1"**
- **Problem**: Coordinates are on land, not ocean
- **Solution**: Verify lat/lon, use updated bathymetric reference

### **Issue**: "CurrentInput_*.nc file not available"**
- **Problem**: Current data missing for date range
- **Solution**: Check `data/cursar_YYYYMMDD.nc` files exist
- **Availability**: Contact CRSAR data provider for coverage

### **Issue**: Leeway remote execution fails
- **Problem**: SSH/rsync credentials, network, permission issues
- **Solution**: Check credentials in script, test SSH connection manually
  ```bash
  sshpass -p "incois@incois" ssh incois@172.30.2.34 "mkdir -p /home/incois/SARAT_Leeway_Runs/test6687"
  ```

### **Issue**: Land points still in finalconvexhull
- **Problem**: Ferret/ETOPO reference data outdated
- **Solution**: Update `landoceancheck.jnl` or Ferret datasets

### **Issue**: Probability values don't sum to 1.0
- **Problem**: Normal for discrete binning and land masking
- **Solution**: Not an error; reflects physical constraints

---

## Performance Notes

| Operation | Duration | Notes |
|-----------|----------|-------|
| Input prep (curr/wind) | 2-5 min | Depends on date range |
| Leeway simulation | 30-60 min | Remote execution on 172.30.2.34 |
| Post-processing | 2-3 min | Fortran execution |
| Land checking | 5-10 min | Per-point Ferret queries |
| Visualization | <1 min | GeoJSON + GMT |

**Total Pipeline**: 1-2 hours for typical 5-day search

---

## Integration Points

### **Web Interface Integration**
- Output: `lkp_<UniqId>.geojson`, `trajectories_<UniqId>.geojson`, `proval-*.xy`
- Web stack can render via Leaflet, Mapbox, or custom JS
- Copy GeoJSON to web directory: `/home/osf/tomcat/webapps/sarat/`

### **Alert System Integration**
- Monitor `leeway_<UniqId>.log` for completion
- On success, trigger bulletin distribution
- Copy `firstpage_<UniqId>.ps` → email/SMS system

### **Database Integration**
- Input logged to `db_sar` MySQL database (via SQL queries)
- Metadata stored: object class, dates, coordinates
- All run artifacts linked by `UniqId`

---

## Summary

**SARAT** is a sophisticated operational SAR system combining:
1. **Data ingestion** (Ferret/NetCDF) → meteorological fields
2. **Seeding** (Leeway config) → simulation parameters
3. **Modeling** (Leeway particle drift) → trajectory prediction
4. **Post-processing** (Fortran) → probability grids
5. **Refinement** (Python) → land masking
6. **Segmentation** (Bash) → probability contours
7. **Output** (GeoJSON + GMT) → web & bulletin formats

**Entry point**: `RunSARInputCreationV2.sh`  
**Key configuration**: `lwseed*.in` / `leeway*.in`  
**Output**: Probability maps, search regions, advisory PDF  
**Technology**: Bash, Python, Fortran, Ferret, GMT, NetCDF, GRIB  
**Runtime**: 1-2 hours per search scenario  
**Domain**: Maritime search and rescue (Indian Ocean region)
