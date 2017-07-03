{hold[Table[PieChart[{1, 2, 3}, ChartLabels -> Placed[{"a", "b", "c"}, p], 
    SectorOrigin -> {Automatic, 1}, PlotLabel -> p], 
   {p, {"RadialInner", "RadialCenter", "RadialOuter"}}]], 
 hold[Table[PieChart[{1, 2, 3}, ChartLabels -> Placed[{"a", "b", "c"}, p], 
    SectorOrigin -> {Automatic, 1}, PlotLabel -> p], 
   {p, {"RadialInside", "RadialEdge", "RadialOutside"}}]], 
 hold[PieChart[Range[10], ChartLabels -> Placed[Range[10], "RadialCallout"], 
   SectorOrigin -> {Automatic, 1}]]}
