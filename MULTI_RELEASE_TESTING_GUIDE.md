# Multi-Release Seeding Backend Implementation Testing Guide

## Quick Reference

| File | Purpose | Status |
|------|---------|--------|
| `BackendScripts/MultiReleaseHandler.py` | Core lwseed generation engine | ✅ IMPLEMENTED |
| `webapp/WEB-INF/src/MultiReleaseModeProcessor.java` | Form parsing & validation | ✅ IMPLEMENTED |
| `BackendScripts/InfilePreparationV2_UPDATED.sh` | Mode-aware script wrapper | ✅ IMPLEMENTED |
| `STORE_SERVLET_INTEGRATION_GUIDE.md` | Servlet integration steps | ✅ DOCUMENTED |

## Implementation Checklist

### Phase 1: Preparation
- [ ] Copy `MultiReleaseHandler.py` to `BackendScripts/`
- [ ] Verify Python3 and required libraries available on server
- [ ] Copy `MultiReleaseModeProcessor.java` to `webapp/WEB-INF/src/`
- [ ] Compile Java class (add to Store servlet classpath)
- [ ] Update `InfilePreparationV2.sh` with multi-mode support (use `InfilePreparationV2_UPDATED.sh` as reference)
- [ ] Verify `jq` JSON parser available on server (`apt-get install jq`)

### Phase 2: Servlet Integration
- [ ] Open `Store.java` servlet
- [ ] Import `MultiReleaseModeProcessor` class
- [ ] Add release mode detection (default = "single")
- [ ] Add parameter parsing call
- [ ] Add error handling for validation failures
- [ ] Update backend script invocation to pass `release_mode`
- [ ] Test compilation and deployment

### Phase 3: Testing - Single Release Mode
**Objective**: Verify backward compatibility

```
Input Form:
  release_mode: single
  latitude: 10.5
  longitude: 45.2
  lkt: 2024-01-15 08:00:00

Expected Output:
  lwseed_config_UNIQ.json (JSON with single location)
  lwseed_UNIQ.in (Traditional format with NPART, LAT, LON, IRELEASE)
  Simulation runs successfully
```

**Verification**:
1. Form submits with no release_mode (defaults to single) → works
2. Form submits with release_mode=single → works identically
3. Particle count is 50,000
4. Output matches traditional format
5. Simulation completes without errors

### Phase 3B: Testing - Multi-Location Release Mode
**Objective**: Verify multiple origin points

#### Test Case 1: 2 Locations
```
Input Form:
  release_mode: multi_location
  location_1_latitude: 10.5
  location_1_longitude: 45.2
  location_2_latitude: 10.6
  location_2_longitude: 45.3
  multi_lkt: 2024-01-15 08:00:00

Expected Output:
  lwseed_config_UNIQ.json (JSON with 2 locations)
  lwseed_UNIQ.in (Contains 2 IRELEASE sections):
    NPART 25000 (for location 1)
    LAT 10.5
    LON 45.2
    IRELEASE 1
    
    NPART 25000 (for location 2)
    LAT 10.6
    LON 45.3
    IRELEASE 2
```

**Verification**:
1. Config JSON has location_count=2
2. Each location gets 25,000 particles (50,000/2)
3. Both locations same release time
4. lwseed file has 2 IRELEASE blocks
5. Both coordinates validated (land check passes/fails appropriately)

#### Test Case 2: 5 Locations
```
Input: 5 location pairs + multi_lkt

Expected Output:
  JSON: location_count = 5
  lwseed.in: 5 IRELEASE blocks
  Each block: NPART 10000 (50,000/5)
```

**Verification**:
1. Particles distributed: 5 × 10,000 = 50,000
2. All 5 locations land-checked
3. Simulation runs with 5 seeding sources

### Phase 3C: Testing - Continuous Moving Source Mode
**Objective**: Verify trajectory-based seeding

#### Test Case 1: 4-Hour Movement
```
Input Form:
  release_mode: continuous_source
  start_lat: 10.5
  start_lon: 45.2
  end_lat: 10.9
  end_lon: 45.6
  start_time: 2024-01-15 08:00:00
  end_time: 2024-01-15 12:00:00
  interpolation_interval_minutes: 30

Expected:
  Duration: 4 hours = 240 minutes
  Interval: 30 minutes
  Release points: 240/30 + 1 = 9 points
  
  Points (interpolated):
    1. 08:00 - (10.5, 45.2) [start]
    2. 08:30 - (10.6, 45.3)    [interpolated]
    3. 09:00 - (10.7, 45.4)
    4. 09:30 - (10.8, 45.5)
    5. 10:00 - (10.85, 45.55)
    ... etc...
    9. 12:00 - (10.9, 45.6)   [end]
  
  Particles per point: 50,000 / 9 = ~5,556 each
```

**Verification**:
1. JSON: release_points_count = 9
2. First point coordinates match start_lat/lon
3. Last point coordinates match end_lat/lon
4. Interpolation formula correct: 
   - lat(t) = start_lat + (end_lat - start_lat) × (t - t_start) / (t_end - t_start)
   - lon(t) = start_lon + (end_lon - start_lon) × (t - t_start) / (t_end - t_start)
5. All coordinates within valid ranges
6. Times are sequential and evenly spaced
7. lwseed file has 9 IRELEASE blocks

#### Test Case 2: 12-Hour Movement
```
Input:
  start: (10.5, 45.2) at 2024-01-15 08:00:00
  end: (11.0, 46.0) at 2024-01-15 20:00:00
  interval: 60 minutes

Expected:
  Release points: 12/1 + 1 = 13 points
  Particles per point: 50,000 / 13 = ~3,846 each
```

### Phase 4: Error Handling Tests

#### Validation Error Test Cases

| Test | Input | Expected Behavior |
|------|-------|-------------------|
| Out of range latitude | lat=95 | Error: "Latitude out of range" |
| Out of range longitude | lon=200 | Error: "Longitude out of range" |
| Invalid mode | release_mode=invalid | Error: "Invalid release mode" |
| Multi-loc: Only 1 location | 1 location_*_* pair | Error: "Minimum 2 locations" |
| Continuous: time order | start>end | Error: "Start time before end" |
| Multi-loc: Missing lon | location_1_latitude only | Error: Missing parameter |

### Phase 5: File Output Validation

For each test case, verify:

1. **JSON Configuration File** (`lwseed_config_UNIQ.json`)
   ```
   {
     "unique_id": "12345",
     "mode": "multi_location",
     "generated_at": "2024-01-15T10:30:45",
     "seeding_configs": [{
       "mode": "multi_location",
       "location_count": 3,
       "locations": [{...}],
       ...
     }]
   }
   ```
   - Valid JSON syntax
   - Contains all required fields per mode
   - Timestamps in ISO format
   - Particle counts sum correctly

2. **Simulation Input File** (`lwseed_UNIQ.in`)
   ```
   NPART 16667
   LAT 10.5
   LON 45.2
   LKUNITS 0
   IRELEASE 1
   
   NPART 16667
   LAT 10.6
   ...
   ```
   - Valid NPART values (positive integers)
   - Valid LAT [-90, 90]
   - Valid LON [-180, 180]
   - IRELEASE sequential and unique
   - No syntax errors
   - Parseable by Ferret/simulation engine

3. **Trajectory File** (continuous mode only, `trajectory_UNIQ.txt`)
   ```
   1,2024-01-15T08:00:00,10.5,45.2
   2,2024-01-15T08:30:00,10.55,45.3
   3,2024-01-15T09:00:00,10.6,45.4
   ...
   ```
   - CSV format with sequence, time, lat, lon
   - Time progression correct
   - Lat/lon progression smooth

### Phase 6: Integration Testing

#### End-to-End Single Release
```
1. Submit form with release_mode=single
2. Verify MultiReleaseModeProcessor receives parameters
3. Verify JSON config generated
4. Verify lwseed.in created
5. Verify InfilePreparationV2.sh processes script correctly
6. Verify simulation runs and completes
7. Check output maps and statistics
```

#### End-to-End Multi-Location
```
1. Submit form with 3+ locations
2. Verify all locations land-checked
3. Check lwseed.in has N IRELEASE blocks
4. Verify particle distribution (50,000/N per location)
5. Run simulation
6. Check probability map shows seeding from all locations
7. Verify particles converge to same destination correctly
```

#### End-to-End Continuous Source
```
1. Submit form with start/end positions and times
2. Verify interpolation generated correct points
3. Check trajectory_UNIQ.txt shows smooth path
4. Verify lwseed.in has sequential release points
5. Run simulation
6. Check particle visualization shows continuous release
7. Verify final probability map reflects continuous source uncertainty
```

### Phase 7: Performance Testing

- [ ] Single release: < 1 second processing
- [ ] Multi-location (5 locs): < 2 seconds processing
- [ ] Continuous source (20 points): < 3 seconds processing
- [ ] Simulation time difference between modes: < 10% variance
- [ ] Memory usage during processing: < 100 MB

### Phase 8: UI Integration Tests

#### Frontend Validation
- [ ] Radio buttons appear correctly in Main.jsp
- [ ] Clicking each radio button shows correct section
- [ ] [+Add More] button works in multi-location mode
- [ ] Delete buttons appear for each location (except first when 2 total)
- [ ] DateTime pickers function correctly
- [ ] Form serialization creates correct POST data

#### Form Submission
- [ ] Single release: Hides multi/continuous sections, shows position
- [ ] Multi-location: Shows location containers with [+Add More], removes position fields
- [ ] Continuous: Shows start/end position and time fields
- [ ] Submit button includes release_mode in POST data
- [ ] Validation.js prevents incomplete submissions

## Test Execution Commands

### Local Testing (Before Deployment)

```bash
# Test MultiReleaseHandler.py directly
cd BackendScripts/

# Single release config
cat > test_single.json << 'EOF'
{
  "unique_id": "TEST_001",
  "mode": "single",
  "simulation_end": "2024-01-15 20:00:00",
  "latitude": 10.5,
  "longitude": 45.2,
  "lkt": "2024-01-15 08:00:00",
  "seeding_duration_hours": 12
}
EOF

python3 MultiReleaseHandler.py single test_single.json ./output/

# Multi-location config
cat > test_multi.json << 'EOF'
{
  "unique_id": "TEST_002",
  "mode": "multi_location",
  "simulation_end": "2024-01-15 20:00:00",
  "locations": [
    {"index": 1, "latitude": 10.5, "longitude": 45.2, "release_time": "2024-01-15 08:00:00"},
    {"index": 2, "latitude": 10.6, "longitude": 45.3, "release_time": "2024-01-15 08:00:00"},
    {"index": 3, "latitude": 10.7, "longitude": 45.4, "release_time": "2024-01-15 08:00:00"}
  ],
  "multi_lkt": "2024-01-15 08:00:00",
  "location_count": 3,
  "seeding_duration_hours": 12
}
EOF

python3 MultiReleaseHandler.py multi_location test_multi.json ./output/

# Continuous source config
cat > test_continuous.json << 'EOF'
{
  "unique_id": "TEST_003",
  "mode": "continuous_source",
  "simulation_end": "2024-01-15 20:00:00",
  "start_lat": 10.5,
  "start_lon": 45.2,
  "end_lat": 10.9,
  "end_lon": 45.6,
  "start_time": "2024-01-15 08:00:00",
  "end_time": "2024-01-15 12:00:00",
  "interpolation_interval_minutes": 30
}
EOF

python3 MultiReleaseHandler.py continuous_source test_continuous.json ./output/

# Verify outputs
ls -la output/
cat output/lwseed_config_TEST_*.json | jq .
cat output/lwseed_TEST_*.in
```

### Server Testing (After Deployment)

```bash
# Test through web form submission
# 1. Open browser to http://sarat-server/webapp/
# 2. Navigate to input form
# 3. Select "Single Release" mode
# 4. Fill coordinates and times
# 5. Submit form
# 6. Check output directory:

cd /var/www/sarat/case${UNIQ_ID}/
ls -la
cat lwseed_config_${UNIQ_ID}.json | jq .
cat lwseed_${UNIQ_ID}.in

# 7. Verify simulation proceeds normally
tail -f /var/log/sarat/simulation_${UNIQ_ID}.log
```

## Debugging Tips

### Issue: "MultiReleaseModeProcessor not found"
**Solution**: Verify Java class compiled and in servlet classpath
```bash
javac -d webapp/WEB-INF/classes webapp/WEB-INF/src/MultiReleaseModeProcessor.java
# Verify in $TOMCAT_HOME/work/Catalina/localhost/sarat/
```

### Issue: "No such file or directory: MultiReleaseHandler.py"
**Solution**: Verify Python script path in Java code matches actual location
```bash
which python3
ls -la BackendScripts/MultiReleaseHandler.py
# Update path in MultiReleaseModeProcessor.java
```

### Issue: JSON parsing fails ("jq: command not found")
**Solution**: Install jq on server
```bash
apt-get update && apt-get install -y jq
```

### Issue: "IRELEASE not sequential"
**Solution**: Check that loop indices in InfilePreparationV2.sh start at 1
```bash
# Should output: IRELEASE 1, 2, 3, etc.
grep IRELEASE lwseed_${UNIQ_ID}.in
```

### Issue: "Particles don't sum to 50,000"
**Solution**: Verify division logic in MultiReleaseHandler.py
```python
# For multi-location: particles_per_location = total_particles // len(locations)
# May lose 1-2 in integer division - acceptable
```

## Success Criteria

✅ All three modes implemented and tested  
✅ Backward compatibility confirmed (single mode default)  
✅ Form validation prevents invalid submissions  
✅ lwseed files generate correctly for all modes  
✅ Simulations complete without errors  
✅ Output probability maps reflect seeding distribution  
✅ Performance meets targets (< 5 seconds total processing)  
✅ Documentation complete and accurate  
