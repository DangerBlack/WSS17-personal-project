{hold[Plot[Evaluate[Table[PDF[NormalDistribution[0, \[Sigma]], x], 
     {\[Sigma], {0.75, 1, 2}}]], {x, -6, 6}, Filling -> Axis]], 
 hold[Plot[Evaluate[Table[PDF[NormalDistribution[\[Mu], 1.5], x], 
     {\[Mu], {-1, 1, 2}}]], {x, -6, 6}, Filling -> Axis]], 
 hold[PDF[NormalDistribution[\[Mu], \[Sigma]], x]]}
