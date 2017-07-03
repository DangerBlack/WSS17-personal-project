{hold[GeoGraphics[GeoRange -> "World", GeoProjection -> "Robinson"]], 
 hold[With[{locations = {GeoPosition[{-35, -55}], GeoPosition[{70, 100}]}}, 
   GeoGraphics[{{Blue, GeoPath[locations, "Geodesic"]}}, GeoRange -> "World", 
    GeoProjection -> "Robinson"]]]}
