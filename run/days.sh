#!/bin/bash

#####################
#
#	Day selection for acciona 1(+1) cada 24 (c4)
#
#####################

run=acciona-mx.v3
mdl=CNRM-CM5
exp=rcp45

if [ $exp == historical ];then
	syear=1981
	period=25
else
	syear=2026
	period=20
fi

sdate=$syear-01-02
edate=`date +%Y-%m-%d -d "$sdate $period year -2 day"` 
ydate=$sdate

echo Inicio: $sdate
echo Fin:    $edate

i="0" # Work count
while [ `echo $ydate | sed 's/-//g'` -lt `echo $edate | sed 's/-//g'` ];do 
xdate=`date +%Y-%m-%d -d "$sdate $((24*$i)) day"`		# Seleccionem dies cada 24 dies
ydate=`date +%Y-%m-%d -d "$xdate 2 day"`				# Agafem el dia mes un de spinoff
if [ `echo $ydate | sed 's/-//g'` -ge `echo $edate | sed 's/-//g'` ];then exit;fi

echo $xdate "--->" $ydate
# Run a script from here

./run.sh $run $mdl $exp $xdate

exit

# Until here
i=$[$i+1]
done


