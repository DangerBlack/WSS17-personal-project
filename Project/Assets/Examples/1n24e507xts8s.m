{hold[Timing[Module[{x = 1/Pi}, Do[x = 3.5*x*(1 - x), {10^6}]; x]]], 
 hold[Timing[Nest[3.5*#1*(1 - #1) & , 1./Pi, 10^6]]]}
