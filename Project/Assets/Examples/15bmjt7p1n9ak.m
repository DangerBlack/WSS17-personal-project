{hold[p = Table[{t, Sin[t]}, {t, 0, 2*Pi, 2*(Pi/10)}]; ], 
 hold[{Graphics[{PointSize[Small], Point[p]}], 
   Graphics[{PointSize[Small], Pink, Point[p]}], 
   Graphics[{PointSize[Large], Point[p]}], 
   Graphics[{PointSize[Large], Pink, Point[p]}]}]}
