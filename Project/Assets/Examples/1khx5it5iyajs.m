{hold[Plot3D[x^2 - y^2, {x, -3, 3}, {y, -3, 3}, 
   RegionFunction -> Function[{x, y, z}, 2 < x^2 + y^2 < 9]]], 
 hold[ContourPlot[x^2 - y^2, {x, -3, 3}, {y, -3, 3}, 
   RegionFunction -> Function[{x, y, z}, 2 < x^2 + y^2 < 9]]]}
