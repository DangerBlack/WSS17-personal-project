{hold[{a, b, c, d, e, f, g} /. {x__, Shortest[y__]} -> {{x}, {y}}], 
 hold[{a, b, c, d, e, f, g} /. {Shortest[x__], y__} -> {{x}, {y}}]}
