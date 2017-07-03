{hold[Nearest[{"aaaa", "abaa", "bbbb", "aaaba"}, "aaba", 3]], 
 hold[(EditDistance[#1, "aaba"] & ) /@ {"aaaa", "abaa", "bbbb", "aaaba"}]}
