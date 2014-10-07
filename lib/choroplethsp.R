# ggplot(counties.df, aes(x=long, y=lat)) +
#   geom_polygon(aes(x=long, y=lat, group=group, fill=valuei), color="black") +
#   scale_fill_brewer(type="seq", palette = "OrRd", guide=FALSE) +
#   coord_fixed()

choroplethsp = function(data, valuecol, map=NULL) {
  if (is.null(map)) {
    p = ggplot() +
      geom_polygon(data=data, aes_string(x="long", y="lat", group="group", fill=valuecol), color="black")
  } else {
    p = map +
      geom_polygon(data=data, aes_string(x="long", y="lat", group="group", fill=valuecol), color="black", alpha=0.3)
  }
  p +
#     scale_fill_brewer(type="seq", palette = "OrRd", guide=FALSE) +
    scale_fill_manual(values = brewer.pal(5,"OrRd"), guide=FALSE) +
    coord_fixed()
}

# map = get_map(location=as.vector(bbox(hexbins.sp)), crop=TRUE, maptype="roadmap")
# print(choroplethsp(hexbins.df, "valuei", map))
# print(choroplethsp(hexbins.df, "valuei"))
