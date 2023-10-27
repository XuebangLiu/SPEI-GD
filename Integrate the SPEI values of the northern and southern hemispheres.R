## Integrate the SPEI values of the northern and southern hemispheres, store them in ".nc" format, and write the necessary captions 
rm(list=ls())
library(sp)
library(raster)
library(rgdal)
library(raster)
library(rasterVis)
library(terra)
library(lattice)
library(latticeExtra)
library(ncdf4)
mainDir_NH <- " \\ERA5_Singer\\All_Period\\5day\\Year\\NH\\"
mainDir_SH <- " \\ERA5_Singer\\All_Period\\5day\\Year\\SH\\"
OutDir <- " \\ERA5_Singer\\All_Period\\"
maskDir <- " \\Reference\\"
referDir <- " \\NC\\"
k <- 5
fillvalue <- -9999
land <- raster(paste(maskDir, "reference_no_Dry.tif", sep=""))
land<-c(as.matrix(land)) 
mask <- which(is.na(land))
refer1 <- nc_open("E:\\PET\\GLEAM\\NC\\Ep_1981_GLEAM_v3.6a.nc") 
lon <- ncvar_get(refer1,"lon")  # longitude
lat <- ncvar_get(refer1,"lat")  # latitude
nc_close(refer1)
for(i in 1982: 2021){
  
  if( i%%4 == 0){
    t <- 366
  } else{
    t <- 365
  }
  ncin_NH <- nc_open(paste(mainDir_NH, as.character(i),".nc", sep=""))
  D_array_NH<- ncvar_get(ncin_NH,"spei")
  ncin_SH <- nc_open(paste(mainDir_SH, as.character(i),".nc", sep=""))
  D_array_SH<- ncvar_get(ncin_SH,"spei")
  D_array <- array(fillvalue, dim=c(720,1440,t))  
  for(j in 1: t){
    tem1 <- rbind(D_array_NH[,,j],D_array_SH[,,j])
    tem2 <-c(as.matrix(tem1)) 
    tem2[mask] <- fillvalue
    D_array[,,j] <- matrix(tem2, nrow = 720, byrow = FALSE)
  }
  nc_close(ncin_NH)
  nc_close(ncin_SH)
  rm(D_array_NH) 
  rm(D_array_SH)
  refer2 <- nc_open(paste(referDir,"Ep_",as.character(i),"_GLEAM_v3.6a.nc", sep="")) 
  time <- ncvar_get(refer2,"time")  # longitude
  tunits <- ncatt_get(refer2,"time","units")
  nc_close(refer2)  
  # path and file name
  ncfname <- paste(OutDir, as.character(k),"day\\Year\\Global\\Daily_SPEI_",as.character(i), "_",as.character(k), "Day.nc", sep="") 
  # create and write the netCDF file -- ncdf4 version 
  # define dimensions 
  londim <- ncdim_def("lon","degrees_east",as.double(lon)) 
  latdim <- ncdim_def("lat","degrees_north",as.double(lat)) 
  timedim <- ncdim_def("time",tunits$value,as.double(time)) 
  # define variables 
  dlname <- "Daily Standardized Precipitation Evapotranspiration Index" 
  Fillvalue <- 1e32
  spei_def <- ncvar_def("spei","z value",list(latdim,londim,timedim),Fillvalue,dlname,prec="double",compression=9)
  # create netCDF file and put arrays 
  # ncout <- nc_create(ncfname,vars= spei_def,force_v4=TRUE) 
  ncout <- nc_create(ncfname,vars= spei_def,force_v4=TRUE)
  # put variables 
  ncvar_put(nc=ncout,varid=spei_def,vals=D_array)  ## test2
  # put additional attributes into dimension and data variables 
  ncatt_put(ncout,"lon","axis","Y") #,verbose=FALSE) #,definemode=FALSE) 
  ncatt_put(ncout,"lat","axis","X") 
  ncatt_put(ncout,"time","axis","T") 
  # add global attributes 
  ncatt_put(ncout,0,"title",'Global Daily SPEI') 
  ncatt_put(ncout,0,"institution",'Peking University') 
  ncatt_put(ncout,0,"source",'ERA5 for Precipitation and Singer_PET for Potential Evaporation') 
  ncatt_put(ncout,0,"Scale",as.character(k)) 
  nc_close(ncout)
  rm(D_array)
}
