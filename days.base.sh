#!/bin/bash

#####################
#
#	This script builds list of days to be used in a given run. For models with regular calendar.
#		Selects days as (c4 Convention) 1 day simulation (+0.5 spin up) every 24 days.
#		Does this for all 3 experiments
#
#####################

mdl=CNRM-CM5
run=acciona-mx.v3

for exp in historical rcp45 rcp85;do
	if [ $exp == historical ];then
		syear=1981
		period=25
	else
		syear=`cat split/model-period.dict | grep $mdl | awk '{print substr($NF,1,    4)}'`
		period=20
	fi

	sdate=$syear-01-02
	edate=`date +%Y-%m-%d -d "$sdate $period year -2 day"` 
	ydate=$sdate

	rm -f days.$run.$exp.lst
	echo Building list of days for $run $exp
	echo From: $sdate To: $edate

	i="0" # Work count
	while [ `echo $ydate | sed 's/-//g'` -lt `echo $edate | sed 's/-//g'` ];do 
		xdate=`date +%Y-%m-%d -d "$sdate $((24*$i)) day"`		# Seleccionem dies cada 24 dies
		ydate=`date +%Y-%m-%d -d "$xdate 2 day"`				# Agafem el dia mes un de spinoff
		if [ `echo $ydate | sed 's/-//g'` -ge `echo $edate | sed 's/-//g'` ];then break;fi

		#echo $xdate "--->" $ydate
		# Run a script from here
		
		echo $xdate >> days.$run.$exp.lst
		
		# Until here
		i=$[$i+1]
	done
	njobs=`cat days.$run.$exp.lst | wc -l`
	echo "... $njobs jobs will be needed"
	echo ''
done
