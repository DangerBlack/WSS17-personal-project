{hold[trainingset = {1 -> "A", 2 -> "A", 3.5 -> "B", 4 -> "B"}; ], 
 hold[c = Classify[trainingset]], hold[c[2.6]], 
 hold[c[2.6, "Probabilities"]], hold[c[{2.6, 5.1, -7.2}]], 
 hold[Plot[c[x, "Probability" -> "A"], {x, 0, 5}, Exclusions -> None]], 
 hold[Classify[trainingset, 2.6]], 
 hold[Classify[trainingset, 2.6, "Probabilities"]]}
