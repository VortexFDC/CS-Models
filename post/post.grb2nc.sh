#!/bin/bash

##########################
#
#	Script de post proceso de un run a partir de grid2.
#	Selecciona las variables que esten en la lista var.lst y las pasa a netCDF
#
##########################

source /home/gil/.profile.local

run=acciona-mx.v3
mdl=IPSL-CM5A-LR

mkdir -p nc

echo 'Processing WRF output for '$mdl
for dm in d01 d02 d03;do

	for scen in rcp85 ;do # rcp85 ;do
		echo ' Working on '$scen $dm
		rdir=/home/martin/storage/runs/$run/wrfoutput/$mdl/$scen/
		
#		grib2nc :  81km -> 0.75 / 27km -> 0.25 / 9km -> 0.075 / 3km -> 0.025
		if [ "$dm" == "d01" ] ; then dx=0.75 ; dy=0.75 ; fi
		if [ "$dm" == "d02" ] ; then dx=0.25 ; dy=0.25 ; fi
		if [ "$dm" == "d03" ] ; then dx=0.075 ; dy=0.075 ; fi
		
		for v in $(awk -F, '{print $1}' var.lst);do
		
			if [ "$v" == "tas" ] ; then extra="" ; fi
			if [ "$v" == "pr" ] ; then extra="-mulc,3600" ; fi
			if [ "$v" == "wind" ] ; then extra="" ; fi
			
			code=$(grep $v var.lst | awk -F, '{print $2}')
			o=nc/wrf.$scen.$run.$dm.$v.nc

			rm -f $o
			rm -f grid.info
		
			for d in $(ls $rdir );do
				#echo $d
			
			    ls $rdir/$d | grep wrfout_arw_$dm > foo.1
				awk -Fgrb2f '{printf "%09.0f\n", $NF}' foo.1 > foo.2
				paste foo.1 foo.2 | sort -k 2 | awk '{if(NR>23) print $1}' > foo.lst
				for f in $(cat foo.lst);do
					#echo $f $v $code
					rm -f foo.grb2
					ln -s $rdir/$d/$f foo.grb2
				
					# getgrid
					if [ ! -f grid.info ] ; then
					wgrib2 foo.grb2 -grid -d $code > grid.info
					
					gtyp=$(awk '{if(NR==2)print $1}' grid.info)
			        nx=$(grep $gtyp grid.info | awk '{print substr($3,2,4)}')
			        ny=$(grep $gtyp grid.info | awk '{print substr($5,1,2)}')
			
					if [ "$gtyp" == "Mercator" ] ; then
				        la0=$(grep lat grid.info  | awk '{print $2}')
				        lo0=$(grep lon grid.info | awk '{print $2}')
				    fi
					if [ "$gtyp" == "Lambert" ] ; then
				        la0=$(grep Lat1 grid.info  | awk '{print $2}')
				        lo0=$(grep Lon1 grid.info | awk '{print $4}')
				    fi
					#echo $lo0:$nx:$dx $la0:$ny:$dy
				
				    fi 
				    
					if [ $code -eq 308 ] ; then
					wgrib2 foo.grb2 -for 308:309 -new_grid_interpolation bilinear -new_grid_winds earth -new_grid latlon $lo0:$nx:$dx $la0:$ny:$dy foo1.grb2 >> foo.log
					else
					wgrib2 foo.grb2 -d $code -new_grid_interpolation bilinear -new_grid_winds earth -new_grid latlon $lo0:$nx:$dx $la0:$ny:$dy foo1.grb2 >> foo.log
					fi
				
				
					wgrib2 foo1.grb2 -append -netcdf $o >> foo.log
				
					rm foo*
				done
			done
		if [ $code -eq 308 ];then
			cdo -s chname,VGRD_80maboveground,va -chname,UGRD_80maboveground,ua $o wrf.$scen.$run.$dm.$v.nc
		else
			cdo -s setname,$v $o wrf.$scen.$run.$dm.$v.nc
		fi

		rm $o
		save_path="/home/martin/storage/runs/$run/nc/$mdl/"
		mkdir -p $save_path
		mv wrf.$scen.$run.$dm.$v.nc $save_path
		echo "Files stored in: $save_path"
		done
	done
done
rm -f grid.info
rm -rf nc
