## Save each row of ten-year daily water balance as a “.nc” file to solve the problem of deficit of computer memory
rm(list = ls())
library(ncdf4)
mainDir <- " \\ERA5_Singer\\NC_ZH\\"
OutDir <- " \\ERA5_Singer\\NC_Row\\1982_1991\\"  # 1992_2001 2002_2011 2012_2021
WD <- array(-9999, dim=c(720,1440,3652)) 
t1 <- 0  
for(i in 1982:1991){    
  ncin <- nc_open(paste(mainDir, as.character(i),".nc", sep=""))
  D_array<- ncvar_get(ncin,"Water_Deficit")
  if( i%%4 == 0){
    t2 <- t1+1
    t1 <- t1+366
    t3 <- 366
    t4 <- 731
  } else if (i%%4 == 1){ 
    t2 <- t1+1
    t1 <- t1+365
    t3 <- 367
    t4 <- 731
  } else{
    t2 <- t1+1
    t1 <- t1+365
    t3 <- 366
    t4 <- 730
  }
  WD[,,t2:t1] <- D_array[,,t3:t4]
  nc_close(ncin)
  rm(D_array) 
}
for(j in 1:720){
  tem1 <- WD[j,,]
  tem1[is.nan(tem1)] <- -9999
  
  longitude <- ncdim_def( name = 'longitude', units = 'degrees_east', vals = seq(1,3652,1) )  
  latitude <- ncdim_def( name = 'latitude', units = 'degrees_north', vals = seq(1,1440,1) )
  ncfname <- paste(OutDir, as.character(j),".nc", sep="")
  dlname <- "Daily water deficit" 
  Fillvalue <- 1e32
  spei_def <- ncvar_def("Water_Deficit","mm/day",list(latitude,longitude),Fillvalue,dlname,prec="double",compression=9)  # 
  ncout <- nc_create(ncfname,vars= spei_def,force_v4=TRUE)
  # put variables 
  ncvar_put(nc=ncout,varid=spei_def,vals=tem1) 
  rm(tem1)
  nc_close(ncout)
}
