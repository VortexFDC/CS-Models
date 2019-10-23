library(ncdf4)

nc=nc_open('scratch.HadGEM2-ES/hlev/ta_short.nc')
z1=ncvar_get(nc,'orog')
t=ncvar_get(nc,'ta')
a=ncvar_get(nc,'lev')
nc_close(nc)

#nc=nc_open('files/ta_6hrLev_ACCESS1-0_historical_r1i1p1_1990010106-1991010100.nc')
#b=ncvar_get(nc,'b')
#nc_close(nc)

b=c(0.99771649, 0.9908815, 0.97954255, 0.96377707, 0.94369549, 0.91943836, 0.89117801, 0.85911834, 0.82349348, 0.78457052, 0.74264622, 0.6980502, 0.65114272, 0.60231441, 0.55198872, 0.50061995, 0.44869339, 0.39672577, 0.34526527, 0.29489139, 0.24621508, 0.19987822, 0.15655422, 0.11694787, 0.08179524, 0.05186372, 0.02793682, 0.01071648, 0.00130179, 0, 0, 0, 0, 0, 0, 0, 0, 0)

#ix=which(b>0)
#b=b[ix]
#a=a[ix]

nc=nc_open('scratch.HadGEM2-ES/hlev/ps_short.nc')
p1=ncvar_get(nc,'ps')
nc_close(nc)

z2=array(NA,dim=c(dim(z1),length(a)))

for(i in 1:length(a)){
z2[,,i]=a[i]+b[i]*z1-z1
}

Rd=287 
g=9.8
con = g/Rd


p2=array(NA,dim=dim(t))

for(j in 1:dim(t)[4]){
for(i in 1:length(a)){
p2[,,i,j] = p1[,,j]* exp(-(con/t[,,i,j])*(z2[,,i]))
}}

system(paste('cdo -s -r copy -setvar,ps -selvar,ta -sellevidx,$(seq -s, 1 ',format(length(a)),') scratch.HadGEM2-ES/hlev/ta_short.nc scratch.HadGEM2-ES/hlev/foo.pressure.nc',sep=''))
nc=nc_open('scratch.HadGEM2-ES/hlev/foo.pressure.nc',write=TRUE)

for(j in 1:dim(t)[4]){
for(i in 1:length(a)){
ncvar_put(nc,'ps',p2[,,i,j],start=c(1,1,i,j),count=c(-1,-1,1,1))
}}

nc_close(nc)
