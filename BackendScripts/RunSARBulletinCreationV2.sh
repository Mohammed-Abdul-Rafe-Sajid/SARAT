#!/bin/bash
cd /home/osf/SearchAndRescueTool/

# Generate time-based probability images with rectangular bounding boxes
PYTHON_SCRIPT="/home/osf/SearchAndRescueTool/sarat_new_visualization_changes/saratv3visuals.py"
if [ -f "$PYTHON_SCRIPT" ]; then
    python3 "$PYTHON_SCRIPT" "$1" "."
else
    # Fallback to local Windows test path
    PYTHON_SCRIPT="d:/osama/INCOIS/SARAT/sarat_new_visualization_changes/saratv3visuals.py"
    if [ -f "$PYTHON_SCRIPT" ]; then
        # When running locally, point inputpath to the specific case folder
        python3 "$PYTHON_SCRIPT" "$1" "d:/osama/INCOIS/SARAT/sarat_new_visualization_changes/case${1}"
    fi
fi

ps=firstpage_$1.ps
Uncertain=10;

/usr/local/bin/gmt gmtset BASEMAP_TYPE=plain  PAPER_MEDIA custom_595x842 PAGE_ORIENTATION landscape
# gmt gmtset BASEMAP_TYPE=plain  PAPER_MEDIA custom_595x842
/usr/local/bin/gmt psbasemap -R76/98/13/28 -JM7.5i   -G -V -P -K  -X1.5 -Y2.5  -B+t"" >$ps
#psimage incois.ps -C17/24.5 -W4/2 -E130 -O -K -V -P >>$ps
#psimage esso.ps -C15/24.8 -W1.5/1.3 -E100 -O -K -V -P >>$ps

# The following line was displaying the earlier colorbar
#gmt psimage new_scale.ps -D0/-2 -E80 -O -K -V -P >>$ps
#gmt psimage SaratColorScale.ps -D0/-2 -E80 -O -K -V -P >>$ps

#psimage new_scale.ps -C0/-2 -W1/1 -E70 -O -K -V -P >>$ps
/usr/local/bin/gmt psimage sarat_final.ps -D0/23  -E1000 -O -K -V -P >>$ps
##
gmtregion="gmtregion_$1.txt"
TopProb=( $(awk '{printf "%.3f\n", $1}' $gmtregion |  sort | uniq  | tail -2 |  awk '{printf "%.2f\n", $1}'  | paste -s) )
#/usr/bin/javac MissingObject.java  
/usr/bin/java MissingObject $4 >ObjectName_$1.txt
##
echo "87 39.3 19 0 5 MC SARAT" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G -F+f0/0/255  >>$ps
echo "87 38.8 14 0 5 MC Search And Rescue Aid Tool" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
echo "87 38.4 10 0 5 MC ESSO-INDIAN NATIONAL CENTRE FOR OCEAN INFORMATION SERVICES" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
echo "87 37.5 10 0 5 MC ISO 9001 : 2008 Certified  Ocean State Forecast Services" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
echo "87 38 10 0 5 MC (Ministry of Earth Sciences, Government of India)" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
#echo "Based upon the SARAT simulations, REGION 1 indicate the most probable Search Region which has maximum  probability of  50%  for locating and/or rescuing the object. REGION 2 indicate the second most probable Search Region of 40% ." | fold -w 95 -s >subject.txt
# echo "Based upon the SARAT simulations (particle plot overlayed below), REGION 1 indicate the most probable Search Region which has maximum  probability of  $( echo "${TopProb[1]} * 100" | bc -l ) %  for locating and/or rescuing the object. REGION 2 indicate the second most probable Search Region of $( echo "${TopProb[0]} * 100" | bc -l ) % ." | fold -w 95 -s >subject.txt
echo "Based upon the SARAT simulations, REGION 1 indicate the most probable Search Region which has maximum  probability of  $( echo "${TopProb[1]} * 100" | bc -l ) %  for locating and/or rescuing the object. REGION 2 indicate the second most probable Search Region of $( echo "${TopProb[0]} * 100" | bc -l ) % ." | fold -w 95 -s >subject.txt
echo "87 10 10 0 5 MC The model simulation has been done with $Uncertain km Uncertainity in Initial Condition" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
echo "87 36.4 13 0 5 MC Search and Rescue  Advisory for Missing Object -$(cat ObjectName_$1.txt)" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R >>$ps

inputLon="$2"
inputLat="$3"

# Convert lat/long to degrees, minutes, seconds for display
ltdeg=`echo $inputLat | awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}'`;
ltdmin=.`echo $inputLat | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
ltmin=$(expr "$ltdmin * 60" | bc -l |  awk '{print $1}');
ltdsec=.`echo $ltmin | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
ltmin=$(expr "$ltdmin * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}' );
ltsec=$(expr "$ltdsec * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}');
###LON
lodeg=`echo $inputLon | awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}'`;
lodmin=.`echo $inputLon | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
lomin=$(expr "$lodmin * 60" | bc -l | awk '{print $1}');
lodsec=.`echo $lomin | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
lomin=$(expr "$lodmin * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}' );
losec=$(expr "$lodsec * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}');

echo "77 33.6 11 0 5 BL Last Known Position is Longitude: ${lodeg} deg ${lomin} mins ${losec} secs (${inputLon} deg), Latitude: ${ltdeg} deg ${ltmin} mins ${ltsec} secs (${inputLat} deg)" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -Ff40/40/40 >>$ps
echo "77 32.6 11 0 5 BL Advisory generated on: $(date +%d/%m/%Y) $(date +%H:%M) hrs IST          Valid Upto : $(date -d "0 day $(awk '{print $6}' userinput_$1.txt)" '+%d/%m/%Y') $(awk '{print substr($7,0,5)}' userinput_$1.txt) hrs IST" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -Ff40/40/40 >>$ps
#echo "83.8 34.5 11 0 5 MC Advisory generated on : $(date +%H:%M) hours IST Dated: $(date +%d/%m/%Y)" | pstext -JM7.5i -N -O -K -R -G0/0/0 >>$ps
#echo "78 33.5 11 0 5 BL  Valid Upto : $(date -d "0 day $(awk '{print $6}' userinput.txt)" '+%d/%m/%Y') $(awk '{print substr($7,0,5)}' userinput.txt) hrs IST" | pstext -JM7.5i -N -O -K -R -G0/0/0 >>$ps
#echo "78 33.5 11 0 5 BL  Valid Upto : $(awk '{print substr($7,0,5)}' userinput.txt) hours IST Dated: $(date -d "0 day $(awk '{print $6}' userinput.txt)" '+%d/%m/%Y')" | pstext -JM7.5i -N -O -K -R -G0/0/0 >>$ps
#	psscale -D3.3i/0.5i/14.0c/0.3ch -O -Ccolor.cpt -K  >>$ps
#echo "79.7 35 10 0 5 BL Sub: " | pstext -JM7.5i -N -O -K -R -G0/0/0 >>$ps
long=35.5
while read line
do
echo "76 $long 11 0 5 BL $line" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
long=`echo $long - 0.5 | bc`
done <subject.txt
###
awk '
function max(x){i=0;for(val in x){if(i<=x[val]){i=x[val];}}return i;}
function min(x){i=max(x);for(val in x){if(i>x[val]){i=x[val];}}return i;}
{a[$1]=$1;next}
END{minimum=min(a);maximum=max(a);iin=min(b);ax=max(b);print minimum" "maximum}' finalconvexhull_$1.dat >lon.txt

awk '
function max(x){i=0;for(val in x){if(i<=x[val]){i=x[val];}}return i;}
function min(x){i=max(x);for(val in x){if(i>x[val]){i=x[val];}}return i;}
{a[$1]=$2;next}
END{minimum=min(a);maximum=max(a);iin=min(b);ax=max(b);print minimum" "maximum}' finalconvexhull_$1.dat >lat.txt

xx1=$(awk '{print $1}' lon.txt)
xx2=$(awk '{print $2}' lon.txt)
yy1=$(awk '{print $1}' lat.txt)
yy2=$(awk '{print $2}' lat.txt)

x1=$( echo "$xx1 - 0.2" | bc -l  );x2=$( echo "$xx2 + 0.2" | bc -l  )
y1=$( echo "$yy1 - 0.2" | bc  -l );y2=$( echo "$yy2 + 0.2" | bc -l )

#y=$3;x=$2
#x1=$( echo "$x - 2" | bc -l  );x2=$( echo "$x + 2" | bc -l  )
#y1=$( echo "$y - 2" | bc  -l );y2=$( echo "$y + 2" | bc -l )
echo -R$x1/$x2/$y1/$y2
##Setting Colour Codes for each Probability
#declare -A Col=( [0.1]=-G0/0/139 [0.2]=-G255/140/0 [0.3]=-G102/0/255 [0.4]=-G238/130/238 [0.5]=-G255/20/147 [0.6]=-G0/100/0 [0.7]=-G128/0/128 [0.8]=-G255/0/0 [0.9]=-G153/51/255 [1.0]=-G64/244/208)
#declare -A Col=( [0.05]=-G1/70/54 [0.10]=-G5/88/67 [0.15]=-G3/103/82 [0.20]=-G0/114/100 [0.25]=-G0/123/120 [0.30]=-G7/130/144 [0.35]=-G31/136/169 [0.40]=-G51/142/190 [0.45]=-G70/152/201 [0.50]=-G91/163/205 [0.55]=-G116/173/208 [0.60]=-G143/182/214 [0.65]=-G168/190/219 [0.70]=-G188/198/224 [0.75]=-G204/206/228 [0.80]=-G217/214/233 [0.85]=-G229/221/237 [0.90]=-G239/228/241 [0.95]=-G247/236/246 [1.0]=-G255/247/251)
# declare -A Col=( [0.05]=-G255/247/251 [0.10]=-G247/236/246 [0.15]=-G239/228/241 [0.20]=-G229/221/237 [0.25]=-G217/214/233 [0.30]=-G204/206/228 [0.35]=-G188/198/224 [0.40]=-G168/190/219 [0.45]=-G143/182/214 [0.50]=-G116/173/208 [0.55]=-G91/163/205 [0.60]=-G70/152/201 [0.65]=-G51/142/190 [0.70]=-G31/136/169 [0.75]=-G7/130/144 [0.80]=-G0/123/120 [0.85]=-G0/114/100 [0.90]=-G3/103/82 [0.95]=-G5/88/67 [1.0]=-G1/70/54)

declare -A Col=( [0.05]=-G255/254/215 [0.10]=-G254/228/148 [0.15]=-G254/194/77 [0.20]=-G248/135/31 [0.25]=-G251/181/154 [0.30]=-G243/68/48 [0.35]=-G208/27/30 [0.40]=-G158/53/3 [0.45]=-G151/215/183 [0.50]=-G94/189/209 [0.60]=-G46/144/192 [0.70]=-G2/98/168 [0.80]=-G0/0/255 [0.90]=-G64/64/64 [1.0]=-G0/0/0)
ProXY=( `ls proval-*-$1.xy` )

# Options for pscoast: https://docs.generic-mapping-tools.org/6.3/pscoast.html#b
# -P: Portrait plot orientation
# -K: Says more plots will be appended later
# -O: Overlay plot mode
# +Df: Resolution selection
# -G: Fill (Here NavajoWhite specifies pen color)
# -JM10: Means 10 inches plot size

# Display the time-evolution combined probability image generated by Python
IMG_FILE="figure/seeding_duration_${1}_combined.png"
if [ ! -f "$IMG_FILE" ]; then
    # Fallback to local test path if on windows
    IMG_FILE="d:/osama/INCOIS/SARAT/sarat_new_visualization_changes/case${1}/figure/seeding_duration_${1}_combined.png"
fi

if [ -f "$IMG_FILE" ]; then
    # Set the origin to where the map should be without drawing a frame
    /usr/local/bin/gmt psbasemap -R$x1/$x2/$y1/$y2 -JM10 -K -O -X1 -Y2.5 >> $ps
    # Place the high-res Python combined image onto the GMT map
    /usr/local/bin/gmt psimage "$IMG_FILE" -Dx0/0+w10i -O -K >> $ps
    
    # We skip plotting the old pscoast, psxy polygons, LKP markers, and the old colorbar, 
    # because the python image contains all of these baked into it.
else
    # --- FALLBACK: OLD GMT PLOTTING ---
    # gmt pscoast -R$x1/$x2/$y1/$y2  -JM10  -K  -O -B0.9WNseg0.3  -Df -P -GNavajoWhite -Wthick  -X1 -Y2.5 >> $ps
    /usr/local/bin/gmt pscoast -R$x1/$x2/$y1/$y2  -JM10  -K  -O -Bg0.3 -BWSne -Ba0.3 -Df -P -GNavajoWhite -Wthick  -X1 -Y2.5 >> $ps
    # gmt pscoast -R$x1/$x2/$y1/$y2  -JM10  -K  -O -B0.9WNseg0.3  -Df -P -GNavajoWhite -Wthick >> $ps
    for (( i=0;i<${#ProXY[@]};i++ ));do
            G=${Col[$(echo ${ProXY[$i]} | sed 's/-/ /g' | awk '{print $2}')]}
            /usr/local/bin/gmt psxy  ${ProXY[$i]} -R -J -W0.2 $G -B -O -K  >>$ps
    done

    # # Empty the temporary file
    # complete_traj_tmp_file="complete_traj_tmp_$1.dat"
    # cat /dev/null > "${complete_traj_tmp_file}"
    # while read -r line
    # do
    #         if [ -n "$line" ]
    #         then
    #                 ## $line is not empty
    #                 echo "$line" >> "${complete_traj_tmp_file}"
    #         else
    #                 ## Draw a trajectory
    #                 #sync
    #                 #sleep 1
    #                 /usr/local/bin/gmt psxy "${complete_traj_tmp_file}" -R -J -W0.2,169/169/169 -O -K  >>$ps
    #                 # echo > "${complete_traj_tmp_file}"
    #                 cat /dev/null > "${complete_traj_tmp_file}"
    #         fi
    # done < "complete_traj_$1.dat"



    /usr/local/bin/gmt pstext -J -O -K -R  -GWhite -N >>$ps<<END
${inputLon} ${inputLat} 18 0 1 MC .
END


    #82.96075 12.6471 18 0 1 MC .
    /usr/local/bin/gmt psxy  -R -J -SE-  -W5,255/255/255 -B -O -K  >>$ps<<END
${inputLon} ${inputLat} 0 $Uncertain $Uncertain 
END

    # inlon=$(echo "${inputLon} + 0.1" | bc -l )

    inlon=$(echo "${inputLon} + 0.02" | bc -l )
    #echo "$inlon $3 10 0 5 MC Initial Position " | /usr/local/bin/gmt pstext -J -N -O -K -R -G -F+f255/255/255 >>$ps

    # Karthik-change
    # echo "$inlon $3 10 0 5 MC Last Known Position($2, $3)" | /usr/local/bin/gmt pstext -J -N -O -K -R -G -F+f10p,Helvetica,black >>$ps
    # echo "${inlon} ${inputLat} 10 0 5 ML Last Known Position(${lodeg}deg${lomin}mins${losec}secs,${ltdeg}deg${ltmin}mins${ltsec}secs)" | /usr/local/bin/gmt pstext -J -N -O -K -R -G -F+f10p,Helvetica,black >>$ps

    echo "${inlon} ${inputLat} 10 0 5 ML Last Known Position" | /usr/local/bin/gmt pstext -J -N -O -K -R -G -F+f10p,Helvetica,black >>$ps

    #inlon=$2
    #echo "$2 $3 10 0 5 MC Initial Position " | /usr/local/bin/gmt pstext -J -N -O -K -R -G -F+f255/255/255 >>$ps
    <<COM
    psxy  -R -J -Sd0.3 -GBlack -B -O -K -M >>$ps<<END
    83.0175 12.6238
    83.0708 13.1475
END
    echo "82.9 12.4238 10 0 5 BL SAGAR" | pstext -JM7.5i -N -O -K -R -G0/0/0 >>$ps
    echo "82.9 12.88 10 0 5 BL PEBRE" | pstext -JM7.5i -N -O -K -R -G0/0/0 >>$ps
COM

    #gmt psscale -CPuBuGnColorBar.cpt -Dx1i/1i+w4i/0.5i+h -Ba -B+tdiscrete >>$ps
    #gmt colorbar -D8.5i/11i+0.5i/1i -CPuBuGnColorBar.cpt -Ba -B+tdiscrete >>$ps
    # gmt psscale -CPuBuGnColorBarReversedWithNewLabels.cpt -O -Dx-1c/-2c+w18c/1c+h -Bx+l"Probability Scale" -By+l"%" >>$ps
    /usr/local/bin/gmt psscale -CChangedColorPalette1.cpt -O -Dx-1c/-2c+w18c/1c+h -Bx+l"Probability Scale" -By+l"%" >>$ps
fi
ps2pdf $ps


## Second page with complete trajectories (Added by Karthik TNC)
ps=secondpage_$1.ps
Uncertain=10;

/usr/local/bin/gmt gmtset BASEMAP_TYPE=plain  PAPER_MEDIA custom_595x842 PAGE_ORIENTATION landscape
/usr/local/bin/gmt psbasemap -R76/98/13/28 -JM7.5i   -G -V -P -K  -X1.5 -Y2.5  -B+t"" >$ps

#psimage new_scale.ps -C0/-2 -W1/1 -E70 -O -K -V -P >>$ps
/usr/local/bin/gmt psimage sarat_final.ps -D0/23  -E1000 -O -K -V -P >>$ps
##
echo "87 39.3 19 0 5 MC SARAT" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G -F+f0/0/255  >>$ps
echo "87 38.8 14 0 5 MC Search And Rescue Aid Tool" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
echo "87 38.4 10 0 5 MC ESSO-INDIAN NATIONAL CENTRE FOR OCEAN INFORMATION SERVICES" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
echo "87 37.5 10 0 5 MC ISO 9001 : 2008 Certified  Ocean State Forecast Services" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
echo "87 38 10 0 5 MC (Ministry of Earth Sciences, Government of India)" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
#echo "Based upon the SARAT simulations, REGION 1 indicate the most probable Search Region which has maximum  probability of  50%  for locating and/or rescuing the object. REGION 2 indicate the second most probable Search Region of 40% ." | fold -w 95 -s >subject.txt
echo "87 10 10 0 5 MC The model simulation has been done with $Uncertain km Uncertainity in Initial Condition" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
echo "87 36.4 13 0 5 MC Complete trajectory plots of the model simulation are shown below" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R >>$ps

echo "77 35.6 11 0 5 BL Last Known Position is Longitude: ${lodeg} deg ${lomin} mins ${losec} secs (${inputLon} deg), Latitude: ${ltdeg} deg ${ltmin} mins ${ltsec} secs (${inputLat} deg)" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -Ff40/40/40 >>$ps
echo "77 34.6 11 0 5 BL Advisory generated on: $(date +%d/%m/%Y) $(date +%H:%M) hrs IST          Valid Upto : $(date -d "0 day $(awk '{print $6}' userinput_$1.txt)" '+%d/%m/%Y') $(awk '{print substr($7,0,5)}' userinput_$1.txt) hrs IST" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -Ff40/40/40 >>$ps
# echo "77 33.6 11 0 5 BL Advisory generated on: $(date +%d/%m/%Y) $(date +%H:%M) hrs IST          Valid Upto : $(date -d "0 day $(awk '{print $6}' userinput_$1.txt)" '+%d/%m/%Y') $(awk '{print substr($7,0,5)}' userinput_$1.txt) hrs IST" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -Ff40/40/40 >>$ps


# long=35.5
# while read line
# do
# echo "76 $long 11 0 5 BL $line" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
# long=`echo $long - 0.5 | bc`
# done <subject.txt
###
awk '
function max(x){i=0;for(val in x){if(i<=x[val]){i=x[val];}}return i;}
function min(x){i=max(x);for(val in x){if(i>x[val]){i=x[val];}}return i;}
{a[$1]=$1;next}
END{minimum=min(a);maximum=max(a);iin=min(b);ax=max(b);print minimum" "maximum}' finalconvexhull_$1.dat >lon_$1.txt

awk '
function max(x){i=0;for(val in x){if(i<=x[val]){i=x[val];}}return i;}
function min(x){i=max(x);for(val in x){if(i>x[val]){i=x[val];}}return i;}
{a[$1]=$2;next}
END{minimum=min(a);maximum=max(a);iin=min(b);ax=max(b);print minimum" "maximum}' finalconvexhull_$1.dat >lat_$1.txt

xx1=$(awk '{print $1}' lon_$1.txt)
xx2=$(awk '{print $2}' lon_$1.txt)
yy1=$(awk '{print $1}' lat_$1.txt)
yy2=$(awk '{print $2}' lat_$1.txt)

x1=$( echo "$xx1 - 0.2" | bc -l  );x2=$( echo "$xx2 + 0.2" | bc -l  )
y1=$( echo "$yy1 - 0.2" | bc  -l );y2=$( echo "$yy2 + 0.2" | bc -l )

echo -R$x1/$x2/$y1/$y2

inputLon="$2"
inputLat="$3"

# declare -A Col=( [0.05]=-G255/254/215 [0.10]=-G254/228/148 [0.15]=-G254/194/77 [0.20]=-G248/135/31 [0.25]=-G251/181/154 [0.30]=-G243/68/48 [0.35]=-G208/27/30 [0.40]=-G158/53/3 [0.45]=-G151/215/183 [0.50]=-G94/189/209 [0.60]=-G46/144/192 [0.70]=-G2/98/168 [0.80]=-G0/0/255 [0.90]=-G64/64/64 [1.0]=-G0/0/0)
# gmt pscoast -R$x1/$x2/$y1/$y2  -JM10  -K  -O -B0.9WNseg0.9  -Df -P -GNavajoWhite -Wthick  -X1 -Y2.5 >> $ps
/usr/local/bin/gmt pscoast -R$x1/$x2/$y1/$y2  -JM10  -K  -O -Bg0.3 -BWSne -Ba0.3 -Df -P -GNavajoWhite -Wthick  -X1 -Y2.5 >> $ps

# Draw the outline of the probability regions
#ProXY=( $(ls proval-*-$1.xy) )
# Should work on SARAT server; it has bash 4.4
readarray -t ProXY < <(ls proval-*-"$1".xy)
for (( i=0;i<${#ProXY[@]};i++ ));do
        /usr/local/bin/gmt psxy  ${ProXY[$i]} -R -J -W0.2 -O -K  >>$ps
done


# Convert lat/long to degrees, minutes, seconds for display
ltdeg=`echo $inputLat | awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}'`;
ltdmin=.`echo $inputLat | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
ltmin=$(expr "$ltdmin * 60" | bc -l |  awk '{print $1}');
ltdsec=.`echo $ltmin | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
ltmin=$(expr "$ltdmin * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}' );
ltsec=$(expr "$ltdsec * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}');
###LON
lodeg=`echo $inputLon | awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}'`;
lodmin=.`echo $inputLon | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
lomin=$(expr "$lodmin * 60" | bc -l | awk '{print $1}');
lodsec=.`echo $lomin | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
lomin=$(expr "$lodmin * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}' );
losec=$(expr "$lodsec * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}');

# Empty the temporary file
complete_traj_tmp_file="complete_traj_tmp_$1.dat"
cat /dev/null > "${complete_traj_tmp_file}"
while read -r line
do
        if [ -n "$line" ]
        then
                ## $line is not empty
                echo "$line" >> "${complete_traj_tmp_file}"
        else
                ## Draw a trajectory
                #sync
                #sleep 1
                /usr/local/bin/gmt psxy "${complete_traj_tmp_file}" -R -J -W0.2,169/169/169 -O -K  >>$ps
                # echo > "${complete_traj_tmp_file}"
                cat /dev/null > "${complete_traj_tmp_file}"
        fi
done < "complete_traj_$1.dat"



# start_lon=$(awk 'NR==1{print $1}' "complete_traj_$1.dat")
# start_lat=$(awk 'NR==1{print $2}' "complete_traj_$1.dat")
# echo "${start_lon}, ${start_lat}"
# awk -v start_lat="${start_lat}" -v start_lon="${start_lon}" '{if ($0 !~ /^$/ && ($1 != start_lon || $2 != start_lat)) print;}' "complete_traj_$1.dat" > "complete_traj_tmp_$1.dat"

# # gmt psxy "complete_traj_$1.dat" -R -J -W0.2,169/169/169 -L+xr -O -K  >>$ps
# gmt psxy "complete_traj_tmp_$1.dat" -R -J -W0.2,169/169/169 -O -K  >>$ps
        # for (( i=0;i<${#ProXY[@]};i++ ));do
        #         G=${Col[$(echo ${ProXY[$i]} | sed 's/-/ /g' | awk '{print $2}')]}
        #         gmt psxy  ${ProXY[$i]} -R -J -W0.2 $G -B -O -K  >>$ps
        # done
###Drawing Mean Trajectory 
#	psxy meantrajectory_$1.dat -R -J -W5/255/255/255 -B -O -K -M >>$ps

/usr/local/bin/gmt pstext -J -O -K -R  -GWhite -N >>$ps<<END
${inputLon} ${inputLat} 18 0 1 MC .
END
#82.96075 12.6471 18 0 1 MC .
/usr/local/bin/gmt psxy  -R -J -SE-  -W5,255/255/255 -B -O -K  >>$ps<<END
${inputLon} ${inputLat} 0 $Uncertain $Uncertain 
END

inlon=$(echo "$2 + 0.02" | bc -l )
#echo "$inlon $3 10 0 5 MC Initial Position " | /usr/local/bin/gmt pstext -J -N -O -K -R -G -F+f255/255/255 >>$ps
# echo "$inlon $3 10 0 5 MC Last Known Position($2, $3)" | /usr/local/bin/gmt pstext -J -N -O -K -R -G -F+f10p,Helvetica,black >>$ps
echo "${inlon} ${inputLat} 10 0 5 ML Last Known Position" | /usr/local/bin/gmt pstext -J -N -O -K -R -G -F+f10p,Helvetica,black >>$ps

ps2pdf $ps

#### Third page (Map showing last known position)
ps=thirdpage_$1.ps
/usr/local/bin/gmt gmtset BASEMAP_TYPE=plain  PAPER_MEDIA custom_595x842 PAGE_ORIENTATION landscape
/usr/local/bin/gmt pscoast -R76/98/10/38 -JM7.5i -C -B0NSEW -Df -V -P -K  -X0.5 -Y1  >$ps
# gmt pscoast -R50/106/-17/38 -JM7.5i -C -B0NSEW -Df -V -P -K  -X0.5 -Y1  >$ps
/usr/local/bin/gmt psimage incois.ps -D8/25  -E100 -O -K -V -P >>$ps
#gmt psimage esso.ps -D7/24.6  -E100 -O -K -V -P >>$ps
echo "87 35.7 10 0 5 MC ESSO-INDIAN NATIONAL CENTRE FOR OCEAN INFORMATION SERVICES" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
echo "87 35.3 10 0 5 MC (Ministry of Earth Sciences, Government of India)" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
echo "87 34.8 10 0 5 MC ISO 9001 : 2008 Certified  Ocean State Forecast Services" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -G >>$ps
#echo "87 34.2 10 0 5 MC (FAX NO. +91-40-23892910)" | pstext -JM7.5i -N -O -K -R -G0/0/0 >>$ps
echo "REGION 1 : Advised to search the triangular area bounded by the following lat. lon. positions for finding the missing object with $( echo "${TopProb[1]} * 100" | bc -l ) %  probability." | fold -w 90 -s >subject.txt
sort  proval-${TopProb[1]}-$1.xy | uniq >finalgmtregion.xy
##
rm ddmmsec.txt
while read line;do
        InsatLat=$(echo $line | awk '{print $2}')
        InsatLong=$(echo $line | awk '{print $1}')
##LAT
ltdeg=`echo $InsatLat | awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}'`;
        ltdmin=.`echo $InsatLat | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
ltmin=$(expr "$ltdmin * 60" | bc -l |  awk '{print $1}');
        ltdsec=.`echo $ltmin | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
        ltmin=$(expr "$ltdmin * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}' );
ltsec=$(expr "$ltdsec * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}');
###LON
lodeg=`echo $InsatLong | awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}'`;
        lodmin=.`echo $InsatLong | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
lomin=$(expr "$lodmin * 60" | bc -l | awk '{print $1}');
        lodsec=.`echo $lomin | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
        lomin=$(expr "$lodmin * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}' );
losec=$(expr "$lodsec * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}');
echo " $lodeg deg $lomin min $losec sec (${InsatLong} deg) , $ltdeg deg $ltmin min $ltsec sec (${InsatLat} deg)" >>ddmmsec.txt
done<finalgmtregion.xy
#	./DegreeMinSec_Converter.sh finalgmtregion.xy
##
#awk '{printf "%2d) %.2f,%.2f\n", NR,$1,$2}' ddmmsec.txt >>subject.txt
	awk '{printf "%2d) %s \n", NR,$0}' ddmmsec.txt >>subject.txt

echo -e "\nREGION 2 : Advised to search the triangular area bounded by the following lat. lon. positions for finding the missing object with $( echo "${TopProb[0]} * 100" | bc -l ) %  probability." | fold -w 90 -s >>subject.txt
sort  proval-${TopProb[0]}-$1.xy | uniq >finalgmtregion.xy
##
rm ddmmsec.txt
while read line;do
        InsatLat=$(echo $line | awk '{print $2}')
        InsatLong=$(echo $line | awk '{print $1}')
##LAT
ltdeg=`echo $InsatLat | awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}'`;
        ltdmin=.`echo $InsatLat | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
ltmin=$(expr "$ltdmin * 60" | bc -l |  awk '{print $1}');
        ltdsec=.`echo $ltmin | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
        ltmin=$(expr "$ltdmin * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}' );
ltsec=$(expr "$ltdsec * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}');
###LON
lodeg=`echo $InsatLong | awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}'`;
        lodmin=.`echo $InsatLong | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
lomin=$(expr "$lodmin * 60" | bc -l | awk '{print $1}');
        lodsec=.`echo $lomin | awk '{print $1}' | sed 's/\./ /g' | awk '{print $2}'`
        lomin=$(expr "$lodmin * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}' );
losec=$(expr "$lodsec * 60" | bc -l |  awk '{print $1}' | sed 's/\./ /g' | awk '{print $1}');
echo " $lodeg deg $lomin min $losec sec (${InsatLong} deg) , $ltdeg deg $ltmin min $ltsec sec (${InsatLat} deg)" >>ddmmsec.txt
done<finalgmtregion.xy
##
#awk '{printf "%2d) %.2f,%.2f\n", NR,$1,$2}' ddmmsec.txt >>subject.txt
	awk '{printf "%2d) %s \n", NR,$0}' ddmmsec.txt >>subject.txt

echo -e "\n\nNext Bulletein will be issued  based on User Request." >>subject.txt

<<kp
echo "REGION 1 : Advised to search the triangular area bounded by the following lat. lon. positions for finding the missing object with $( echo "${TopProb[1]} * 100" | bc -l ) %  probability." | fold -w 70 -s >subject.txt
long=33.5
while read line
do
echo "78 $long 11 0 5 BL $line" | pstext -JM7.5i -N -O -K -R -G40/40/40 >>$ps
long=`echo $long - 0.5 | bc`
done <subject.txt
echo "REGION 2 : Advised to search the triangular area bounded by the following lat. lon. positions for finding the missing object with $( echo "${TopProb[0]} * 100" | bc -l ) %  probability." | fold -w 70 -s >subject.txt
kp

long=22.5
while read line
do
echo "88 $long $line " | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -F+f12,Times-Roman,-=0.5p,black -V  >>$ps
long=`echo $long - 0.5 | bc`
done <subject.txt

echo "90 12   Marine Forecaster" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -F+f12,-=0.5p,black >>$ps;
echo "88 11.5  Information Services and Ocean Sciences Group-INCOIS" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -F+f12,-=0.5p,black >>$ps;
echo "88 11   For Ocean State Forecast(OSF) visit http://www.incois.gov.in/portal/osf/osf.jsp" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -F+f12,-=0.5p,black >>$ps;
echo "88 10.5  In case of any query, please contact 040-23895017 or email us at osf@@incois.gov.in" | /usr/local/bin/gmt pstext -JM7.5i -N -O -K -R -F+f12,-=0.5p,black >>$ps;


# gmt pscoast -R67/98/0/24 -JD79/17/19/23/5.5i -B6g2 -W -Df -G255/160/50 -O -K -P -X3 -Y12 >>$ps
/usr/local/bin/gmt pscoast -R45/108/-26/24 -JD79/17/19/23/6.3i -B5g4 -W -Df -G255/160/50 -O -K -P -X2 -Y12 >>$ps

awk '
function max(x){i=0;for(val in x){if(i<=x[val]){i=x[val];}}return i;}
function min(x){i=max(x);for(val in x){if(i>x[val]){i=x[val];}}return i;}
{a[$1]=$1;next}
END{minimum=min(a);maximum=max(a);iin=min(b);ax=max(b);print minimum" "maximum}' finalconvexhull_$1.dat >lon.txt

awk '
function max(x){i=0;for(val in x){if(i<=x[val]){i=x[val];}}return i;}
function min(x){i=max(x);for(val in x){if(i>x[val]){i=x[val];}}return i;}
{a[$1]=$2;next}
END{minimum=min(a);maximum=max(a);iin=min(b);ax=max(b);print minimum" "maximum}' finalconvexhull_$1.dat >lat.txt

xx1=$(awk '{print $1}' lon.txt)
xx2=$(awk '{print $2}' lon.txt)
yy1=$(awk '{print $1}' lat.txt)
yy2=$(awk '{print $2}' lat.txt)

##y=$3;x=$2
x1=$( echo "$xx1 - 0.2" | bc -l  );x2=$( echo "$xx2 + 0.2" | bc -l  )
y1=$( echo "$yy1 - 0.2" | bc  -l );y2=$( echo "$yy2 + 0.2" | bc -l )
echo -R$x1/$x2/$y1/$y2
##Setting Colour Codes for each Probability
#declare -A Col=( [0.1]=-G0/0/139 [0.2]=-G255/140/0 [0.3]=-G102/0/255 [0.4]=-G238/130/238 [0.5]=-G255/20/147 [0.6]=-G0/100/0 [0.7]=-G128/0/128 [0.8]=-G255/0/0 [0.9]=-G153/51/255 [1.0]=-G64/244/208)
# declare -A Col=( [0.05]=-G1/70/54 [0.1]=-G5/88/67 [0.15]=-G3/103/82 [0.2]=-G0/114/100 [0.25]=-G0/123/120 [0.3]=-G7/130/144 [0.35]=-G31/136/169 [0.4]=-G51/142/190 [0.45]=-G70/152/201 [0.5]=-G91/163/205 [0.55]=-G116/173/208 [0.6]=-G143/182/214 [0.65]=-G168/190/219 [0.7]=-G188/198/224 [0.75]=-G204/206/228 [0.8]=-G217/214/233 [0.85]=-G229/221/237 [0.9]=-G239/228/241 [0.95]=-G247/236/246 [1.0]=-G255/247/251)
# declare -A Col=( [0.05]=-G255/247/251 [0.10]=-G247/236/246 [0.15]=-G239/228/241 [0.20]=-G229/221/237 [0.25]=-G217/214/233 [0.30]=-G204/206/228 [0.35]=-G188/198/224 [0.40]=-G168/190/219 [0.45]=-G143/182/214 [0.50]=-G116/173/208 [0.55]=-G91/163/205 [0.60]=-G70/152/201 [0.65]=-G51/142/190 [0.70]=-G31/136/169 [0.75]=-G7/130/144 [0.80]=-G0/123/120 [0.85]=-G0/114/100 [0.90]=-G3/103/82 [0.95]=-G5/88/67 [1.0]=-G1/70/54)
declare -A Col=( [0.05]=-G255/254/215 [0.10]=-G254/228/148 [0.15]=-G254/194/77 [0.20]=-G248/135/31 [0.25]=-G251/181/154 [0.30]=-G243/68/48 [0.35]=-G208/27/30 [0.40]=-G158/53/3 [0.45]=-G151/215/183 [0.50]=-G94/189/209 [0.60]=-G46/144/192 [0.70]=-G2/98/168 [0.80]=-G0/0/255 [0.90]=-G64/64/64 [1.0]=-G0/0/0)

# ProXY=( `ls proval-*-$1.xy` )
#         #pscoast -R$x1/$x2/$y1/$y2  -JM$x1/$y1/16c  -K  -O -B0.5WNseg0.5  -Df -P -GNavajoWhite -Wthick  -X3 -Y-13 >> $ps
# for (( i=0;i<${#ProXY[@]};i++ ));do
#         G=${Col[$(echo ${ProXY[$i]} | sed 's/-/ /g' | awk '{print $2}')]}
#         # gmt psxy  ${ProXY[$i]} -R -J -W0.2 $G -B -O -K >>$ps
#         gmt psxy  ${ProXY[$i]} -R -J -W0.05i $G -B -O -K >>$ps
# done
lkp_file="lkp_$1.dat"
echo "$2 $3" > "${lkp_file}"
/usr/local/bin/gmt psxy "${lkp_file}" -R -J -Sa0.1i -W1p,red -Gyellow -B -O -K >> "${ps}"

ps2pdf $ps
# gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=bulletein-$1.pdf   firstpage_$1.pdf secondpage_$1.pdf;
# rm firstpage_$1.pdf secondpage_$1.pdf
# exit

# gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=bulletein-$1.pdf   firstpage_$1.pdf secondpage_$1.pdf;
# rm firstpage_$1.pdf secondpage_$1.pdf
gs -dBATCH -dNOPAUSE -dPDFSETTINGS=/ebook -q -sDEVICE=pdfwrite -sOutputFile=bulletein-$1.pdf   firstpage_$1.pdf secondpage_$1.pdf thirdpage_$1.pdf;
rm firstpage_$1.pdf secondpage_$1.pdf thirdpage_$1.pdf

cp bulletein-$1.pdf sarat_bulletein.pdf
exit

### SMS Dissemintaion Section
# echo "Region1 ($( echo "${TopProb[1]} * 100" | bc -l ) %)" >forsms.txt
# printf "%.2f %.2f\n" $(sort  proval-${TopProb[1]}-$1.xy | uniq ) >>forsms.txt
# echo "Region2 ($( echo "${TopProb[0]} * 100" | bc -l ) %)" >>forsms.txt
# printf "%.2f %.2f\n" $(sort  proval-${TopProb[0]}-$1.xy | uniq ) >>forsms.txt
# if [ -f forsms.txt ];then
#         /usr/bin/javac BulkSms.java;echo "$(awk '{print $10}' userinput.txt)" >mobileno.txt
#         /usr/bin/java BulkSms forsms.txt mobileno.txt
# fi
