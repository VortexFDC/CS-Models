#!/bin/bash

#####################
#
#	This script builds list of days to be used in a given run. Adapted to suit any calendar
#		Selects days as (c4 Convention) 1 day simulation (+0.5 spin up) every 24 days.
#		Does this for all 3 experiments
#
#####################

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

	rm -f days.full.$exp.lst
	echo Building list of days for reanalysis $exp
	echo From: $sdate To: $edate

	i="0" # Work count
	while [ `echo $ydate | sed 's/-//g'` -lt `echo $edate | sed 's/-//g'` ];do 
		xdate=`date +%Y-%m-%d -d "$sdate $((1*$i)) day"`	 # Select all days
		
		i=$[$i+1]

		d=`echo $xdate | awk -F- '{print $3}'`
		m=`echo $xdate | awk -F- '{print $2}'`
		# Start next month if period needs next month
		if [ $d -gt 29 ] && [ $m -ne 2 ];then
			continue
		elif [ $d -gt 27 ] && [ $m -eq 2 ];then
			continue
		elif [ $d -eq 1 ];then
			continue
		fi

		ydate=`date +%Y-%m-%d -d "$xdate 1 day"`
		if [ `echo $ydate | sed 's/-//g'` -ge `echo $edate | sed 's/-//g'` ];then break;fi

		echo $xdate "--->" $ydate

		# Run a script from here
		
		echo $xdate >> days.full.$exp.lst
		
		# Until here
		i=$[$i+1]
	done
	njobs=`cat days.full.$exp.lst | wc -l`
	echo "... $njobs jobs will be needed"
	echo ''
done
