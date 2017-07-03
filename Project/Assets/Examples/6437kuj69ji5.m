{hold[v = {{0, 0, 0}, {2, 0, 0}, {2, 2, 0}, {0, 2, 0}, {1, 1, 2}}; ], 
 hold[i = {{1, 2, 5}, {2, 3, 5}, {3, 4, 5}, {4, 1, 5}}; ], 
 hold[{Graphics3D[{Opacity[0.8], Yellow, GraphicsComplex[v, Polygon[i]]}], 
   Graphics3D[{Thick, GraphicsComplex[v, Line[i]]}]}]}
