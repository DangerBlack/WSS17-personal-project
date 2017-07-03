{hold[Shallow[WikipediaData["Bill Gates", "LinksList"]]], 
 hold[Shallow[WikipediaData["Bill Gates", "BacklinksList"]]], 
 hold[links = WikipediaData["Graph theory", "BacklinksRules", 
     "MaxLevelItems" -> 20, "MaxLevel" -> 2]; ], 
 hold[Graph[links, VertexLabels -> Placed["Name", Tooltip], 
   VertexStyle -> {"Graph theory" -> Red}]]}
