#!/bin/bash

######################################
#
#	Executes precook for all days abailable for the given model (based on days.$run.$exp.lst) for the selected model and experiment (and run)
#	Special case for HadGEM2-ES
#
######################################

run=acciona-mx.v3
exp=historical

mdl=HadGEM2-ES

if [ $exp == historical ];then
	syear=1981
	eyear=2005
else
	syear=`../cat model-period.dict | grep $mdl | awk '{print substr($NF,1,4)}'`
	eyear=`../cat model-period.dict | grep $mdl | awk '{print substr($NF,6,4)}'`
fi


for date in `cat ../days.$run.$exp.lst`;do
	
	if [ `echo $date | sed 's/-//g'` -lt ${syear}0102 ];then continue;fi
	if [ `echo $date | sed 's/-//g'` -gt ${eyear}1227 ];then break;fi
	if [ $mdl == HadGEM2-ES ] && [ $exp == historical ] && [ `echo $date | sed 's/-//g'` -gt ${eyear}1127 ];then break;fi

	./precook.$mdl.sh $exp $date

done