Package["Project`"]

(**PackageExport[Pippo]**)
SetAttributes[hold, {HoldAll, SequenceHold, Flat}]

PackageExport[hold]

$whitelist := $whitelist=Get[FileNameJoin[{PacletManager`PacletResource["Project", "Assets"], "category.m"}]]

PackageExport[$whitelist]

extractAllSymbols[f_] := 
 hold @@ Cases[Unevaluated[f], 
   s_Symbol /; Context[s] == "System`" :> hold[s], Infinity, 
   Heads -> True]

PackageExport[extractAllSymbols]