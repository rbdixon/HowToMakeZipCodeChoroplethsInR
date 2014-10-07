# # Set an ID prior to fortifying for plotting
# shapes.sp@data$id = rownames(shapes.sp@data)
# 
# # Fortify
# state.df = fortify(state.sp)
# state.df = merge(state.df, state.sp@data, by="id")

fortifyMerge = function(shapes.sp, col="id") {
  shapes.sp@data[,col] = rownames(shapes.sp@data)
  shapes.df = fortify(shapes.sp)
  shapes.df = merge(shapes.df, shapes.sp@data, by=col, all.x=TRUE)
  return(shapes.df)
}