{hold[Plot3D[Sin[x*y], {x, 0, 3}, {y, 0, 3}, ColorFunction -> "Rainbow", 
   Mesh -> None]], hold[ParametricPlot3D[{(3 + Cos[v])*Cos[u], 
    (3 + Cos[v])*Sin[u], Sin[v]}, {u, 0, 2*Pi}, {v, 0, 2*Pi}, Mesh -> None]]}
