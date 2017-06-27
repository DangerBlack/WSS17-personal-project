Package["Project`"]

(**PackageExport[Pippo]**)
SetAttributes[hold, {HoldAll, SequenceHold, Flat}]

PackageExport[hold]

$whitelist := $whitelist=Get[FileNameJoin[{PacletManager`PacletResource["Project", "Assets"], "category.m"}]]
$wholewhitelist := $wholewhitelist=DeleteDuplicates[Flatten[Map[Values, $whitelist]]]

loadAllExample[wholewhitelist_] := Flatten[Map[extractAllExampleInDoc, wholewhitelist]]
loadAllSymbolExample[wholewhitelist_]:=Map[# -> DeleteDuplicates@extractAllSymbols[#] &, loadAllExample[wholewhitelist]];
loadAllFilteredSymbolExample[wholewhitelist_]:= Select[loadAllSymbolExample[wholewhitelist], SubsetQ[wholewhitelist, Last[#]] &];

filterUnsafeExpression[l_,safeExprList_] := Select[safeExprList, SubsetQ[l, Last[#]] &]

loadAllCategorySafeExample[whitelist_,wholewhitelist_]:=
	With[
			{
				safeExprList=loadAllFilteredSymbolExample[wholewhitelist]
			},
			Map[First[#] -> filterUnsafeExpression[Last[#],safeExprList] &, whitelist]
		]

PackageExport[$whitelist]
PackageExport[$wholewhitelist]
PackageExport[loadAllFilteredSymbolExample]
PackageExport[loadAllCategorySafeExample]

(**extractAllSymbols[f_] := 
 hold @@ Cases[Unevaluated[f], 
   s_Symbol /; Context[s] == "System`" :> hold[s], Infinity, 
   Heads -> True]**)

 extractAllSymbols[f_] := 
 Cases[Unevaluated[f], 
   s_Symbol /; Context[s] == "System`" :> SymbolName[Unevaluated[s]], Infinity, 
   Heads -> True]

PackageExport[extractAllSymbols]