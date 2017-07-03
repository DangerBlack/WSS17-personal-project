{hold[ef[pts_List, e_] := 
   Block[{s = 0.015, g = Graphics[Circle[{0, 0}], 
       ImageSize -> {24., Automatic}]}, 
    {Arrowheads[{{s, 0.33, g}, {s, 0.67, g}}], Arrow[pts]}]], 
 hold[Graph[{UndirectedEdge[1, 2], UndirectedEdge[2, 3], 
    UndirectedEdge[3, 1]}, EdgeShapeFunction -> ef]]}
