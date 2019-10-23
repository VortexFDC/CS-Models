load "/home/vortex/lib/ncl6/lib/ncarg/nclscripts/csm/contributed.ncl"

tmp1 = str_split(fn1,"/")
tmp2 = str_split(tmp1(2),".")
var = tmp2(0)

fn2 = "scratch.XmodelX/hlev/foo.pressure.nc"
if (var .eq. "va") then
	fn2 = "scratch.XmodelX/hlev/foo.pressure.va.nc"
end if

f=addfile(fn1,"r")
q=f->$var$(:,0:27,:,:)
f=addfile(fn2,"r")
pres=f->ps(:,0:27,:,:)

plev = (/ 100000,97500,95000,92500,90000,87500,85000,82500,80000,77500,75000,70000,65000,60000,55000,50000,45000,40000,35000,30000 /)

qp=linint1_n_Wrap(pres, q, False, plev, 0, 1)

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

poisson_grid_fill( qp, gtype, guess, nscan, eps, relc, opt)

qp!1 = "lev"
qp&lev@units="Pa"
qp&lev@long_name="Pressure"
qp&lev@axis="Z"


system("rm -f scratch.XmodelX/zinter/"+var+".nc")
g=addfile("scratch.XmodelX/zinter/"+var+".nc","c")
g->$var$=qp
