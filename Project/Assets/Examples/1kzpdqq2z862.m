{hold[Plot[Evaluate[Table[BesselJ[n, x], {n, 3}]], {x, 0, 10}, 
   Filling -> Axis, FillingStyle -> Automatic]], 
 hold[ListPlot[Table[{k, PDF[BinomialDistribution[50, p], k]}, 
    {p, {0.3, 0.5, 0.8}}, {k, 0, 50}], Filling -> Axis, 
   FillingStyle -> Automatic]]}
