{hold[nb = CreateDocument[TextCell["abcd abcd abcd", "Text", FontSize -> 14], 
     FontSize -> 20]; ], hold[SelectionMove[nb, Next, Cell]], 
 hold[SetOptions[NotebookSelection[nb], FontSize -> Inherited]], 
 hold[Options[NotebookSelection[nb]]]}
