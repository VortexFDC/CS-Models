#!/bin/bash

######################################
#
#	Executes precook for all days abailable for the given model (based on days.$run.$exp.lst) for the selected model and experiment (and run)
#	Special case for HadGEM2-ES in dates
#	Spercial for HadGEM2-ES ACCESS1-0 in R enviroment
#		Launch as: nohup ./build.reanalysis.historical.sh > nohup.historical.out 2>&1 &
#
######################################

exp=historical
mdl=ACCESS1-0

mkdir -p /home/martin/storage/reanalysis/$mdl/$exp/

if [ $mdl == 'HadGEM2-ES' ] || [ $mdl == 'ACCESS1-0' ];then
	source /opt/anaconda/etc/profile.d/conda.sh
	conda activate Rclassic
fi

syear=1981
eyear=2005


for date in `cat ../days.real.full.$exp.lst`;do
	
	if [ `echo $date | sed 's/-//g'` -lt ${syear}0102 ];then continue;fi
	if [ `echo $date | sed 's/-//g'` -gt ${eyear}1230 ];then break;fi
	if [ $mdl == HadGEM2-ES ] && [ $exp == historical ] && [ `echo $date | sed 's/-//g'` -gt ${eyear}1127 ];then break;fi


	dtx=`echo $date | sed 's/-//g'`
	y1=`echo $date | awk -F- '{print $1}'`
	m1=`echo $date | awk -F- '{print $2}' | sed 's/^0*//'`
	m1=`printf "%02d" $m1`
	save=/home/martin/storage/reanalysis/$mdl/$exp/$y1/$y1.$m1

	if [ -f $save/$mdl.$exp.${dtx}00.grb.rar ] && [ -f $save/$mdl.$exp.${dtx}06.grb.rar ] && [ -f $save/$mdl.$exp.${dtx}12.grb.rar ] && [ -f $save/$mdl.$exp.${dtx}18.grb.rar ] ;then echo 'Grib file '$mdl.$exp.$dtx'??.grb.rar already exists';continue ;fi

	# System to relaunch precook if stuck
	maxloop=75
	for i in `seq 3`;do
		echo Launch precook num $i
		./precook.$mdl.sh $exp $date &
		PID=$!
		for loop in `seq $maxloop`;do
			sleep 2
			kill -0 $PID > /dev/null 2>&1
			EC=$?
			if [ $EC -eq 0 ] && [ $loop -eq $maxloop ]; then
				# Torna a llençar
				echo -----------------Redoing precook---------------
				kill -kill $PID
				break
			elif [ $EC -eq 0 ];then
				# Espera el seguent loop
				continue
			else
				# Surt de l loop i continua
				break 2
			fi
		done
	done

	#exit

done
