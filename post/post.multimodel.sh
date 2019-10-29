#!/bin/bash

run=acciona-mx.v3
var=tas

models_path='/home/martin/storage/models'

rm -f summary.$var

for exp in historical rcp45 rcp85;do
	echo -e "$exp
models\t\td01\td02\td03" >> summary.$var
	
	for mdl in `ls $models_path`;do
		f=$models_path/$mdl/out/wrfoutput/$run/$exp/wrf.$exp.$run.d01.$var.nc
		if [ ! -f $f ];then continue;fi
		echo Getting results for $mdl ($exp) ...
		
		echo $mdl > foo.d00
		for dom in d01 d02 d03;do
			f=$models_path/$mdl/out/wrfoutput/$run/$exp/wrf.$exp.$run.$dom.$var.nc
			cdo -s timmean $f $mdl.$exp.$run.$dom.$var.mean.nc
			cdo -s info -fldmean $mdl.$exp.$run.$dom.$var.mean.nc | awk '{print $9}' > foo.$dom
		done


		
		paste foo.d?? >> summary.$var
		rm -f foo.d??
	
	done
	echo '' >> summary.$var
done

echo 'Summary $var created!'
