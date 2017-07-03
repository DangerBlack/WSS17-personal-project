{hold[vf[{xc_, yc_}, name_, {w_, h_}] := 
    Block[{xmin = xc - w, xmax = xc + w, ymin = yc - h, ymax = yc + h}, 
     Polygon[{{xmin, ymin}, {xmax, ymax}, {xmin, ymax}, {xmax, ymin}}]]; ], 
 hold[CompleteGraph[4, VertexShapeFunction -> vf, VertexSize -> 0.2]]}
