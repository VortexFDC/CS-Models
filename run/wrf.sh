#!/bin/bash

##
#
# Runs WRF (in vega). Gets grib files from cloud1 (storage). Saves output as grib2 in cloud1 (storage).
#
##

run=$1
mdl=$2
exp=$3
idate=$4
path=`pwd`

if [ `echo $run $mdl $exp $idate | wc -w` -ne 4 ];then echo 'Please check parameters given ...
Needs: run model experiment date';exit;fi

if [ -z "$idate" ] || [ `echo $idate | awk -F- '{print NF}'` -ne 3 ];then echo 'Please specify start date in format YYYY-MM-DD';exit;fi

idate=`echo $idate | sed 's/-//g'`
fdate=`date +%Y%m%d -d "$idate 2 day"`
hours=36	# 1 day simulation + 0,5 day spinup

savePath=/home/martin/storage/runs/$run/wrfoutput/$mdl/$exp/$idate.$fdate/
ssh cloud1.vortex.es 'mkdir -p '$savePath
# Check if run exists in storage
wrks=`ssh cloud1.vortex.es 'ls '$savePath' | wc -l'`
if [ $wrks -eq 111 ];then echo 'Work previously computed. Skipping...';exit;fi

# Find number of domains of the run
d=`ls $path/$run.$exp/static/geo_em.d*.nc | wc -l`
t=`seq $d | tr '\n' ','`
doms=`echo ${t:: -1}`

## Get data files from cloud1 (storage)
echo Spliting days from $idate to $fdate ...
cd $path/$run.$exp/grib
rm -f $mdl.$exp.* cmip5*
scp cloud1.vortex.es:/home/martin/storage/models/$mdl/wrfinput/$mdl.$exp.$idate.$fdate.grb .

# Split days
echo $idate $fdate $hours
# Funciona tmb per rcp pq els gribs de rcp ja tanen el timeshift
for d in `cdo -s showdate $mdl.$exp.$idate.$fdate.grb`;do
	n=`echo $d | sed 's/-//g'`
	cdo -s seldate,$d $mdl.$exp.$idate.$fdate.grb cmip5.$n.grb
done

# Shifttime when rcpXX
if [[ $exp == *"rcp"* ]];then
    d0=`date +%Y%m%d -d "$idate -100 year"`
else
	d0=$idate
fi

## Run ems_prep
echo Runing ems_prep
cd $path/$run.$exp
# 	To start al half day --cycle 12 
ems_prep --dset cmip5:none:local --date $d0 -length $hours --cycle 12 --analysis --noaerosol --domain $doms 	# To start al half day --cycle 12 

## Run ems_run
ems_run --domain $doms

## Run ems_post
ems_post --grib  --domain $doms

## Move wrfouts to cloud1 (storage)
echo Moving files to cloud1.vortex.es:$savePath
scp emsprd/grib/* cloud1.vortex.es:$savePath

rm -f grib/* wpsprd/* wrfprd/* emsprd/grib/*
cd $path
