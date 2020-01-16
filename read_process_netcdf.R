library(ncdf4)
library(gsubfn)

# Extract vertical/atmospheric temperature layers from grid point(s)

# create empty matrix
data_mat <-matrix(nrow =0, ncol = 5)
colnames(data_mat) <- c("date","surfair.tmp","hpa925.tmp","hpa850.tmp","hpa700.tmp")

# generate list of netCDF files in directory 
files <- list.files(path ="path_to_files/", "*.nc4", full.names = TRUE )

# apply  
tmp_list <-lapply(files, function(x){
  file_path <- x
  
  # open netCDF file
  netcdf_data <- nc_open(file_path)
  
  vec <- c(0,0,0,0,0)
 
  # extract date from filename
  datestr <- strapplyc(file_path,"AIRS.(.*).L3", simplify = TRUE) # second argument of strapplyc() depending on consistent file naming patterns
  
  # get Variable Surface Air Temperature (dimensions: Longitude, Latitude)
  surfair_tmp <- ncvar_get(netcdf_data,"SurfAirTemp_D")
  
  # get atmospheric air temperature layers (dimensions: Longitude, Latitude, Standard Pressure Level)
  air_tmp <- ncvar_get(netcdf_data,"Temperature_D")
  
  vec[1] <- datestr
  vec[2] <- surfair_tmp[2,2] # surfair_tmp[Longitude, Latitude]
  vec[3] <- air_tmp[2,2,2] # air_tmp[Longitude, Latitude, Standard Pressure Level]
  vec[4] <- air_tmp[2,2,3]
  vec[5] <- air_tmp[2,2,4]
  vec
})

for (i in 1:length(tmp_list))
{
  data_mat<-rbind(data_mat,as.vector(tmp_list[[i]],mode = "character"))
}

data_df <- as.data.frame(data_mat)

