#!/bin/bash

######################################
#
#	Runs WRF for all days abailable for the given model (based on days.$run.$exp.lst) for the selected model and experiment (and run)
#	Special case for HadGEM2-ES
#		Launch as: nohup run.wrf.sh > nohup.$exp.out 2>&1 &
#
######################################

run=acciona-mx.v3
mdl=ACCESS1-0
exp=rcp85

scp cloud1.vortex.es:/home/martin/models/head/{model-period.dict,days.$run.$exp.lst} .

if [ $exp == historical ];then
	syear=1981
	eyear=2005
else
	syear=`cat model-period.dict | grep $mdl | awk '{print substr($NF,1,4)}'`
	eyear=`cat model-period.dict | grep $mdl | awk '{print substr($NF,6,4)}'`
fi

# Create directory for run.exp
cp -r $run $run.$exp

for date in `cat days.$run.$exp.lst`;do
	
	if [ `echo $date | sed 's/-//g'` -lt ${syear}0102 ];then continue;fi
	if [ `echo $date | sed 's/-//g'` -gt ${eyear}1227 ];then break;fi
	if [ $mdl == HadGEM2-ES ] && [ $exp == historical ] && [ `echo $date | sed 's/-//g'` -gt ${eyear}1127 ];then break;fi

	./wrf.sh $run $mdl $exp $date

done

rm -r $run.$exp
