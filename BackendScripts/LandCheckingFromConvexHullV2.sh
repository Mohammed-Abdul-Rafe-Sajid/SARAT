#!/bin/bash
cd /home/osf/SearchAndRescueTool
i=0;
I_Lon=0;
I_Lat=0;
Hull_Seg="hull_$1.dat";
FHull_Seg="finalconvexhull_$1.dat"
#rm $FHull_Seg
cat >sample.jnl<<EOF
use /home/osf/SearchAndRescueTool/etopo1.cdf
list/noheader rose[x=\$1,y=\$2]
quit
EOF

while read line;do
	lon=`echo $line | awk '{print $1}'`
	lat=`echo $line | awk '{print $2}'`
	if [ $i -eq 0 ];
	then
		I_Lon=$lon;
		I_Lat=$lat;
	fi

    #landval=`ferret -script sample.jnl $lon $lat | awk '{print $1}'`
	#JavaCal=`/usr/bin/java latlong $landval`
	#echo -e "\t \t $JavaCal"
	# if [ $JavaCal -eq 0 ];then
	# 	echo "[$lon,$lat] % Land : $landval %"	
	# 	./GenerateXYpoints.sh $I_Lon $I_Lat $lon $lat $1
	# 	cat pts_$1.dat >>$FHull_Seg
	# else	
	#     echo "[$lon,$lat]  Ocean : $landval "
	# 	echo $lon $lat >>$FHull_Seg
	# fi
	landval=`/usr/local/ferret/bin/ferret -script /home/osf/SearchAndRescueTool/sample.jnl $lon $lat | awk '{print $1}' | sed -e 's/\.$//'`
	#echo "${landval}"
	if [ "$landval" -le "0" ]
	# if (( "$landval" <= 0 ))
	then
		# Ocean
		echo "[$lon,$lat]  Ocean : $landval "
		echo $lon $lat >>$FHull_Seg
	else
		# Land
		echo "[$lon,$lat] % Land : $landval"	
		./GenerateXYpointsV2.sh $I_Lon $I_Lat $lon $lat $1
		cat pts_$1.dat >>$FHull_Seg
	fi
	i=$(( $i + 1 ))
done<$Hull_Seg
