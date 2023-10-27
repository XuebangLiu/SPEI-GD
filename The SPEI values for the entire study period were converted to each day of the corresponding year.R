## The SPEI values for the entire study period were converted to each day of the corresponding year, here only the Northern Hemisphere was converted to prevent memory starvation 
rm(list=ls())
library(ncdf4)
mainDir <- " \\ERA5_Singer\\All_Period\\5day\\Row\\"
OutDir <- " \\ERA5_Singer\\All_Period\\5day\\Year\\NH\\"
fillvalue <- -9999
SPEI_Last <- array(fillvalue, dim=c(360,1440,14610))
for(pixel in 1: 360){  
  ncin <- nc_open(paste(mainDir, as.character(pixel),".nc", sep=""))
  D_array<- ncvar_get(ncin,"spei")
  aa <-  array(D_array, dim = c(1, 1440, 14610))
  SPEI_Last[pixel,,] <-  array(D_array, dim = c(1, 1440, 14610))
  rm(D_array)
}
t1 <- 0 
for(i in 1982: 2021){  
  if( i%%4 == 0){
    t2 <- t1+1
    t1 <- t1+366
    t3 <- 366
  } else{
    t2 <- t1+1
    t1 <- t1+365
    t3 <- 365
  } 
  spei_year <- SPEI_Last[,,t2:t1]
  X <- ncdim_def( name = 'Row', units = 'X', vals = seq(1,360,1) )
  Y <- ncdim_def( name = 'Column', units = 'Y', vals = seq(1,1440,1)) 
  Z <- ncdim_def( name = 'Days', units = 'Z', vals = seq(1,t3,1)) 
  ncfname <- paste(OutDir,as.character(i), ".nc", sep="")
  dlname <- "NH_Daily spei during 1982-2018" 
  Fillvalue <- 1e32
  spei_def <- ncvar_def("spei","z value",list(X,Y,Z),Fillvalue,dlname,prec="double",compression=9) 
  ncout <- nc_create(ncfname,vars= spei_def,force_v4=TRUE)
  # put variables 
  ncvar_put(nc=ncout,varid=spei_def,vals=spei_year) 
  rm(spei_year)
  nc_close(ncout) 
}
