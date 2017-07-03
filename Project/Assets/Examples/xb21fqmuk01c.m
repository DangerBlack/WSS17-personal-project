{hold[Plot[Evaluate[Table[PDF[WeibullDistribution[\[Alpha], 2], x], 
     {\[Alpha], {0.5, 2, 4}}]], {x, 0, 5}, Filling -> Axis]], 
 hold[Plot[Evaluate[Table[PDF[WeibullDistribution[2, \[Beta]], x], 
     {\[Beta], {1, 2, 4}}]], {x, 0, 5}, Filling -> Axis]], 
 hold[PDF[WeibullDistribution[\[Alpha], \[Beta]], x]], 
 hold[Plot[Evaluate[Table[PDF[WeibullDistribution[3, 2, \[Mu]], x], 
     {\[Mu], {-1.5, 1, 2}}]], {x, 0, 6}, Filling -> Axis]], 
 hold[PDF[WeibullDistribution[\[Alpha], \[Beta], \[Mu]], x]]}
