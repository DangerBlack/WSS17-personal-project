{hold[g = Graph[{1, 2, 3, 4, 5, 6}, {Null, {{1, 2}, {1, 3}, {1, 4}, {1, 5}, 
       {1, 6}, {2, 3}, {2, 6}, {3, 4}, {4, 5}, {5, 6}}}, 
     {GridLinesStyle -> Directive[GrayLevel[0.5, 0.4]], ImagePadding -> 0, 
      ImageSize -> {124.5, Automatic}, GraphHighlightStyle -> {"Thick"}, 
      GraphLayout -> "StarEmbedding", ImagePadding -> 0, 
      ImageSize -> {124.5, Automatic}, VertexShapeFunction -> 
       {{White, Disk[#1, 0.1], Black, Text[#2, #1]} & }}]; ], 
 hold[FindShortestPath[g, 3, 5]], hold[HighlightGraph[g, PathGraph[%]]]}
