{hold[TakeLargestBy[{"", "xxx", "xx"}, StringLength, 2]], 
 hold[TakeLargestBy[StringLength, 2][{"", "xxx", "xx"}]], 
 hold[TakeLargestBy[Association[a -> "", b -> "xxx", c -> "xx"], 
   StringLength, 2]]}
