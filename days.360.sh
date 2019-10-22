#!/bin/bash

#####################
#
#	NOT IN USE
#
#	This script builds list of days to be used in a given run if the calendar of the model is 360_day
#		Selects days as (c4 Convention) 1 day simulation (+0.5 spin up) every 24 days.
#		Does this for all 3 experiments
#		To use for: HadGEM-ES, 
#
#####################

mdl=HadGEM2-ES
run=acciona-mx.v3

for exp in historical rcp45 rcp85;do
	if [ $exp == historical ];then
		syear=1981
		eyear=2005
	else
		syear=`cat model-period.dict | grep $mdl | awk '{print substr($NF,1,4)}'`
		eyear=`cat model-period.dict | grep $mdl | awk '{print substr($NF,6,4)}'`
	fi

	sdate=$syear-01-02
	ydate=$sdate
	# May only be needed for HadGEM
	if [ $exp == historical ] ;then
		edate=$eyear-11-30
	else
		edate=$eyear-12-31
	fi

	rm -f days.$run.$exp.lst
	echo Building list of days for $run $exp '(for 360_day calendar models)'
	echo From: $sdate To: $edate

	while [ `echo $ydate | sed 's/-//g'` -lt `echo $edate | sed 's/-//g'` ];do
		y=`echo $ydate | sed 's/-//g'`

		x1=$((y+22))
		y1=$((y+24))

		if [ `echo ${x1:6:2}` -gt 30 ];then
			x1=$((x1-30+100))
		fi
		if [ `echo ${x1:4:2}` -gt 12 ];then
			x1=$((x1-1200+10000))
		fi
		
		if [ `echo ${y1:6:2}` -gt 30 ];then
			y1=$((y1-30+100))
		fi  
		if [ `echo ${y1:4:2}` -gt 12 ];then
			y1=$((y1-1200+10000))
		fi

		xy=`echo ${x1:0:4}`
		xm=`echo ${x1:4:2}`
		xd=`echo ${x1:6:2}`
		xdate=`echo "$xy-$xm-$xd"`

		yy=`echo ${y1:0:4}`
		ym=`echo ${y1:4:2}`
		yd=`echo ${y1:6:2}`
		ydate=`echo "$yy-$ym-$yd"`

		if [ `echo $ydate | sed 's/-//g'` -ge `echo $edate | sed 's/-//g'` ];then break;fi

		echo $xdate $ydate

	done

#	i="0" # Work count
#	while [ `echo $ydate | sed 's/-//g'` -lt `echo $edate | sed 's/-//g'` ];do 
#		xdate=`date +%Y-%m-%d -d "$sdate $((24*$i)) day"`		# Seleccionem dies cada 24 dies
#		ydate=`date +%Y-%m-%d -d "$xdate 2 day"`				# Agafem el dia mes un de spinoff
#		if [ `echo $ydate | sed 's/-//g'` -ge `echo $edate | sed 's/-//g'` ];then break;fi
#
#		#echo $xdate "--->" $ydate
#		# Run a script from here
#		
#		echo $xdate >> days.$run.$exp.lst
#		
#		# Until here
#		i=$[$i+1]
#	done
#	njobs=`cat days.$run.$exp.lst | wc -l`
#	echo "... $njobs jobs will be needed"
#	echo ''
done
