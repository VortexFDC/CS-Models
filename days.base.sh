#!/bin/bash

#####################
#
#	This script builds list of days to be used in a given run. Adapted to suit any calendar
#		Selects days as (c4 Convention) 1 day simulation (+0.5 spin up) every 24 days.
#		Does this for all 3 experiments
#
#####################

run=acciona-mx.v3

for exp in historical rcp45 rcp85;do
	if [ $exp == historical ];then
		syear=1981
		eyear=2005
	else 
		syear=2020
		eyear=2046
	fi

	sdate=$syear-01-02
	ydate=$sdate

	edate=$eyear-12-30

	rm -f days.$run.$exp.lst
	echo Building list of days for $run $exp
	echo From: $sdate To: $edate

	i="0" # Work count
	while [ `echo $ydate | sed 's/-//g'` -lt `echo $edate | sed 's/-//g'` ];do 
		xdate=`date +%Y-%m-%d -d "$sdate $((24*$i)) day"`		# Seleccionem dies cada 24 dies
		
		d=`echo $xdate | awk -F- '{print $3}'`
		m=`echo $xdate | awk -F- '{print $2}'`
		# Start next month if period needs next month
		if [ $d -gt 27 ] && [ $m -ne 2 ];then
			xdate=`date +%Y-%m-%d -d "$xdate -$((d-2)) day 1 month"`
		elif [ $d -gt 25 ] && [ $m -eq 2 ];then
			xdate=`date +%Y-%m-%d -d "$xdate -$((d-2)) day 1 month"`
		elif [ $d -eq 1 ];then
			xdate=`date +%Y-%m-%d -d "$xdate 1 day"`
		fi

		ydate=`date +%Y-%m-%d -d "$xdate 2 day"`				# Agafem el dia mes un de spinoff
		if [ `echo $ydate | sed 's/-//g'` -ge `echo $edate | sed 's/-//g'` ];then break;fi

		echo $xdate "--->" $ydate

		# Run a script from here
		
		echo $xdate >> days.$run.$exp.lst
		
		# Until here
		i=$[$i+1]
	done
	njobs=`cat days.$run.$exp.lst | wc -l`
	echo "... $njobs jobs will be needed"
	echo ''
done
