# SARAT Codebase Analysis

## Project: Search and Rescue Aid Tool (SARAT)
**Organization**: INCOIS (Indian National Centre for Ocean Information Services), Ministry of Earth Sciences, Government of India

## Tech Stack & Languages
- **Bash Shell Scripts** (.sh) - Main workflow orchestration
- **Python** (3.x) - Data processing, visualization, GeoJSON generation
- **Fortran** (.f) - Probability calculations
- **Ferret** (Scientific data language) - Ocean/current data processing
- **GMT** (Generic Mapping Tools) - Map visualization and PostScript generation
- **Java** - Land/ocean classification utility
- **NetCDF** (Climate/weather data format) - Current and wind data
- **GRIB** (Gridded Binary) - Model input format
- **JSON/GeoJSON** - Output data serialization

## Core Components

### 1. **Input Stage** (Wind & Current Preparation)
- **RunSARInputCreationV2.sh** (Entry Point)
  - Validates lat/lon against land/ocean data (Ferret + ETOPO1 database)
  - Extracts current data from CRSAR model (cursar_*.nc files)
  - Extracts wind data from WSSAR model (wssar_*.nc files)
  - Performs temporal interpolation for IST timezone alignment
  - Converts NetCDF → GRIB format via CDO

### 2. **Seed/Configuration Stage**
- **InfilePreparationV2.sh**
  - Creates `lwseed*.in` configuration file from user inputs
  - Contains: lat/lon (degrees + decimal minutes), start/end dates, object class
  - Formatted for Leeway particle drift model
  
- **GenerateXYpointsV2.sh**
  - Generates start/end point coordinates for search region
  - Uses Ferret to validate land/ocean boundaries
  - Produces `pts_*.dat` files

### 3. **Model Execution** (via lwseed executable)
- Converts `lwseed*.in` → `leeway*.in` (actual model input)
- Configurable output timesteps (default: 3600 seconds)
- Runs on remote server (172.30.2.34) via SSH
- Outputs particle trajectories: `leeway*.out`

### 4. **Post-Processing** (Probability/Hull Calculation)
- **leeway_probV2.f** (Fortran)
  - Reads leeway.out particle data
  - Generates:
    - `composite_*.dat` - Aggregated particle positions
    - `area_*.dat` - Probability grid cells
    - `hull_*.dat` - Convex hull boundary points
    - `meantrajectory_*.dat` - Mean/median drift paths
    - `convex_hull_*.dat` - Convex hull coordinates
    - `probability_*.gnu` & `complete_trajectory_*.gnu` - Gnuplot scripts

### 5. **Land Checking & Refinement**
- **LandCheckingFromConvexHullV2.py**
  - Removes land-based hull points
  - Updates `area_*.dat` accordingly
  - Generates `finalconvexhull_*.dat`

### 6. **Probability Segmentation**
- **HullSegmentV2.sh**
  - Creates probability contours at 5%, 10%, 15%, 20%, etc.
  - Outputs: `proval-X.XX-*.xy` files per probability threshold
  - Generates `gmtregion_*.txt` for mapping

### 7. **Output Visualization**
- **CreateGeoJsons.py**
  - LKP (Last Known Position): `lkp_*.geojson` point
  - Trajectories: `trajectories_*.geojson` linestrings
  - Mean path: `meantrajectory_*.geojson`

- **RunSARBulletinCreationV2.sh**
  - Creates PostScript bulletin PDFs
  - Displays regions with probabilities
  - Uses GMT for cartography
  - Adds metadata (date, coordinates, uncertainties)

### 8. **Visualization & Analysis** (New suite)
- **allin1sarat.py** - Unified analysis orchestrator
- **sarat_visuals.py** - Core visualization functions
- **saratv3visuals.py** - V3 enhancements
- Processes: trajectories, current fields, probability grids, beacon tracks

## Data Flow
```
User Input (lat, lon, dates)
    ↓
RunSARInputCreationV2.sh (validate, extract current/wind)
    ↓
InfilePreparationV2.sh (create lwseed*.in)
    ↓
lwseed executable (lwseed*.in → leeway*.in)
    ↓
Leeway Model (leeway*.in → leeway*.out) [on remote server]
    ↓
Fortran Post-processor (leeway*.out → composite/area/hull/mean trajectory .dat files)
    ↓
LandCheckingFromConvexHullV2.py (filter land points)
    ↓
HullSegmentV2.sh (create probability contours)
    ↓
CreateGeoJsons.py + RunSARBulletinCreationV2.sh (visualization)
    ↓
Output: GeoJSON, PostScript bulletin, probability maps
```

## Key File Formats

### Input:
- `lwseed*.in` - Seed configuration
- `wind*.grb` - Wind field GRIB
- `current*.grb` - Current field GRIB

### Intermediate:
- `leeway*.out` - Particle trajectories (lat, lon, time triplets)
- `*.nc` - NetCDF climate data
- `*.dat` - ASCII coordinate/probability data

### Output:
- `*.geojson` - Web visualization format
- `proval-X.XX-*.xy` - Probability contour coordinates
- `*.ps` - PostScript bulletin PDF
- `*.gnu` - Gnuplot script

## Case Example (case6687)
Shows post-processed outputs: trajectory data, probability grids, convex hull, mean paths, and GMT visualization scripts.

## Key Dependencies
- Ferret (ocean data processing)
- GMT (cartography)
- CDO (NetCDF/GRIB conversion)
- Java (land classification)
- sshpass (remote execution)
- bc (floating-point calculations)
