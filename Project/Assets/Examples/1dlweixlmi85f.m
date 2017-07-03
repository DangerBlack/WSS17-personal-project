{hold[ListPlot[Table[{k, PDF[BinomialDistribution[50, p], k]}, 
    {p, {0.3, 0.5, 0.8}}, {k, 0, 50}], Filling -> Axis]]}
