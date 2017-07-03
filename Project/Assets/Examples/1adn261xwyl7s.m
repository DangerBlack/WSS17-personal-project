{hold[data1 = RandomReal[{0, 1}, 25]; , Null, 
  data2 = RandomReal[{1, 2}, 25]; ], 
 hold[ListLinePlot[{data1, data2, Legended[Mean[{data1, data2}], "mean"]}]]}
