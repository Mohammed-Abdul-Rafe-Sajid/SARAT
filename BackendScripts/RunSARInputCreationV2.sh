#!/bin/bash
cd /home/osf/SearchAndRescueTool
##################################################################
# This program is for creating inputs for SAR Model		 #
#		-by Kaviyazhahu/Krishnaprasad			 #
#								 #
##################################################################
source /usr/local/ferret/bin/my_ferret_paths_template.sh
#if [ -z "$1" ]
 #then
   #dstamp=`TZ=GMT+0 date +%Y%m%d`
 #else
   #dstamp=$1
#fi
#if [ -n "$1" ]
#then
#    webapp_dir="$1"
#    if [ ! -d "${webapp_dir}" ]
#    then
#        echo "${webapp_dir} does not exist."
#        exit 2
#    fi
#else
#    echo "Required argument webapp-directory for pushing the outputs to web interface."
#    exit 2
#fi
#
#shift
#
webapp_dir="/home/osf/tomcat/webapps/sarat"
echo $@ >userinput.txt
start=$(date +%s.%N)
	rm Current*.nc  Wind*.nc 
Home="/home/osf/SearchAndRescueTool"
UniqId=$(awk '{print $8}' userinput.txt)
echo "$@" >userinput_${UniqId}.txt
ObjectId=$(awk '{print $1}' userinput.txt)
#UniqId=$(awk '{print $7}' userinput.txt)

StartDate=$(awk '{print $4,substr($5,0,5)}' userinput.txt);EndDate=$(awk '{print $6,substr($7,0,5)}' userinput.txt)
iplat=$(awk '{print $2}' userinput.txt);iplon=$(awk '{print $3}' userinput.txt)
rm -rf tmp_dir/*
####
/usr/local/ferret/bin/ferret -nojnl<<EOF
use  etopo1.cdf
list/file=land$UniqId.txt/clobber/noheader rose[x=$iplon,y=$iplat]
quit
EOF
	landval=`awk '{print $1}' land$UniqId.txt`
if [ $( echo "$landval <= 0" | bc -l ) -eq 0 ];then
        echo "1" >invalidlatlon.txt
		chmod 777 invalidlatlon.txt
		#cp invalidlatlon.txt /home/osf/tomcat/webapps/saratV2/
        cp invalidlatlon.txt "${webapp_dir}/"
		exit
else
        echo "0" >invalidlatlon.txt
		#cp invalidlatlon.txt /home/osf/tomcat/webapps/saratV2/
        cp invalidlatlon.txt "${webapp_dir}/"
fi
####
WI="YES";CI="YES";
f_step="";l_step="";
####Start IST Time 
	Min=$(date -d "$StartDate" +%s);Mindelete=$(echo "$Min % 10800 "| bc)
	final_st=$(date -d "$StartDate IST -$Mindelete seconds" +'%Y-%m-%d %H:%M')
####End IST Time
	Min=$(date -d "$EndDate" +%s);Mindelete=$(echo "$Min % 10800  "| bc)
	dummy=$(date -d "$EndDate IST  -$Mindelete seconds" +'%Y-%m-%d %H:%M')
	if [ $Mindelete -ne 0 ];then 	final_en=$(date -d "$dummy IST  +10800 seconds" +'%Y-%m-%d %H:%M')
	else final_en=$(date -d "$dummy IST" +'%Y-%m-%d %H:%M');fi
	echo $final_st $final_en
	Diff=0;d=$(date -d "$final_st IST" +'%Y-%m-%d')
                ##while loop for counting the days
                while [[ "$d" < $(date -d "$final_en IST" +'%Y-%m-%d') || "$d" = $(date -d "$final_en IST" +'%Y-%m-%d') ]];do Diff=$(( $Diff + 1));
                d=$(date -I -d "$d + 1 day");done
if [[ $CI == "YES" ]];then
####Setting array for Timestep 
	declare -A TArray=( [02:30]=1 [05:30]=2 [08:30]=3 [11:30]=4 [14:30]=5 [17:30]=6 [20:30]=7 [23:30]=8 )
		##for loop : to pick correct timestep number from in i/p Nc files and appending to Single Nc file (GMT)
		for ((i=0;i<$Diff;i++));do
		echo "++ $i $Diff ++"
		       if [[ $i -eq 0 ]];then
			 t_step=${TArray[$(date -d "$final_st IST" +'%H:%M')]}:8
		       elif [[ $i -eq $(( $Diff - 1 )) ]];then
			 t_step=1:${TArray[$(date -d "$final_en IST" +'%H:%M')]}
		       else
			 t_step="1:8"
		       fi
                       echo `date -d "$i day $final_st" '+%Y%m%d'`  $t_step
/usr/local/ferret/bin/ferret -nojnl<<EOF
use "data/cursar_$(date -d "$i day $final_st" '+%Y%m%d').nc"
set mem/size=1024;let U=USURF;let V=VSURF
save/file=CurrentInput_$UniqId.nc/l=$t_step/k=1/append U,V
quit
EOF
		done
		##for loop is endded here
#### Checking file Exist and Size
    if [[ -f CurrentInput_$UniqId.nc && -s CurrentInput_$UniqId.nc ]];then
		Time1=$(date -d "0 day $final_st" '+%d-%b-%Y %H:%M');
		Time2=$(date -d "0 day $final_en" '+%d-%b-%Y %H:%M')
	###Converting GMT timestamps into IST timestamps since model required in IST format
/usr/local/ferret/bin/ferret -nojnl<<EOF
use "/home/osf/SearchAndRescueTool/CurrentInput_$UniqId.nc"
define axis/t="$Time1":"$Time2":3/units=hours/t0="01-jan-1990 00:00" taxnew
define grid/t=taxnew grdnew
let UC=U[g=grdnew@asn] 
let VC=V[g=grdnew@asn]
let/title="Currents UC" cu=IF UC GT 1000 THEN (-999) ELSE UC
let/title="Currents UC" cv=IF VC GT 1000 THEN (-999) ELSE VC
set var/bad=-999.0 cu
set var/bad=-999.0 cv
set mem/size=1024
save/file=Current_$UniqId.nc/append cu,cv 
quit
EOF
    else
        echo "I am Exitting . ' CurrentInput_$UniqId.nc ' file not available..";exit
    fi
##
fi
### Wind  Input Creation 
	declare -A TArray=( [02:30]=1 [05:30]=2 [08:30]=3 [11:30]=4 [14:30]=5 [17:30]=6 [20:30]=7 [23:30]=8 )
		echo $Diff
		for ((i=0;i<$Diff;i++));do
			if [[ $i -eq 0 ]];then
                         t_step=${TArray[$(date -d "$final_st IST" +'%H:%M')]}:8
                       elif [[ $i -eq $(( $Diff - 1 )) ]];then
                         t_step=1:${TArray[$(date -d "$final_en IST" +'%H:%M')]}
                       else
                         t_step="1:8"
                       fi
		 echo "$t_step <===> $(date -d "$i day $final_st" '+%Y%m%d')"
/usr/local/ferret/bin/ferret -nojnl<<EOF
use "data/wssar_$(date -d "$i day $final_st" '+%Y%m%d').nc"
set mem/size=1024;
save/file=WindInput_$UniqId.nc/l=$t_step/append WX,WY
quit
EOF
		done
#masking the land
		Time1=$(date -d "0 day $final_st" '+%d-%b-%Y %H:%M');Time2=$(date -d "0 day $final_en" '+%d-%b-%Y %H:%M')
/usr/local/ferret/bin/ferret -nojnl<<EOF
use "/home/osf/SearchAndRescueTool/WindInput_$UniqId.nc"
define axis/t="$Time1":"$Time2":3/units=hours/t0="01-jan-1990 00:00" taxnew
define grid/t=taxnew grdnew
let WSX=WX[g=grdnew@asn] 
let WSY=WY[g=grdnew@asn]
use "/usr/local/ferret/fer_dsets/data/etopo5.cdf"
def grid/like=WSX[d=1] grd
def grid/like=WSY[d=1] grd
let myrose=rose[d=2,g=grd]
let land=if(myrose ge 0)then 1 else 0
let vlands=if(land eq 1)then WSX[d=1]
let vlandy=if(land eq 1)then WSY[d=1]
let WSXM=if(land eq 0)then WSX[d=1]
let WSYM=if(land eq 0)then WSY[d=1]
set var/bad=0.000 WSXM
set var/bad=0.000 WSYM
set mem/size=1024
save/file=Wind_$UniqId.nc/clobber WSXM,WSYM
quit
EOF
#chmod 777 landmask.jnl;
#ferret -script landmask.jnl
#converting netced to grib
chmod 777 Wind_$UniqId.nc Current_$UniqId.nc
if [ -f Wind_$UniqId.nc ];then
	/usr/local/bin/cdo -f grb -chparam,-1,-33,-2,34 Wind_$UniqId.nc  wind$UniqId.grb
	rm WindInput_$UniqId.nc
fi
if [ -f Current_$UniqId.nc ];then
	/usr/local/bin/cdo -f grb -chparam,-1,-49,-2,50 Current_$UniqId.nc current$UniqId.grb
	rm CurrentInput_$UniqId.nc
fi

chmod 777 wind$UniqId.grb current$UniqId.grb
## Check current & wind GRB Files exixts or Not,
if [[ -f current$UniqId.grb && -f wind$UniqId.grb ]];then
##lwseed.in file creation
	./InfilePreparationV2.sh  $UniqId
	chmod 777 lwseed$UniqId.in
	if [ -f lwseed$UniqId.in ];then
		cp lwseed$UniqId.in model/leeway_india/build/leeway/lwseed/
		cd model/leeway_india/build/leeway/lwseed/
		./lwseed lwseed$UniqId.in leeway$UniqId.in
		chmod 777 leeway$UniqId.in
		###Copy leeway.in file to leeway directory for model input
		cp leeway$UniqId.in ../leeway
		cd ../leeway
		cp $Home/current$UniqId.grb .;cp $Home/wind$UniqId.grb .
		sed -i 's/wind.grb/wind'$UniqId'.grb/g' leeway$UniqId.in;sed -i 's/current.grb/current'$UniqId'.grb/g' leeway$UniqId.in
		sed -i '18s/.*/500/' leeway$UniqId.in
		run_leeway_on_remote=1
		remote_server_ip="172.30.2.34"
		remote_username="incois"
		remote_pass="incois@incois"
		remote_root_dir="/home/incois/SARAT_Leeway_Runs"
		remote_work_dir="${remote_root_dir}/${UniqId}"
		leewayrun_log_file="leeway_${UniqId}.log"
		if [ "${run_leeway_on_remote}" -eq 1 ]
		then
			echo "Creating '${remote_work_dir}' on '${remote_server_ip}' ..." >"${leewayrun_log_file}"
			sshpass -p "${remote_pass}" ssh "${remote_username}"@"${remote_server_ip}" "mkdir -p ${remote_work_dir}" >>"${leewayrun_log_file}" 2>&1

			echo "Syncing required files for leeway run to remote server ${remote_server_ip}" >>"${leewayrun_log_file}"
			sshpass -p "${remote_pass}" rsync -avczP wind"${UniqId}".grb current"${UniqId}".grb leeway"${UniqId}".in "${remote_username}"@"${remote_server_ip}":"${remote_root_dir}/" >>"${leewayrun_log_file}" 2>&1 || {
				echo "Failed to sync required files for leeway run to remote server ${remote_server_ip}" >>"${leewayrun_log_file}"
				exit 2
			}
			echo "Running leeway on remote server ${remote_server_ip}" >>"${leewayrun_log_file}"
			sshpass -p "${remote_pass}" ssh "${remote_username}"@"${remote_server_ip}" "cd ${remote_root_dir}; ${remote_root_dir}/leeway ./leeway${UniqId}.in ./leeway${UniqId}.out && rm ./wind${UniqId}.grb ./current${UniqId}.grb && mv ./leeway${UniqId}.in ./leeway${UniqId}.out ${remote_work_dir}/" >>"${leewayrun_log_file}" 2>&1 || {
				echo "Remote execution of leeway run failed on remote server ${remote_server_ip}." >>"${leewayrun_log_file}"
				exit 2
			}
			echo "Syncing output files from leeway run on remote server ${remote_server_ip}" >>"${leewayrun_log_file}"
			sshpass -p "${remote_pass}" rsync -avczP "${remote_username}"@"${remote_server_ip}":"${remote_work_dir}/leeway${UniqId}.out" leeway"${UniqId}".out >>"${leewayrun_log_file}" 2>&1 || {
				echo "Failed to sync output files from leeway run on remote server ${remote_server_ip}." >>"${leewayrun_log_file}"
				exit 2
			}
			
		else
			./leeway leeway$UniqId.in leeway$UniqId.out >"${leewayrun_log_file}" 2>&1
		fi
		chmod 777 leeway$UniqId.out
		cp leeway$UniqId.out $Home/leeway.out
		cp leeway$UniqId.out $Home	
		cd $Home

		leeway_prob_template_script="leeway_probV2.f"
		leeway_prob_script="leeway_probV2_${UniqId}.f"
		echo "Copying leeway prob template script ${leeway_prob_template_script} to leeway prob unique id script ${leeway_prob_script}.." >leewayexec_"${UniqId}".log 2>&1
		cp "${leeway_prob_template_script}" "${leeway_prob_script}" >>leewayexec_"${UniqId}".log 2>&1 || {
			echo "Failed to copy leeway prob template script ${leeway_prob_template_script} to leeway prob unique id script ${leeway_prob_script}"
			exit 2
		}
		
		sed -i 's/leeway.*..out/leeway'$UniqId'.out/g' "${leeway_prob_script}"
		sed -i 's/composite_.*.dat/composite_'$UniqId'.dat/g' "${leeway_prob_script}"
		sed -i 's/area_.*.dat/area_'$UniqId'.dat/g' "${leeway_prob_script}"
		sed -i 's/hull_.*.dat/hull_'$UniqId.dat'/g' "${leeway_prob_script}"
		sed -i 's/meantrajectory_.*.dat/meantrajectory_'$UniqId'.dat/g' "${leeway_prob_script}"
		sed -i 's/convex_hull_.*.dat/convex_hull_'$UniqId'.dat/g' "${leeway_prob_script}"
		sed -i 's/probability_.*.gnu/probability_'$UniqId'.gnu/g' "${leeway_prob_script}"
		sed -i 's/complete_trajectory_.*.gnu/complete_trajectory_'$UniqId'.gnu/g' "${leeway_prob_script}"
		sed -i 's/complete_traj_.*.dat/complete_traj_'$UniqId'.dat/g' "${leeway_prob_script}"
		sed -i 's/complete_trajectory_.*.eps/complete_trajectory_'$UniqId'.eps/g' "${leeway_prob_script}"
		sed -i 's/probability_.*.eps/probability_'$UniqId'.eps/g' "${leeway_prob_script}"
			
			
		# gfortran leeway_prob.f envelope.f;
		#gfortran -o leeway_probV2.exec "${leeway_prob_script}" envelope.f
		leewayexec_log="leewayexec_${UniqId}.log"
		leeway_prob_exec="leeway_probV2_${UniqId}.exec"
		gfortran -o "${leeway_prob_exec}" "${leeway_prob_script}" envelope.f >"${leewayexec_log}" 2>&1 
		# ./a.out
		# Run the FORTRAN executable
		#./leeway_probV2.exec >leewayexec_"${UniqId}".log 2>&1
		run_leewaypostproc_on_remote=1
		if [ "${run_leewaypostproc_on_remote}" -eq 1 ]
		then
			remote_work_tmp_dir="${remote_work_dir}/tmp_dir"
			echo "Creating '${remote_work_tmp_dir}' on '${remote_server_ip}' ..." >>"${leewayexec_log}"
			sshpass -p "${remote_pass}" ssh "${remote_username}"@"${remote_server_ip}" "mkdir -p ${remote_work_tmp_dir}" >>"${leewayexec_log}" 2>&1

			echo "Syncing required files for leeway postprocess run to remote server ${remote_server_ip}" >>"${leewayexec_log}"
			sshpass -p "${remote_pass}" rsync -avczP leeway${UniqId}.out "${leeway_prob_script}" "${leeway_prob_exec}" "${remote_username}"@"${remote_server_ip}":"${remote_work_dir}/" >>"${leewayexec_log}" 2>&1 || {
				echo "Failed to sync required files for leeway postprocess run to remote server ${remote_server_ip}" >>"${leewayexec_log}"
				exit 2
			}

			echo "Running leeway postprocess on remote server ${remote_server_ip}" >>"${leewayexec_log}"
			sshpass -p "${remote_pass}" ssh "${remote_username}"@"${remote_server_ip}" "cd ${remote_work_dir}; ./${leeway_prob_exec} && rm -rf ${remote_work_tmp_dir}" >>"${leewayexec_log}" 2>&1 || {
				echo "Remote execution of leeway postprocess run failed on remote server ${remote_server_ip}." >>"${leewayexec_log}"
				exit 2
			}

			echo "Syncing output files from leeway postprocess run on remote server ${remote_server_ip}" >>"${leewayexec_log}"
			sshpass -p "${remote_pass}" rsync -avczP --include="*.dat" --exclude="*" "${remote_username}"@"${remote_server_ip}":"${remote_work_dir}"/ "${Home}/" >>"${leewayexec_log}" 2>&1 || {
				echo "Failed to sync output dat files from leeway postprocess run on remote server ${remote_server_ip}." >>"${leewayexec_log}"
				exit 2
			}
		else
			#./leeway_probV2_${UniqId}.exec >>leewayexec_"${UniqId}".log 2>&1
			#ls -lrt ./leeway_probV2_${UniqId}.exec
			./"${leeway_prob_exec}" >>leewayexec_"${UniqId}".log 2>&1
		fi
		#rm ./leeway_probV2_${UniqId}.exec
		rm ./"${leeway_prob_exec}"

		chmod 777 *.dat
		# ./LandCheckingFromConvexHullV2.sh $UniqId >landcheck_${UniqId}.log 2>&1
		python3 ./LandCheckingFromConvexHullV2.py "${UniqId}" >landcheck_"${UniqId}".log 2>&1
		./HullSegmentV2.sh ${UniqId} >hullsegment_"${UniqId}".log 2>&1

		echo "Calling 'RunSARBulletinCreationV2.sh ${UniqId} ${iplon} ${iplat} ${ObjectId}'" > bulletin_gen_"${UniqId}".log
		./RunSARBulletinCreationV2.sh $UniqId  $iplon  $iplat $ObjectId >> bulletin_gen_"${UniqId}".log 2>&1

		#./OnlyMeanTrajectory.sh $UniqId  $iplon  $iplat $ObjectId
		chmod 777 *.dat
		cp *.dat dat_files/;mv *.nc  nc_files/;mv *.grb grb_files/
		cp *.xy xy_files/
		mv lee*.in in_files/;mv lee*.out out_files/
		rm ferret.jnl*
		chmod 777 $UniqId.json bulletein-$UniqId.pdf
		#cp $UniqId.json /home/osf/tomcat/webapps/saratV2/data/
        cp $UniqId.json ${webapp_dir}/data/

		# Trajectories and LKP geojsons
		#cp lkp_"${UniqId}".geojson /home/osf/tomcat/webapps/saratV2/data/
		#cp trajectories_"${UniqId}".geojson /home/osf/tomcat/webapps/saratV2/data/
		#cp meantrajectory_"${UniqId}".geojson /home/osf/tomcat/webapps/saratV2/data/
        cp lkp_"${UniqId}".geojson ${webapp_dir}/data/
		cp trajectories_"${UniqId}".geojson ${webapp_dir}/data/
		cp meantrajectory_"${UniqId}".geojson ${webapp_dir}/data/

		if [ -f bulletein-$UniqId.pdf ];then
			cp bulletein-$UniqId.pdf ${webapp_dir}/data/pdf/
		echo "
Sender=osf@incois.gov.in
SenderPassword=IRAWS#20220406
emailList=$(awk '{print $9}' userinput.txt)
subject=Reg:Search And Rescue 
message=pls find attachment
directory=/home/osf/SearchAndRescueTool
attachments=sarat_bulletein.pdf
" >MailSend.properties
		/usr/bin/java -jar MailSender.jar MailSend.properties
		#/usr/bin/java -jar MailSender.jar NavySend.properties
		fi
	fi
fi
end=$(date +%s.%N)    
#runtime=$(python -c "print(${end} - ${start})")

#echo "Runtime was $runtime"
