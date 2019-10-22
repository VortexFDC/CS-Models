# CS-Models

The aim of this repo is to launch simulations for any given model and experiment.
It needs to have an uems/run asociated.

0. **bin**		  	-> Binaries of cdo needed to run scripts (in cloud and in vega)
1. **splitCMIP5**	-> Only needed the first time per model (Independent from run). Standarices raw CMIP5 data.
2. **precook**  	-> Scripts (one per model) to build grib files ready to run wrf.
3. **run** 		    -> *(TO BE RUN IN VEGA) Scripts that launch WRF for the run. Paralel among experiments.
4. **post**	    	-> Stript to transporf grib2 files into netCDF filtering variables.

There will be a main script that does all at some point.
days.base.sh and days.$run.$exp.lst may be the same among all runs or not...

As some models (ex. HadGEM2-ES) only have 360 days per year days.$run.$exp.lst will be different for some models.
