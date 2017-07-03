{hold[g[{{xmin_, xmax_}, {ymin_, ymax_}}, ___] := 
   Polygon[{{xmin, ymin}, {xmax, ymax}, {xmin, ymax}, {xmax, ymin}}]], 
 hold[BarChart[{1, 2, 3, 4, 5}, ChartElementFunction -> g]]}
