#!/bin/bash
# RunSARInputCreationV2_MultiRelease.sh
# Enhanced for multi-release seeding modes
# Integrates: MultiReleaseHandler.py → InfilePreparationV2.sh → Simulation Pipeline
# 
# Usage: bash RunSARInputCreationV2_MultiRelease.sh <UNIQ_ID> [RELEASE_MODE]

UNIQ_ID=$1
RELEASE_MODE=${2:-single}

SARAT_HOME="/home/osf/SearchAndRescueTool"
CASE_DIR="${SARAT_HOME}/case${UNIQ_ID}"
SCRIPT_DIR="${SARAT_HOME}/BackendScripts"
LOG_DIR="${CASE_DIR}/logs"

mkdir -p "$LOG_DIR"

echo "=========================================="
echo "SARAT V3 Multi-Release Simulation Pipeline"
echo "=========================================="
echo "Case ID: $UNIQ_ID"
echo "Release Mode: $RELEASE_MODE"
echo "Start Time: $(date)"
echo ""

###############################################################################
# PHASE 1: Validate Locations (Multi-LKP)
###############################################################################

echo "[Phase 1] Multi-Location Validation"

CONFIG_FILE="${SARAT_HOME}/webapp/data/${UNIQ_ID}/release_config_${UNIQ_ID}.json"

if [ "$RELEASE_MODE" != "single" ] && [ -f "$CONFIG_FILE" ]; then
    echo "Running MultiLKPValidator.py..."
    python3 "${SCRIPT_DIR}/MultiLKPValidator.py" "$CONFIG_FILE" \
        "${LOG_DIR}/validation_report.json"
    
    if [ $? -ne 0 ]; then
        echo "ERROR: Location validation failed"
        exit 1
    fi
    echo "✓ All locations validated"
else
    if [ "$RELEASE_MODE" = "single" ]; then
        echo "Single mode - using existing land check (integrated in InfilePrep)"
    fi
fi

###############################################################################
# PHASE 2: Generate Infile (lwseed)
###############################################################################

echo ""
echo "[Phase 2] Generate lwseed Input File"
echo "Executing InfilePreparationV2.sh..."

cd "$SARAT_HOME"
bash "${SCRIPT_DIR}/InfilePreparationV2.sh" "$UNIQ_ID" "$RELEASE_MODE"

if [ $? -ne 0 ]; then
    echo "ERROR: lwseed generation failed"
    exit 1
fi

# Verify lwseed file was created
LWSEED_FILE=$(find "$CASE_DIR" -name "lwseed${UNIQ_ID}*.in" -type f | head -1)
if [ -z "$LWSEED_FILE" ]; then
    echo "ERROR: lwseed file not found"
    exit 1
fi

echo "✓ lwseed file created: $LWSEED_FILE"
echo "✓ File size: $(wc -c < "$LWSEED_FILE") bytes"

###############################################################################
# PHASE 3: Run Existing Simulation Pipeline
###############################################################################

echo ""
echo "[Phase 3] Execute Simulation Pipeline"
echo "Mode: $RELEASE_MODE"

# Mode-specific processing
case "$RELEASE_MODE" in
    "single")
        echo "Processing Single Release..."
        bash "${SCRIPT_DIR}/RunSARBulletinCreationV2.sh" "$UNIQ_ID"
        ;;
    
    "multi_location")
        echo "Processing Multiple Location Release..."
        # Run simulation with multi-LKP support
        bash "${SCRIPT_DIR}/RunSARBulletinCreationV2.sh" "$UNIQ_ID" "multi"
        ;;
    
    "continuous_source")
        echo "Processing Continuous Moving Source..."
        # Run simulation with trajectory support
        bash "${SCRIPT_DIR}/RunSARBulletinCreationV2.sh" "$UNIQ_ID" "continuous"
        ;;
    
    *)
        echo "ERROR: Unknown release mode: $RELEASE_MODE"
        exit 1
        ;;
esac

if [ $? -ne 0 ]; then
    echo "ERROR: Simulation pipeline failed"
    exit 1
fi

echo "✓ Simulation pipeline completed successfully"

###############################################################################
# PHASE 4: Post-Processing & Visualization
###############################################################################

echo ""
echo "[Phase 4] Post-Processing"

# Generate GeoJSON for visualization
if [ -f "${SARAT_HOME}/sarat_new_visualization_changes/generate_geojson_index.py" ]; then
    echo "Generating GeoJSON visualization files..."
    python3 "${SARAT_HOME}/sarat_new_visualization_changes/generate_geojson_index.py" \
        "$CASE_DIR"
    
    if [ $? -eq 0 ]; then
        echo "✓ GeoJSON files generated"
    fi
fi

###############################################################################
# PHASE 5: Summary & Completion
###############################################################################

echo ""
echo "[Phase 5] Job Summary"
echo "=========================================="

# Check output files
PROBABILITY_FILE=$(find "$CASE_DIR/out_files" -name "*probability*" -type f 2>/dev/null | head -1)
TRAJECTORY_FILE=$(find "$CASE_DIR/out_files" -name "*trajectory*" -type f 2>/dev/null | head -1)

if [ -n "$PROBABILITY_FILE" ]; then
    echo "✓ Probability map: $PROBABILITY_FILE"
fi

if [ -n "$TRAJECTORY_FILE" ]; then
    echo "✓ Trajectory output: $TRAJECTORY_FILE"
fi

# Summary
echo ""
echo "Case ID: $UNIQ_ID"
echo "Release Mode: $RELEASE_MODE"
echo "Output Directory: $CASE_DIR"
echo "Completion Time: $(date)"
echo ""
echo "✓ Processing completed successfully"
echo "=========================================="

exit 0
