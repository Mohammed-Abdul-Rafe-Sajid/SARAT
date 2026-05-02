#!/bin/bash
cd /home/osf/SearchAndRescueTool/
##################################################################
#This Program is to create a IN file for Model Input             #
#            -by OSF Team                                        #
#                                                                #
##################################################################

###Mysql Query To Access User Inputs
echo "mysql -u osf -posf_sar -h 172.16.1.78 -e"\"" use db_sar;select missed_object,loc_lat,loc_long,miss_date_from,miss_date_to from inputs order by request_date DESC limit 1;\"" >query.sh
#chmod +x query.sh;./query.sh >log
#rm query.sh
	ObjectClass=$( awk '{print $1}' userinput.txt);
	IpLat=$(awk '{print $2}' userinput.txt );IpLon=$( awk '{print $3}' userinput.txt);
	StartDate=$(awk '{print $4,substr($5,0,5)}' userinput.txt);EndDate=$(awk '{print $6,substr($7,0,5)}' userinput.txt)
##Formating Start Date into lwseed.in Format 
	SYear=$(date -d "+0 day $StartDate" '+%Y');SMonth=$(date -d "+0 day $StartDate" '+%m')
	SDate=$(date -d "+0 day $StartDate" '+%d');SHour=$(date -d "+0 day $StartDate" '+%H')	
	SMin=$(date -d "+0 day $StartDate" '+%M')
##Formating End Date into lwseed.in Format 
	EYear=$(date -d "+0 day $EndDate" '+%Y');EMonth=$(date -d "+0 day $EndDate" '+%m')
	EDate=$(date -d "+0 day $EndDate" '+%d');EHour=$(date -d "+0 day $EndDate" '+%H')
	EMin=$(date -d "+0 day $EndDate" '+%M')

##Compute Dynamic Seeding Duration
	# Convert dates to seconds for duration calculation
	start_sec=$(date -d "$StartDate" +%s)
	end_sec=$(date -d "$EndDate" +%s)
	
	# Compute duration in hours
	duration_hours=$(( (end_sec - start_sec) / 3600 ))
	
	# Decide seeding duration: 12 hours if > 24 hrs simulation, else 6 hours
	if [ "$duration_hours" -gt 24 ]; then
	    seed_hours=12
	else
	    seed_hours=6
	fi
	
	# Compute seeding end datetime
	seed_end=$(date -d "$StartDate +$seed_hours hours" "+%Y %m %d %H %M")
	
	# Extract seeding end components
	SeedYear=$(echo $seed_end | awk '{print $1}')
	SeedMonth=$(echo $seed_end | awk '{print $2}')
	SeedDate=$(echo $seed_end | awk '{print $3}')
	SeedHour=$(echo $seed_end | awk '{print $4}')
	SeedMin=$(echo $seed_end | awk '{print $5}')
	
	# Debug output
	echo "DEBUG: Simulation duration: $duration_hours hours"
	echo "DEBUG: Seeding duration: $seed_hours hours"
	echo "DEBUG: Seeding end: $SeedYear-$SeedMonth-$SeedDate $SeedHour:$SeedMin"

#Formatting Lat Lon into lwseed.in Format
  ltdeg=`echo $IpLat  | sed 's/\./ /g' | awk '{print $1}'`;
  ltdmin=.`echo $IpLat  | sed 's/\./ /g' | awk '{print $2}'`
  ltmin=$(expr "$ltdmin * 60" | bc -l |  awk '{print $1}');
  lodeg=`echo $IpLon  | sed 's/\./ /g' | awk '{print $1}'`;
  lodmin=.`echo $IpLon | sed 's/\./ /g' | awk '{print $2}'`
  lomin=$(expr "$lodmin * 60" | bc -l | awk '{print $1}');
#
echo "Leeway seeder - do not remove this lon
2.5     # Leeway version - do not remove this lon
$lodeg       # startLon  [deg]             (int)
$lomin   #startLon  [decimal minutes] (float)
$ltdeg    # startLat  [deg]             (int)
$ltmin  # startLat  [decimal minutes] (float)
$lodeg       # endLon    [deg]             (int)
$lomin  # endLon    [decimal minutes] (float)
$ltdeg      # endLat    [deg]             (int)
$ltmin   #endLat    [decimal minutes] (float)
10   # startRad  [km]              (float)
10   # endRad    [km]              (float)
GSHHS   # Optional object description - do not remove this lon
$ObjectClass      # objectClassId               (int)
$SYear    # startDate [year]            (int)
$SMonth      # startDate [month]           (int)
$SDate      # startDate [day]             (int)
$SHour $SMin   # startDate [hh mm]            (int)
$EYear    # endDate   [year]            (int)
$EMonth      # endDate   [month]           (int)
$EDate     # endDate   [day]             (int)
$EHour $EMin  # endDate   [hh mm]            (int)
$SeedYear    # seedingEnd - [year]       (int)
$SeedMonth   # seedingEnd - [month]      (int)
$SeedDate    # seedingEnd - [day]        (int)
$SeedHour $SeedMin   # seedingEnd - [hh mm]           (int)
0 0.0 0.0 # Constant current, east and north components [m/s] (true=1, false=0)
0 0.0 0.0 # Constant wind, east and north components [m/s] (true=1, false=0)
0         # Particles do not strand (true=1, false=0)
3600      # Output timestep, must be multiple of model timestep [seconds]
" >lwseed$1.in
chmod 777 lwseed$1.in
