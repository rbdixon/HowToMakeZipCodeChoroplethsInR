filterLocalZipSPDF = function(visitorzips.spdf) {
  # # To get a good map it would be ideal to get rid of zip codes that are far away
  zips.coords = coordinates(visitorzips.spdf) # list of zip centroids
  zips.nb = tri2nb(zips.coords, row.names=row.names(zips.coords)) # neightbour list
  zips.dist = nbdists(zips.nb, zips.coords) # distance to nearest neighbours
  
  # plot(zips.nb, zips.coords, pch=".", col="red")
  
  # 3rd quartile
  zips.dist.3q = summary(unlist(zips.dist))[5]
  
  # Just those zips which are less than the 3q
  zips.close = unlist(llply(zips.dist, function(d) {
    any(d <= zips.dist.3q)
  }))
  
  return(visitorzips.spdf = visitorzips.spdf[zips.close,])
}

getBaseMap = function(long, lat, zoom) {
  base = getmapbox_map(c(long, lat), mapbox="rbdixon.hl5lib8k", zoom=zoom)
  
  map = map_png(base)
#   map = map_png(base, extent = "normal", maprange=FALSE) +
#     coord_map(projection="mercator", 
#               xlim=c(attr(base, "bb")$ll.lon, attr(base, "bb")$ur.lon),
#               ylim=c(attr(base, "bb")$ll.lat, attr(base, "bb")$ur.lat))
  
  return(map)
}

zchoropleth = function(ZTABLE, ZIPS.spdf, valuecol, long, lat) {
  # Drop small zips
  Z = ZTABLE[ZTABLE[,valuecol]>30,] # Re-identification protection
  
  if (nrow(Z)>0) {
    # Get just the zip shapes we need
    visitorzips.spdf = ZIPS.spdf[ZIPS.spdf$ZCTA5CE10 %in% as.character(Z$zip),]
  
    # FIXME: Not all observed zips map into ZCTA5CE10
    # Probably due to zip to ZCTA mapping errors
    Z = Z[Z$zip %in% as.character(visitorzips.spdf@data$ZCTA5CE10), ]  

    # Add data
    nbreaks = max(min(round(length(Z[,valuecol])/2), 5), 1)

    # No point in drawing a choropleth with one zip code
    if (nrow(Z) < 2) {
      return(NULL)
    }

    # Assigns the value we are using for the illustration.
    Z$value = cut_number(Z[,valuecol], n=nbreaks, labels=c(1:nbreaks))

    # Simply attempting a merge with an SPDF results in the data and polygons
    # going out of order. Very infuriating. spdfMerge will properly do the required
    # merge and keep order.
    Z$ZCTA5CE10 = Z$zip
    visitorzips.spdf = spdfMerge(visitorzips.spdf, Z, by="ZCTA5CE10")
  
    # Just local zips. This throws out far away zip codes
    if (nrow(Z) > 5) {
      visitorzips.spdf=filterLocalZipSPDF(visitorzips.spdf)
    }
  
    # Thinning the polygons help them to draw faster
    visiorzips.spdf = thinnedSpatialPoly(visitorzips.spdf, tolerance=0.01, topologyPreserve = TRUE)

    # Get a fortified data frame of those zips
    choro.df = suppressMessages(fortifyMerge(visitorzips.spdf))

    # Get base map
    bbox = c(left=min(choro.df$long), bottom=min(choro.df$lat),
            right=max(choro.df$long), top=max(choro.df$lat))
    zoom = calc_zoom(bbox)-1
    basemap = getBaseMap(mean(bbox[c("left", "right")]), mean(bbox[c("top", "bottom")]), zoom)

    # This actually draws the map and adds the point
    plot = choroplethsp(choro.df, "value", map=basemap) +
      geom_point(x=long, y=lat, color="blue", size=6)
  
    # Plot
    return(plot)
  } else {
    return(NULL)
  }
}

