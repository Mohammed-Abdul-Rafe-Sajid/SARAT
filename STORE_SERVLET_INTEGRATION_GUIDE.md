# Store Servlet Integration Guide - Multi-Release Seeding Modes

## Overview
This guide explains how to integrate the multi-release seeding system into the existing `Store.java` servlet. The Store servlet is the POST endpoint that receives form submissions from Main.jsp.

## Architecture

```
Main.jsp (Frontend Form)
        ↓
     [POST]
        ↓
  Store.java (Servlet)
        ↓
  MultiReleaseModeProcessor.java (Parsing & Validation)
        ↓
  MultiReleaseHandler.py (lwseed Generation)
        ↓
  InfilePreparationV2.sh (Traditional Backend Processing)
```

## Integration Steps

### Step 1: Add Release Mode Detection in Store.java

In the `doPost()` method of Store.java, after receiving and validating basic request parameters:

```java
// Get release mode from form submission (default to 'single' for backward compatibility)
String releaseMode = request.getParameter("release_mode");
if (releaseMode == null || releaseMode.isEmpty()) {
    releaseMode = "single"; // Default to single release for backward compatibility
}

// Validate release mode
List<String> validModes = Arrays.asList("single", "multi_location", "continuous_source");
if (!validModes.contains(releaseMode)) {
    request.setAttribute("message", 
        "ERROR: Invalid release mode. Must be single, multi_location, or continuous_source.");
    request.getRequestDispatcher("/output.jsp").forward(request, response);
    return;
}
```

### Step 2: Process Mode-Specific Parameters

Add this processing logic after basic validation:

```java
// Get unique ID and output directory
String uniq_id = request.getParameter("uniq_id"); // From form
String outputDir = request.getSession().getServletContext()
        .getRealPath("/data/" + uniq_id);

// Create output directory if needed
new File(outputDir).mkdirs();

// Initialize processor
MultiReleaseModeProcessor processor = new MultiReleaseModeProcessor(
        releaseMode, 
        uniq_id, 
        outputDir
);

try {
    // Parse and validate mode-specific parameters
    Map<String, Object> releaseParams = MultiReleaseModeProcessor
            .parseReleaseParameters(releaseMode, request.getParameterMap());
    
    // Generate configuration JSON
    String configJson = processor.generateReleaseConfigJson(releaseParams);
    
    // Write configuration to file
    String configFilePath = processor.writeConfigFile(configJson);
    
    // Execute lwseed generation
    MultiReleaseModeProcessor.ProcessResult result = 
            processor.executeMultiReleaseHandler(configFilePath);
    
    if (!result.isSuccess()) {
        request.setAttribute("message", 
            "ERROR: Failed to generate lwseed configuration:\n" + result.getMessage());
        request.getRequestDispatcher("/output.jsp").forward(request, response);
        return;
    }
    
    // Log success
    System.out.println("Multi-release mode '" + releaseMode + "' processed successfully");
    System.out.println("lwseed config: " + configFilePath);
    
} catch (IllegalArgumentException e) {
    request.setAttribute("message", "VALIDATION ERROR: " + e.getMessage());
    request.getRequestDispatcher("/output.jsp").forward(request, response);
    return;
} catch (Exception e) {
    request.setAttribute("message", 
        "ERROR: Exception during multi-release processing: " + e.getMessage());
    e.printStackTrace();
    request.getRequestDispatcher("/output.jsp").forward(request, response);
    return;
}
```

### Step 3: Continue Existing Backend Processing

After successful lwseed generation, proceed with existing backend workflow:

```java
// Generate lwseed particles (traditional backend flow)
// The lwseed configuration from MultiReleaseHandler.py should be converted
// to the format expected by your existing simulation scripts

// Call existing backend script with mode awareness
String backendScript = "BackendScripts/InfilePreparationV2.sh";
ProcessBuilder pb = new ProcessBuilder(
        "bash",
        backendScript,
        uniq_id,
        releaseMode // Pass mode to backend for mode-specific handling
);

// ... proceed with existing Process execution and output handling
```

### Step 4: Update InfilePreparationV2.sh

Modify the script to accept and handle the release mode parameter:

```bash
#!/bin/bash
# InfilePreparationV2.sh - Updated for multi-release modes

UNIQ_ID=$1
RELEASE_MODE=${2:-single}  # Default to 'single' for backward compatibility

# Mode-specific processing
case "$RELEASE_MODE" in
    "single")
        # Existing single-release logic
        # Generate particles from single LKP at single LKT
        echo "Processing Single Release Mode for $UNIQ_ID"
        ;;
    
    "multi_location")
        # Multiple locations, single time
        # Read lwseed_config_${UNIQ_ID}.json
        # For each location: generate particles at that location
        echo "Processing Multiple Location Release Mode for $UNIQ_ID"
        # Extract locations from JSON and process each
        ;;
    
    "continuous_source")
        # Continuous trajectory-based seeding
        # Read lwseed_config_${UNIQ_ID}.json
        # Generate particles along interpolated path with time-based distribution
        echo "Processing Continuous Moving Source Mode for $UNIQ_ID"
        # Extract trajectory points and generate seeding along path
        ;;
    
    *)
        echo "ERROR: Unknown release mode: $RELEASE_MODE"
        exit 1
        ;;
esac

# ... continue with existing simulation pipeline
```

## Data Flow Examples

### Single Release Mode
```
Form submittal:
  release_mode=single
  latitude=10.5
  longitude=45.2
  lkt=2024-01-15 08:00:00

Processing:
  MultiReleaseModeProcessor parses coordinates
  MultiReleaseHandler generates:
    - Single location point
    - All 50,000 particles from one source
    
Output:
  lwseed_config_UNIQ_ID.json (JSON format)
  lwseed_UNIQ_ID.in (traditional simulation format)
```

### Multiple Location Release Mode
```
Form submittal:
  release_mode=multi_location
  location_1_latitude=10.5
  location_1_longitude=45.2
  location_2_latitude=10.6
  location_2_longitude=45.3
  location_3_latitude=10.7
  location_3_longitude=45.4
  multi_lkt=2024-01-15 08:00:00

Processing:
  MultiReleaseModeProcessor collects all location_*_latitude/longitude pairs
  Validates each location (2+ required)
  MultiReleaseHandler distributes 50,000 particles:
    - ~16,667 particles from location 1
    - ~16,667 particles from location 2
    - ~16,666 particles from location 3
    All released at same time (multi_lkt)
    
Output:
  lwseed_config_UNIQ_ID.json lists all 3 locations with particle counts
  lwseed_UNIQ_ID.in with 3 IRELEASE sections (one per location)
```

### Continuous Moving Source Mode
```
Form submittal:
  release_mode=continuous_source
  start_lat=10.5
  start_lon=45.2
  end_lat=10.7
  end_lon=45.4
  start_time=2024-01-15 08:00:00
  end_time=2024-01-15 12:00:00

Processing:
  MultiReleaseModeProcessor validates start/end positions and times
  MultiReleaseHandler interpolates path every 30 minutes:
    - 08:00:00: lat=10.5, lon=45.2 (start)
    - 08:30:00: lat=10.55, lon=45.3
    - 09:00:00: lat=10.6, lon=45.35
    - ... [continues every 30 min]
    - 12:00:00: lat=10.7, lon=45.4 (end)
  
  Generates 9 interpolated points total
  Distributes 50,000 particles across 9 points:
    - ~5,556 particles per release point
    
Output:
  lwseed_config_UNIQ_ID.json lists all 9 interpolated points with times/counts
  lwseed_UNIQ_ID.in with 9 IRELEASE sections (one per time step)
```

## Error Handling

The processor validates:

1. **Coordinate Validation**: Latitude [-90, 90], Longitude [-180, 180]
2. **Mode Validation**: Must be "single", "multi_location", or "continuous_source"
3. **Multi-location Validation**: Minimum 2 locations required
4. **Time Validation**: start_time < end_time, times in valid ISO format
5. **Land-Ocean Check**: Can be integrated with existing verifyLatitudeLongitude()

If validation fails, `MultiReleaseModeProcessor.parseReleaseParameters()` throws `IllegalArgumentException` with descriptive message.

Example error handling:

```java
try {
    Map<String, Object> releaseParams = MultiReleaseModeProcessor
            .parseReleaseParameters(releaseMode, request.getParameterMap());
    // ... process ...
} catch (IllegalArgumentException e) {
    // User input validation error - safe to show to user
    request.setAttribute("message", "VALIDATION ERROR: " + e.getMessage());
    request.getRequestDispatcher("/input_error.jsp").forward(request, response);
} catch (Exception e) {
    // System error - log and show generic message
    e.printStackTrace();
    request.setAttribute("message", "ERROR: System error processing your request");
    request.getRequestDispatcher("/system_error.jsp").forward(request, response);
}
```

## Backward Compatibility

The system defaults to "single" release mode:

1. If `release_mode` parameter not provided → uses "single"
2. Existing form submissions (without release_mode) work unchanged
3. Single-release processing uses existing code paths
4. New multi-release modes run through separate handlers

## Configuration Files Generated

For each submission, the system creates:

1. **release_config_UNIQ_ID.json**: Complete configuration in JSON format
   - All mode parameters
   - Particle distribution details
   - Validation metadata

2. **lwseed_UNIQ_ID.in**: Traditional simulation script format
   - NPART (particle count)
   - LAT/LON coordinates
   - IRELEASE index
   - Compatible with Ferret/GMT downstream

## Testing Checklist

- [ ] Single release mode processes correctly (backward compatibility)
- [ ] Multi-location with 2 locations works
- [ ] Multi-location with 5+ locations works
- [ ] Continuous source mode with 2-hour duration works
- [ ] Continuous source mode with 12-hour duration works
- [ ] Error handling for invalid coordinates
- [ ] Error handling for missing required parameters
- [ ] lwseed files generated in output directory
- [ ] JSON config files are valid and readable
- [ ] Existing simulation pipeline consumes generated lwseed files
- [ ] Particle visualization shows correct distribution per mode
