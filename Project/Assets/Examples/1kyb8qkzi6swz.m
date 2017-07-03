{hold[Plot[Evaluate[Table[BesselJ[n, x], {n, 4}]], {x, 0, 10}, 
   Filling -> Axis]], hold[GraphPlot[Table[i -> Mod[i^2, 102], 
    {i, 0, 102}]]], hold[ReliefPlot[Table[i + Sin[i^2 + j^2], 
    {i, -4, 4, 0.03}, {j, -4, 4, 0.03}], ColorFunction -> "SunsetColors"]]}
