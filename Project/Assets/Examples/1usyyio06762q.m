{hold[v = PolyhedronData["Dodecahedron", "Vertices"]; ], 
 hold[Short[i = PolyhedronData["Dodecahedron", "Faces"]]], 
 hold[Graphics3D /@ {{Yellow, GraphicsComplex[v, Polygon[i]]}, 
    {Thick, GraphicsComplex[v, Line[i]]}}], 
 hold[Graphics3D /@ {{Yellow, PolyhedronData["Dodecahedron", 
      "GraphicsComplex"]}, {Thick, PolyhedronData["Dodecahedron", "Edges", 
      "GraphicsComplex"]}}]}
