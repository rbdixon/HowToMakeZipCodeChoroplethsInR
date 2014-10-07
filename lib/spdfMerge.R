#' This function merges the data within a Spatial*DataFrame (spdf)
#' with a second specified data frame (mdf)
#'
#' Merging data with an existing Spatial*DataFrame is problematic
#' because merge() does not maintain the original order. This function
#' relies on match() and performs a classic 'left join' merge while
#' maintaining order
#' 
#' @param spdf Spatial*DataFrame 
#' @param mdf dataframe to match with spdf
#' 
#' @return an object of class Spatial*DataFrame matching spdf
#' @export
#' @author Josh M London \email{josh.london@@noaa.gov}
spdfMerge<-function(spdf,mdf,by) {
	spdf@data<-data.frame(spdf@data, 
	mdf[match(spdf@data[,by], 
	mdf[,by]),])
	return(spdf)
}