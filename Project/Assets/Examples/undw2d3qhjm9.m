{hold[f[x_] := If[x > 10, Throw[overflow], x!]], hold[Catch[f[2] + f[11]]], 
 hold[Catch[f[2] + f[3]]]}
