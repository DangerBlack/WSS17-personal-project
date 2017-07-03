{hold[data1 = RandomVariate[NormalDistribution[0, 1], 500]; , Null, 
  data2 = RandomVariate[NormalDistribution[3, 1/2], 500]; ], 
 hold[Histogram[{data1, data2}]]}
