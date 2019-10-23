;*************************************************
; grid_fill_2.ncl
;*************************************************
;
; Concepts illustrated:
;   - Reading a NetCDF file
;   - Setting parameters for "poisson_grid_fill"
;   - Illustrating before and after application of poisson_grid_fill
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin
                                   
  f     = addfile (fn1 , "r")

tmp = str_split(fn1,"/")
tmp2 = tmp(2)
tmp3 = str_split(tmp2,".")
var = tmp3(0)
pref = tmp(0)
  
  x     = f->$var$

;-----------------------------------------------------------------
; Set the poisson_grid_fill variables
; Global grid: Fill in over land             
;-----------------------------------------------------------------
  nscan = 2000             ; usually *much* fewer
  eps   = 0.001            ; variable depended
  gtype = True             ; Cyclic in longitude [global]
  guess = 0                ; use zonal means
  relc  = 0.6              ; standard relaxation coef
  opt   = 0

  poisson_grid_fill( x, gtype, guess, nscan, eps, relc, opt)

;-----------------------------------------------------------------
; Regional grid: interpolation and extrapolation         
;-----------------------------------------------------------------
  y    = x


;  gtype = False            ; regional ... not cyclic in lon
  poisson_grid_fill( y, gtype, guess, nscan, eps, relc, opt)


  f     = addfile (pref+"/zinter/"+var+".nc" , "c")
  f->$var$=y     

end
