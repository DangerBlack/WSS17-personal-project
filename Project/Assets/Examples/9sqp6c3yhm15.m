{hold[Plot3D[Sin[x + y^2], {x, -2, 2}, {y, -2, 2}, 
   RegionFunction -> (1 < #1^2 + #2^2 < 4 & ), Filling -> Bottom, 
   FillingStyle -> Opacity[0.7], Mesh -> None]]}
