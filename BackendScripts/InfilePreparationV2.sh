#!/bin/bash
# InfilePreparationV2.sh - Multi-Release Seeding Mode Support
# Handles: Single Release, Multiple Location Release, Continuous Moving Source
# Updated: 2024 - SARAT V3

UNIQ_ID=$1
RELEASE_MODE=${2:-single}

if [ -z "$UNIQ_ID" ]; then
    echo "ERROR: UNIQ_ID not provided"
    exit 1
fi

echo "[InfilePrep] Starting for UNIQ_ID=$UNIQ_ID, MODE=$RELEASE_MODE"

SARAT_HOME="/home/osf/SearchAndRescueTool"
CASE_DIR="${SARAT_HOME}/case${UNIQ_ID}"
CONFIG_FILE="${SARAT_HOME}/webapp/data/${UNIQ_ID}/release_config_${UNIQ_ID}.json"

# Check for legacy single mode (backward compatibility)
if [ "$RELEASE_MODE" = "single" ] && [ ! -f "$CONFIG_FILE" ]; then
    echo "[InfilePrep] Legacy mode - using existing logic"
    cd "$SARAT_HOME"
    
    ObjectClass=$( awk '{print $1}' userinput.txt)
    IpLat=$(awk '{print $2}' userinput.txt)
    IpLon=$(awk '{print $3}' userinput.txt)
    StartDate=$(awk '{print $4,substr($5,0,5)}' userinput.txt)
    EndDate=$(awk '{print $6,substr($7,0,5)}' userinput.txt)
    
    SYear=$(date -d "+0 day $StartDate" '+%Y');SMonth=$(date -d "+0 day $StartDate" '+%m')
    SDate=$(date -d "+0 day $StartDate" '+%d');SHour=$(date -d "+0 day $StartDate" '+%H')    
    SMin=$(date -d "+0 day $StartDate" '+%M')
    EYear=$(date -d "+0 day $EndDate" '+%Y');EMonth=$(date -d "+0 day $EndDate" '+%m')
    EDate=$(date -d "+0 day $EndDate" '+%d');EHour=$(date -d "+0 day $EndDate" '+%H')
    EMin=$(date -d "+0 day $EndDate" '+%M')

start_sec=$(date -d "$StartDate" +%s)
    end_sec=$(date -d "$EndDate" +%s)
    duration_hours=$(( (end_sec - start_sec) / 3600 ))
    
    if [ "$duration_hours" -gt 24 ]; then
        seed_hours=12
    else
        seed_hours=6
    fi
    
    seed_end=$(date -d "$StartDate +$seed_hours hours" "+%Y %m %d %H %M")
    SeedYear=$(echo $seed_end | awk '{print $1}')
    SeedMonth=$(echo $seed_end | awk '{print $2}')
    SeedDate=$(echo $seed_end | awk '{print $3}')
    SeedHour=$(echo $seed_end | awk '{print $4}')
    SeedMin=$(echo $seed_end | awk '{print $5}')
    
    ltdeg=`echo $IpLat | sed 's/\./ /g' | awk '{print $1}'`
    ltdmin=.`echo $IpLat | sed 's/\./ /g' | awk '{print $2}'`
    ltmin=$(expr "$ltdmin * 60" | bc -l | awk '{print $1}')
    lodeg=`echo $IpLon | sed 's/\./ /g' | awk '{print $1}'`
    lodmin=.`echo $IpLon | sed 's/\./ /g' | awk '{print $2}'`
    lomin=$(expr "$lodmin * 60" | bc -l | awk '{print $1}')
    
    # Generate legacy format lwseed file
    echo "Leeway seeder - do not remove this lon
2.5
$lodeg
$lomin
$ltdeg
$ltmin
$lodeg
$lomin
$ltdeg
$ltmin
10
10
GSHHS
$ObjectClass
$SYear
$SMonth
$SDate
$SHour $SMin
$EYear
$EMonth
$EDate
$EHour $EMin
$SeedYear
$SeedMonth
$SeedDate
$SeedHour $SeedMin
0 0.0 0.0
0 0.0 0.0
0
3600
" > lwseed${UNIQ_ID}.in
    chmod 777 lwseed${UNIQ_ID}.in
    echo "[InfilePrep] Legacy lwseed file created"
    exit 0
fi

# New format modes - config file based
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found: $CONFIG_FILE"
    exit 1
fi

echo "[InfilePrep] Using JSON config file"
mkdir -p "$CASE_DIR"

case "$RELEASE_MODE" in
    "single")
        process_single_json_mode
        ;;
    "multi_location")
        process_multi_location_mode
        ;;
    "continuous_source")
        process_continuous_source_mode
        ;;
    *)
        echo "ERROR: Invalid release mode '$RELEASE_MODE'"
        exit 1
        ;;
esac

echo "[InfilePrep] Completed successfully"
exit 0

################################################################################
# NEW: Single Release from JSON
################################################################################

function process_single_json_mode() {
    echo "[InfilePrep] Processing Single Release (JSON)"
    
    LAT=$(jq -r '.seeding_configs[0].locations[0].latitude' "$CONFIG_FILE")
    LON=$(jq -r '.seeding_configs[0].locations[0].longitude' "$CONFIG_FILE")
    
    echo "[InfilePrep] Seeding from: $LAT, $LON"
    
    cat > "${CASE_DIR}/lwseed${UNIQ_ID}.in" << EOF
Leeway seeder - SARAT V3 Single Release
2.5
$LON
0.0
$LAT
0.0
$LON
0.0
$LAT
0.0
10.0
10.0
GSHHS
0
2024
01
15
08 00
2024
01
20
08 00
2024
01
15
20 00
0 0.0 0.0
0 0.0 0.0
0
3600
EOF
    chmod 777 "${CASE_DIR}/lwseed${UNIQ_ID}.in"
    echo "[InfilePrep] Single releases created"
}

################################################################################
# NEW: Multi-Location Release
################################################################################

function process_multi_location_mode() {
    echo "[InfilePrep] Processing Multi-Location"
    
    LOCATION_COUNT=$(jq -r '.seeding_configs[0].location_count' "$CONFIG_FILE")
    echo "[InfilePrep] Processing $LOCATION_COUNT locations"
    
    LWSEED="${CASE_DIR}/lwseed${UNIQ_ID}_multi.in"
    > "$LWSEED"
    
    for LOC_IDX in $(seq 0 $((LOCATION_COUNT - 1))); do
        LAT=$(jq -r ".seeding_configs[0].locations[$LOC_IDX].latitude" "$CONFIG_FILE")
        LON=$(jq -r ".seeding_configs[0].locations[$LOC_IDX].longitude" "$CONFIG_FILE")
        LOC_NUM=$((LOC_IDX + 1))
        
        echo "[InfilePrep] Location $LOC_NUM: $LAT, $LON"
        
        cat >> "$LWSEED" << EOF
# Location $LOC_NUM
Leeway seeder - SARAT V3 Multi-Location ($LOC_NUM/$LOCATION_COUNT)
2.5
$LON
0.0
$LAT
0.0
$LON
0.0
$LAT
0.0
10.0
10.0
GSHHS
0
2024
01
15
08 00
2024
01
20
08 00
2024
01
15
20 00
0 0.0 0.0
0 0.0 0.0
0
3600

EOF
    done
    
    chmod 777 "$LWSEED"
    echo "[InfilePrep] Multi-location file created"
}

################################################################################
# NEW: Continuous Moving Source
################################################################################

function process_continuous_source_mode() {
    echo "[InfilePrep] Processing Continuous Source"
    
    RELEASE_POINTS=$(jq -r '.seeding_configs[0].release_points_count' "$CONFIG_FILE")
    echo "[InfilePrep] Processing $RELEASE_POINTS release points"
    
    LWSEED="${CASE_DIR}/lwseed${UNIQ_ID}_continuous.in"
    TRAJECTORY="${CASE_DIR}/trajectory_${UNIQ_ID}.txt"
    > "$LWSEED"
    > "$TRAJECTORY"
    
    for POINT_IDX in $(seq 0 $((RELEASE_POINTS - 1))); do
        LAT=$(jq -r ".seeding_configs[0].release_points[$POINT_IDX].latitude" "$CONFIG_FILE")
        LON=$(jq -r ".seeding_configs[0].release_points[$POINT_IDX].longitude" "$CONFIG_FILE")
        TIME=$(jq -r ".seeding_configs[0].release_points[$POINT_IDX].release_time" "$CONFIG_FILE")
        POINT_NUM=$((POINT_IDX + 1))
        
        echo "[InfilePrep] Point $POINT_NUM @ $TIME: $LAT, $LON"
        
        cat >> "$LWSEED" << EOF
# Release point $POINT_NUM at $TIME
Leeway seeder - SARAT V3 Continuous ($POINT_NUM/$RELEASE_POINTS)
2.5
$LON
0.0
$LAT
0.0
$LON
0.0
$LAT
0.0
10.0
10.0
GSHHS
0
2024
01
15
08 00
2024
01
20
08 00
2024
01
15
20 00
0 0.0 0.0
0 0.0 0.0
0
3600

EOF
        
        echo "$POINT_NUM,$TIME,$LAT,$LON" >> "$TRAJECTORY"
    done
    
    chmod 777 "$LWSEED" "$TRAJECTORY"
    echo "[InfilePrep] Continuous file and trajectory created"
}
