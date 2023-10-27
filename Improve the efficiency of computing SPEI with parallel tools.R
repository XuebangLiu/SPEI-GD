# Improve the efficiency of computing SPEI with parallel tools
rm(list=ls())
library(parallel)
myfunc <- function(row_WD){ 
  library(SPEI)
  library(sp)
  library(raster)
  library(rgdal)
  library(raster)
  library(rasterVis)
  library(terra)
  library(lattice)
  library(latticeExtra)
  library(ncdf4)
  #setwd(OutDir)
  mainDir <- "F:\\SPEI\\Water Balance\\ERA5_Singer\\NC_Row\\"
  OutDir <- "E:\\SPEI\\SPEI\\ERA5_Singer\\All_Period\\"
  i <- row_WD
  fillvalue <- -9999
  # integrate the data of all days during 1982-2021 on a single row 
  ncin1 <- nc_open(paste(mainDir,"1982_1991\\", as.character(i),".nc", sep=""))
  D_array1<- ncvar_get(ncin1,"Water_Deficit")
  ncin2 <- nc_open(paste(mainDir,"1992_2001\\", as.character(i),".nc", sep=""))
  D_array2<- ncvar_get(ncin2,"Water_Deficit")
  
  ncin3 <- nc_open(paste(mainDir,"2002_2011\\", as.character(i),".nc", sep=""))
  D_array3<- ncvar_get(ncin3,"Water_Deficit")
  ncin4 <- nc_open(paste(mainDir,"2012_2021\\", as.character(i),".nc", sep=""))
  D_array4<- ncvar_get(ncin4,"Water_Deficit")
  WD <- cbind(D_array1,D_array2,D_array3,D_array4)
  D_size<- dim(WD)
  # calculate spei 
  Result <- matrix(fillvalue, ncol=D_size[2], nrow= D_size[1], dimnames= list(seq(1:D_size[1]), c(1:D_size[2])))
  k=7  # scale
  for(pixel in 1: nrow(WD)){
    wichita <- matrix(fillvalue, ncol=1, nrow= D_size[2], dimnames= list(seq(1:D_size[2]), c(1)))
    wichita[,1] <- WD[pixel,]
    if (any(wichita==fillvalue)){
      Result[pixel,] <- fillvalue
    } else {
      spei1 <- spei(wichita[,1],k)
      wichita1 <- matrix(fillvalue, ncol=1, nrow= D_size[2], dimnames= list(seq(1:D_size[2]), c(1)))
      wichita1 <- as.matrix(spei1$fitted)
      wichita1[is.nan(wichita1)] <- fillvalue
      wichita1[is.na(wichita1)] <- fillvalue
      wichita1[wichita1== -Inf] <- fillvalue
      wichita1[wichita1== Inf] <- fillvalue
      Result[pixel,] <- wichita1
    }
  }
  rm(WD)
  Y <- ncdim_def( name = 'All Days', units = 'Y', vals = seq(1,D_size[2],1) ) 
  X <- ncdim_def( name = 'Column', units = 'X', vals = seq(1,D_size[1],1) )
  ncfname <- paste(OutDir, as.character(k),"day\\",as.character(i), ".nc", sep="")
  dlname <- "All_Daily spei during 1982-2018" 
  Fillvalue <- 1e32
  spei_def <- ncvar_def("spei","z value",list(X,Y),Fillvalue,dlname,prec="double",compression=9) 
  ncout <- nc_create(ncfname,vars= spei_def,force_v4=TRUE)
  # put variables 
  ncvar_put(nc=ncout,varid=spei_def,vals=Result) 
  rm(Result)
  nc_close(ncout) 
}
system.time({
  x <- 1: 720
  cl <- makeCluster(35) 
  results <- parLapply(cl,x,myfunc) 
  stopCluster(cl) 
})
