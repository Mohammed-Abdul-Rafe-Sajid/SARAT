#!/bin/bash
cd /home/osf/SearchAndRescueTool/
x1=$1;y1=$2
x2=$3;y2=$4
###
cat >sample.jnl<<EOF
use  etopo1.cdf
list/noheader rose[x=\$1,y=\$2]
quit
EOF
#	echo $x1 $y1 $x2 $y2
##Finding Slope of the Line
	my=`echo $y2 - $y1| bc  -l`;mx=`echo $x2 - $x1| bc  -l`
	m=`echo $my / $mx | bc -l`
##Finding equation of line
	nof_pts=`echo "$mx / 20" | bc -l`
	MX=$( echo "$m * $nof_pts" | bc -l )
	X=$x1;Y=$y1
	for (( i=0 ;i<20;i++ ));do
	 X=$( echo "$X + $nof_pts" | bc -l )
#	 #Y=MX+B ** equation
	 Y=$( echo "$MX + $Y" | bc -l )
		landval=`ferret -script sample.jnl $X $Y`
		JavaCal=`/usr/bin/java latlong $landval`
		#echo $X $Y $JavaCal $i 
		 if [ $JavaCal -eq 0 ];then
			echo 	"$X	$Y" >pts_$5.dat
                        break
	         fi
	done
exit
