Package["Project`"]

(**PackageExport[Pippo]**)

PackageExport[$wholewhitelist]
PackageExport[$DataBase]
PackageExport[extractAllSymbols]


$whitelist      := $whitelist      = Get[FileNameJoin[{PacletManager`PacletResource["Project", "Assets"], "category.m"}]]
$wholewhitelist := $wholewhitelist = DeleteDuplicates[Join @@  $whitelist]


(*

$DataBase := $DataBase = With[
	{$exampleSymbol = loadAllFilteredSymbolExample[$wholewhitelist]},
	<|
		"Examples"-> <|Map[customHash[#] -> # &, Keys[$exampleSymbol]]|>,
		"Categories" -> loadCategories[$whitelist, $exampleSymbol],
		"CategoriesNames" -> getCategoriesName[$whitelist],
		"ExamplesNSymbols"-> <|Map[customHash[First[#]] -> Length[Last[#]] &, $exampleSymbol]|>
	|>

]*)

extractAllSymbols[f_] := 
	With[{exp=removeExpressionPart[f]},
		DeleteDuplicates@Cases[
			Unevaluated[exp], 
	   		s_Symbol /; Context[s] == "System`" :> SymbolName[Unevaluated[s]], 
	   		Infinity, 
			Heads -> True
		]
	]

(*Load all example from function in wholewhitelist in documentation*)
loadAllExample[wholewhitelist_] := Flatten[Map[extractAllExampleInDoc, wholewhitelist],1]
(*load all symbol from al the function that can be found in documentation from wholewhitelist*)
loadAllSymbolExample[wholewhitelist_]:=Map[# -> DeleteDuplicates@extractAllSymbols[#] &, loadAllExample[wholewhitelist]];
(*filter all example found with the previus function only example that are made by function in wholewhilelist*)
loadAllFilteredSymbolExample[wholewhitelist_]:= Select[
														loadAllSymbolExample[wholewhitelist],
														SubsetQ[wholewhitelist, Last[#]]&&Length[Last[#]]>=1 &
													];

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


saveExample[key_,example_]:=
	Put[example,FileNameJoin[{$ApplicationExampleFolder, StringJoin[key,".m"]}]];
getExample[key_]:=
	Get[FileNameJoin[{$ApplicationExampleFolder, StringJoin[key,".m"]}]];

$DataBase := $DataBase = getSettings["dataset.m",
	With[
		{$exampleSymbol = loadAllFilteredSymbolExample[$wholewhitelist]},
		(
			Map[saveExample[customHash[#], #]&, Keys[$exampleSymbol]];
			<|
				"Examples":> getExample,
				"Categories" -> loadCategories[$whitelist, $exampleSymbol],
				"CategoriesNames" -> getCategoriesName[$whitelist],
				"ExamplesNSymbols"-> <|Map[customHash[First[#]] -> Length[Last[#]] &, $exampleSymbol]|>
			|>
		)
	]
]