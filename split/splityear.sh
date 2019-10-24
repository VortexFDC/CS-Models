#!/bin/bash

#################
#
#	Splits raw CMIP5 data for given model (all experiments) in one year files.
#		Necesita: Check files remaining in spool/check/
#		Works for: CNRM-CM5 HadGEM2-ES GFDL-CM3
#
#################

mdl=GFDL-CM3
ens=r1i1p1

spool_path="./spool"

#rm -r spool
mkdir -p spool/{cat,check,ready}

for exp in historical;do # historical rcp45 rcp85;do
	data_path="/home/martin/storage/models/${mdl}/wget/raw-${exp}"
	echo Getting data from: $data_path

	# Build file to year dictionary
	dict=file-year.$mdl.$exp.dict
	if [ ! -f $dict ];then
		echo Building file to year dictionary
		for f in `ls $data_path`;do
			yrs=`cdo -s showyear $data_path/$f`
			echo $f $yrs >> $dict
		done
	else
		echo Using existing file to year dictionary: $dict
	fi

	# Set period
	if [ $exp == historical ];then
		syear=1981
		eyear=2005
	else
		syear=`cat ../model-period.dict | grep $mdl | awk '{print substr($NF,1,4)}'`
		eyear=`cat ../model-period.dict | grep $mdl | awk '{print substr($NF,6,4)}'`
	fi

	# Select and cat files for year
	for varfreq in `ls $data_path | awk -F_ '{print $1"_"$2}' | sort | uniq`;do
		## If need to filter a var for debugging
		#if [ $varfreq != 'va_day' ];then
		#	echo ' 'Skipping $varfreq
		#	continue
		#fi

		echo " Selecting $varfreq ..."
		
		for year in `seq $syear $eyear`; do
			files=`grep ${varfreq}_ $dict | grep " $year" | awk '{print $1}'`
			i=0
			
			# Check if file exists in check or in ready
			if [ ! -f $spool_path/check/${varfreq}_${mdl}_${exp}_${ens}_${year}.nc ] && [ ! -f $spool_path/ready/${varfreq}_${mdl}_${exp}_${ens}_${year}.nc ];then
				rm -f $spool_path/cat/*
				
				for f in $files;do
					ii=`printf "%02d\n" $i`
					cdo -s selyear,$year $data_path/$f $spool_path/cat/$varfreq.$ii.nc
					let i++
				done
				rm -f $spool_path/check/${varfreq}_${mdl}_${exp}_${ens}_${year}.nc
				cdo -s cat $spool_path/cat/$varfreq.??.nc $spool_path/check/${varfreq}_${mdl}_${exp}_${ens}_${year}.nc
				rm -f $spool_path/cat/*
			else
				echo " ... File ${varfreq}_${mdl}_${exp}_${ens}_${year}.nc exists in check or ready"
			fi
		
			# Check calendar
			cal=`ncdump -h $spool_path/check/${varfreq}_${mdl}_${exp}_${ens}_${year}.nc | grep time:calendar | awk '{print $3}'`
			if [[ $cal == *"360_day"* ]];then
				ndays=360
			elif [[ $cal == *"365_day"* ]];then
				ndays=365
			else
				# Check for leap years
				ref=`date +%Y-%m-%d -d "$year-01-01 365 day"`
				if [ $ref == $((year+1))-01-01 ];then
					ndays=365
				else
					ndays=366
				fi
			fi
			
			## Check if files have all time-steps
			freq=`echo $varfreq | awk -F_ '{print $2}'`
			ntime=`cdo -s ntime $spool_path/check/${varfreq}_${mdl}_${exp}_${ens}_${year}.nc`

			if [[ $freq == *"mon"* ]];then
				if [ $ntime -eq 12 ];then
					mv $spool_path/check/${varfreq}_${mdl}_${exp}_${ens}_${year}.nc $spool_path/ready/
					#echo '    '${varfreq} ${year} ok!
				else
					echo '    Check FAILED For '${varfreq} ${year}
				fi
			else
				if [[ $freq == *"day"* ]] || [[ $freq == *"Day"* ]];then
					const=1
				elif [[ $freq == *"6hr"* ]];then
					const=4
				elif [[ $freq == *"3hr"* ]];then
					const=8
				fi
				if [ $ntime -eq $(($ndays*$const)) ];then 
					mv $spool_path/check/${varfreq}_${mdl}_${exp}_${ens}_${year}.nc $spool_path/ready/
					#echo '    '${varfreq} ${year} ok!
				else
				    echo '    Check FAILED For '${varfreq} ${year} -- $ntime timesteps
					# Anyadir que si $year es $syear puede tener todos-1 timesteps
					#			  si $year es $eyear puede tener un solo timestep
				fi
			fi

		done
	done
done

echo If all OK. Move files from spool/ready/ to ~/storage/models/$mdl/files/
echo If there are files in spool/check/ corrections may need to be made.
