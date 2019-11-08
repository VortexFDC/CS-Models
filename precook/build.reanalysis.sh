#!/bin/bash

######################################
#
#	Executes precook for all days abailable for the given model (based on days.$run.$exp.lst) for the selected model and experiment (and run)
#	Special case for HadGEM2-ES in dates
#	Spercial for HadGEM2-ES ACCESS1-0 in R enviroment
#
######################################

exp=historical
mdl=ACCESS1-0

mkdir -p /home/martin/storage/models/$mdl/wrfinput/

if [ $mdl == 'HadGEM2-ES' ] || [ $mdl == 'ACCESS1-0' ];then
	source /opt/anaconda/etc/profile.d/conda.sh
	conda activate Rclassic
fi

if [ $exp == historical ];then
	syear=1981
	eyear=2005
else
	syear=`cat ../model-period.dict | grep $mdl | awk '{print substr($NF,1,4)}'`
	eyear=`cat ../model-period.dict | grep $mdl | awk '{print substr($NF,6,4)}'`
fi


for date in `cat ../days.full.$exp.lst`;do
	
	if [ `echo $date | sed 's/-//g'` -lt ${syear}0102 ];then continue;fi
	if [ `echo $date | sed 's/-//g'` -gt ${eyear}1227 ];then break;fi
	if [ $mdl == HadGEM2-ES ] && [ $exp == historical ] && [ `echo $date | sed 's/-//g'` -gt ${eyear}1127 ];then break;fi
	
	echo $date
	#./precook.$mdl.sh $exp $date

done
