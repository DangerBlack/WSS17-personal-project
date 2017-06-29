Package["Project`"]

(**PackageExport[Pippo]**)
SetAttributes[hold, {HoldAll, SequenceHold, Flat}]

PackageExport[hold]
PackageExport[$wholewhitelist]
PackageExport[$DataBase]

$whitelist      := $whitelist      = Get[FileNameJoin[{PacletManager`PacletResource["Project", "Assets"], "category.m"}]]
$wholewhitelist := $wholewhitelist = DeleteDuplicates[Join @@  $whitelist]

$DataBase := $DataBase = With[
	{$exampleSymbol = loadAllFilteredSymbolExample[$wholewhitelist]},
	<|
		"Examples"-> <|Map[customHash[#] -> # &, Keys[$exampleSymbol]]|>,
		"Categories" -> loadCategories[$whitelist, $exampleSymbol],
		"CategoriesNames" -> getCategoriesName[$whitelist]
	|>

]

extractAllSymbols[f_] := 
	Cases[
		Unevaluated[f], 
   		s_Symbol /; Context[s] == "System`" :> SymbolName[Unevaluated[s]], 
   		Infinity, 
		Heads -> True
	]

(*Load all example from function in wholewhitelist in documentation*)
loadAllExample[wholewhitelist_] := Flatten[Map[extractAllExampleInDoc, wholewhitelist],1]
(*load all symbol from al the function that can be found in documentation from wholewhitelist*)
loadAllSymbolExample[wholewhitelist_]:=Map[# -> DeleteDuplicates@extractAllSymbols[#] &, loadAllExample[wholewhitelist]];
(*filter all example found with the previus function only example that are made by function in wholewhilelist*)
loadAllFilteredSymbolExample[wholewhitelist_]:= Select[loadAllSymbolExample[wholewhitelist], SubsetQ[wholewhitelist, Last[#]]&&Length[Last[#]]>1 &];

filterUnsafeExpression[l_,safeExprList_] := Select[safeExprList, SubsetQ[l, Last[#]] &]



getCategoriesName[whitelist_]:=
	Association @ KeyValueMap[buildKey[#1] -> #1 &, whitelist]

loadCategories[whitelist_, examples_]:=
	Association @ KeyValueMap[
		Function[
			{cat, symbols},
			buildKey[cat] -> Map[
				customHash[First[#]]&,
				filterUnsafeExpression[
					symbols, 
					examples
				]
			]
		],
		whitelist
	]
