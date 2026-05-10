#!/bin/bash
# InfilePreparationV2.sh - Updated for Multi-Release Seeding Modes
# Supports: Single Release (existing), Multiple Location Release (NEW), Continuous Moving Source (NEW)
# 
# Updated: 2024 - Multi-Release Seeding Implementation
# 
# Usage: bash InfilePreparationV2.sh <UNIQ_ID> [RELEASE_MODE]
#        Release modes: single, multi_location, continuous_source (default: single)

set -e

UNIQ_ID=$1
RELEASE_MODE=${2:-single}

if [ -z "$UNIQ_ID" ]; then
    echo "ERROR: UNIQ_ID not provided"
    echo "Usage: bash InfilePreparationV2.sh <UNIQ_ID> [RELEASE_MODE]"
    exit 1
fi

# Define directories
SARAT_HOME="/path/to/sarat"
CASE_DIR="${SARAT_HOME}/case${UNIQ_ID}"
DATA_DIR="${CASE_DIR}/data"
OUT_DIR="${CASE_DIR}/out_files"
DAT_DIR="${CASE_DIR}/dat_files"
XY_DIR="${CASE_DIR}/xy_files"
SCRIPT_DIR="${SARAT_HOME}/BackendScripts"
CONFIG_FILE="${SARAT_HOME}/webapp/data/${UNIQ_ID}/release_config_${UNIQ_ID}.json"

# Create directories if not exist
mkdir -p "$DATA_DIR" "$OUT_DIR" "$DAT_DIR" "$XY_DIR"

#################################################################################
# MULTI-RELEASE MODE DETECTION & DISPATCH
#################################################################################

echo "=== SARAT V3 Multi-Release Infile Preparation ==="
echo "Unique ID: $UNIQ_ID"
echo "Release Mode: $RELEASE_MODE"

case "$RELEASE_MODE" in
    "single")
        process_single_release
        ;;
    "multi_location")
        process_multi_location_release
        ;;
    "continuous_source")
        process_continuous_source_release
        ;;
    *)
        echo "ERROR: Invalid release mode '$RELEASE_MODE'"
        exit 1
        ;;
esac

echo "=== Processing Complete ==="
exit 0

#################################################################################
# CASE 1: SINGLE RELEASE MODE (Existing functionality)
#################################################################################

function process_single_release() {
    echo ""
    echo "--- Processing Single Release Mode ---"
    
    # Read JSON config
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "ERROR: Config file not found: $CONFIG_FILE"
        exit 1
    fi
    
    # Extract single location from JSON using jq
    LATITUDE=$(jq -r '.seeding_configs[0].locations[0].latitude' "$CONFIG_FILE")
    LONGITUDE=$(jq -r '.seeding_configs[0].locations[0].longitude' "$CONFIG_FILE")
    PARTICLE_COUNT=$(jq -r '.seeding_configs[0].particle_count' "$CONFIG_FILE")
    
    echo "Location: $LATITUDE, $LONGITUDE"
    echo "Particles: $PARTICLE_COUNT"
    
    # Existing land-ocean check
    echo "Running land-ocean check..."
    python3 "${SCRIPT_DIR}/LandCheckingFromConvexHullV2.py" \
        "$LATITUDE" "$LONGITUDE" "$UNIQ_ID" "$CASE_DIR"
    
    if [ $? -ne 0 ]; then
        echo "ERROR: Land check failed"
        exit 1
    fi
    
    # Generate XY points (existing logic)
    echo "Generating XY coordinate files..."
    bash "${SCRIPT_DIR}/GenerateXYpointsV2.sh" "$UNIQ_ID" "$LATITUDE" "$LONGITUDE"
    
    # Create lwseed input file
    create_lwseed_single "$LATITUDE" "$LONGITUDE" "$PARTICLE_COUNT"
    
    # Run hull segment calculation (existing logic)
    echo "Running hull segment calculation..."
    bash "${SCRIPT_DIR}/HullSegmentV2.sh" "$UNIQ_ID"
    
    echo "Single release mode processing complete"
}

#################################################################################
# CASE 2: MULTI-LOCATION RELEASE MODE (NEW)
#################################################################################

function process_multi_location_release() {
    echo ""
    echo "--- Processing Multiple Location Release Mode ---"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "ERROR: Config file not found: $CONFIG_FILE"
        exit 1
    fi
    
    # Extract number of locations
    LOCATION_COUNT=$(jq -r '.seeding_configs[0].location_count' "$CONFIG_FILE")
    PARTICLES_PER_LOC=$(jq -r '.seeding_configs[0].particles_per_location' "$CONFIG_FILE")
    
    echo "Number of locations: $LOCATION_COUNT"
    echo "Particles per location: $PARTICLES_PER_LOC"
    
    # Create composite lwseed file for multiple locations
    LWSEED_FILE="${CASE_DIR}/lwseed${UNIQ_ID}.in"
    > "$LWSEED_FILE"  # Clear file
    
    # Process each location
    declare -a LATITUDES
    declare -a LONGITUDES
    
    for LOC_IDX in $(seq 0 $((LOCATION_COUNT - 1))); do
        LAT=$(jq -r ".seeding_configs[0].locations[$LOC_IDX].latitude" "$CONFIG_FILE")
        LON=$(jq -r ".seeding_configs[0].locations[$LOC_IDX].longitude" "$CONFIG_FILE")
        LOC_NUM=$((LOC_IDX + 1))
        
        echo "Location $LOC_NUM: $LAT, $LON"
        
        # Land-ocean check for each location
        echo "  Running land-ocean check for location $LOC_NUM..."
        python3 "${SCRIPT_DIR}/LandCheckingFromConvexHullV2.py" \
            "$LAT" "$LON" "${UNIQ_ID}_loc${LOC_NUM}" "$CASE_DIR"
        
        if [ $? -ne 0 ]; then
            echo "ERROR: Land check failed for location $LOC_NUM"
            exit 1
        fi
        
        LATITUDES[$LOC_IDX]=$LAT
        LONGITUDES[$LOC_IDX]=$LON
        
        # Append to composite lwseed file
        echo "NPART $PARTICLES_PER_LOC" >> "$LWSEED_FILE"
        echo "LAT $LAT" >> "$LWSEED_FILE"
        echo "LON $LON" >> "$LWSEED_FILE"
        echo "LKUNITS 0" >> "$LWSEED_FILE"
        echo "IRELEASE $LOC_NUM" >> "$LWSEED_FILE"
        echo "" >> "$LWSEED_FILE"
    done
    
    echo "Created composite lwseed file: $LWSEED_FILE"
    echo "Total locations: $LOCATION_COUNT"
    echo "Total particles: $((PARTICLES_PER_LOC * LOCATION_COUNT))"
    
    # Generate XY points for all locations combined
    echo "Generating XY coordinate files..."
    # Create merged XY files representing all locations
    create_xy_multi_location "${LATITUDES[@]}" "${LONGITUDES[@]}"
    
    # Run hull segment calculation with multi-location consideration
    echo "Running hull segment calculation for multi-location mode..."
    bash "${SCRIPT_DIR}/HullSegmentV2.sh" "$UNIQ_ID" "multi"
    
    echo "Multiple location release mode processing complete"
}

#################################################################################
# CASE 3: CONTINUOUS MOVING SOURCE MODE (NEW)
#################################################################################

function process_continuous_source_release() {
    echo ""
    echo "--- Processing Continuous Moving Source Release Mode ---"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "ERROR: Config file not found: $CONFIG_FILE"
        exit 1
    fi
    
    # Extract trajectory information
    RELEASE_POINTS=$(jq -r '.seeding_configs[0].release_points_count' "$CONFIG_FILE")
    PARTICLES_PER_POINT=$(jq -r '.seeding_configs[0].particles_per_release_point' "$CONFIG_FILE")
    INTERPOLATION_INTERVAL=$(jq -r '.seeding_configs[0].interpolation_interval_minutes' "$CONFIG_FILE")
    
    echo "Release points along trajectory: $RELEASE_POINTS"
    echo "Particles per release point: $PARTICLES_PER_POINT"
    echo "Interpolation interval: ${INTERPOLATION_INTERVAL} minutes"
    
    # Create trajectory lwseed file
    LWSEED_FILE="${CASE_DIR}/lwseed${UNIQ_ID}_continuous.in"
    TRAJECTORY_FILE="${CASE_DIR}/trajectory_${UNIQ_ID}.txt"
    > "$LWSEED_FILE"  # Clear file
    > "$TRAJECTORY_FILE"
    
    # Process each release point along the trajectory
    declare -a TRAJECTORY_LATS
    declare -a TRAJECTORY_LONS
    declare -a TRAJECTORY_TIMES
    
    for POINT_IDX in $(seq 0 $((RELEASE_POINTS - 1))); do
        LAT=$(jq -r ".seeding_configs[0].release_points[$POINT_IDX].latitude" "$CONFIG_FILE")
        LON=$(jq -r ".seeding_configs[0].release_points[$POINT_IDX].longitude" "$CONFIG_FILE")
        TIME=$(jq -r ".seeding_configs[0].release_points[$POINT_IDX].release_time" "$CONFIG_FILE")
        POINT_NUM=$((POINT_IDX + 1))
        
        echo "Release point $POINT_NUM ($TIME): $LAT, $LON"
        
        # Land check for each point (can be relaxed or skipped if trajectory over ocean)
        # For continuous mode, we validate only specific points (start, end, milestones)
        if [ $POINT_IDX -eq 0 ] || [ $POINT_IDX -eq $((RELEASE_POINTS - 1)) ]; then
            python3 "${SCRIPT_DIR}/LandCheckingFromConvexHullV2.py" \
                "$LAT" "$LON" "${UNIQ_ID}_release${POINT_NUM}" "$CASE_DIR"
            
            if [ $? -ne 0 ]; then
                echo "WARNING: Land check issue at release point $POINT_NUM (continuing anyway)"
            fi
        fi
        
        TRAJECTORY_LATS[$POINT_IDX]=$LAT
        TRAJECTORY_LONS[$POINT_IDX]=$LON
        TRAJECTORY_TIMES[$POINT_IDX]=$TIME
        
        # Append to lwseed file
        echo "# Release point $POINT_NUM at $TIME" >> "$LWSEED_FILE"
        echo "NPART $PARTICLES_PER_POINT" >> "$LWSEED_FILE"
        echo "LAT $LAT" >> "$LWSEED_FILE"
        echo "LON $LON" >> "$LWSEED_FILE"
        echo "LKUNITS 0" >> "$LWSEED_FILE"
        echo "IRELEASE $POINT_NUM" >> "$LWSEED_FILE"
        echo "" >> "$LWSEED_FILE"
        
        # Write to trajectory file (for visualization/debugging)
        echo "$POINT_NUM,$TIME,$LAT,$LON" >> "$TRAJECTORY_FILE"
    done
    
    echo "Created continuous lwseed file: $LWSEED_FILE"
    echo "Trajectory file: $TRAJECTORY_FILE"
    echo "Total release points: $RELEASE_POINTS"
    echo "Total particles: $((PARTICLES_PER_POINT * RELEASE_POINTS))"
    
    # Generate XY points along trajectory
    echo "Generating XY coordinate files along trajectory..."
    create_xy_continuous_trajectory "${TRAJECTORY_LATS[@]}" "${TRAJECTORY_LONS[@]}"
    
    # Run hull segment calculation with trajectory consideration
    echo "Running hull segment calculation for continuous trajectory mode..."
    bash "${SCRIPT_DIR}/HullSegmentV2.sh" "$UNIQ_ID" "continuous"
    
    echo "Continuous moving source release mode processing complete"
}

#################################################################################
# HELPER FUNCTIONS - LWSEED GENERATION
#################################################################################

function create_lwseed_single() {
    local lat=$1
    local lon=$2
    local particles=$3
    local lwseed_file="${CASE_DIR}/lwseed${UNIQ_ID}.in"
    
    cat > "$lwseed_file" << EOF
NPART $particles
LAT $lat
LON $lon
LKUNITS 0
IRELEASE 1
EOF
    
    echo "Created lwseed file: $lwseed_file"
}

#################################################################################
# HELPER FUNCTIONS - XY COORDINATE GENERATION
#################################################################################

function create_xy_multi_location() {
    local -a lats=("${@:1:$((${#@}/2))}") 
    local -a lons=("${@:$((${#@}/2+1))}")
    
    # Generate XY files for each location
    for i in "${!lats[@]}"; do
        LAT=${lats[$i]}
        LON=${lons[$i]}
        LOC_NUM=$((i + 1))
        
        echo "Generating XY for location $LOC_NUM: $LAT, $LON"
        
        # Can use existing script or create merged output
        bash "${SCRIPT_DIR}/GenerateXYpointsV2.sh" \
            "${UNIQ_ID}_loc${LOC_NUM}" "$LAT" "$LON"
    done
}

function create_xy_continuous_trajectory() {
    local -a lats=("${@:1:$((${#@}/2))}") 
    local -a lons=("${@:$((${#@}/2+1))}")
    
    # Generate XY files representing the continuous trajectory
    local trajectory_xy="${XY_DIR}/continuous_trajectory_${UNIQ_ID}.txt"
    > "$trajectory_xy"
    
    echo "Writing trajectory XY points to: $trajectory_xy"
    
    for i in "${!lats[@]}"; do
        LAT=${lats[$i]}
        LON=${lons[$i]}
        echo "$LON $LAT" >> "$trajectory_xy"  # GMT/Ferret format: LON LAT
    done
}

#################################################################################
# MAIN EXECUTION
#################################################################################

# Source this script for execution
# process_single_release handler is called at top level
# Additional handlers dispatch from main case statement
