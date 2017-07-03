Package["Project`"]

(**PackageExport[Pippo]**)

PackageExport[$DataBase]
PackageExport[extractAllSymbols]

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
	With[{exp = removeExpressionPart[f]},
		Quiet[
			DeleteDuplicates @ Cases[
				Unevaluated[exp], 
		   		s_Symbol /; Context[s] == "System`" :> SymbolName[Unevaluated[s]], 
		   		Infinity, 
				Heads -> True
			],
			General::ssle
		]
	]

(*Load all example from function in wholewhitelist in documentation*)
loadAllExample[wholewhitelist_] := Flatten@Map[extractFunctionFromRowBox, 
 										Lookup[
 												WolframLanguageData[$wholewhitelist, "DocumentationExampleInputs"] 
 													/. _Missing -> {"BasicExamples" -> {}}, 
 												"BasicExamples"
 												]
 										]
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


(*loadCategories[whitelist_, examples_]:=
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
	]*)
weight[l_] := 
 Association @@ Map[# -> Count[l, #]/Length[l] &, DeleteDuplicates@l]
calculateWeight[categorySymbol_, symbols_] := 
 N[Times @@ Map[Lookup[categorySymbol, #, 10^-6] &, symbols]]
pickCategoryFromSymbol[symbols_] :=
 		With[{wl = Map[
     			calculateWeight[#, symbols] &,
     			KeyValueMap[#1 -> weight[#2] &, $whitelist][[All, 2]]
     		]},
  			First@Flatten@Position[wl, Max[wl]]
  			]
loadCategories[whitelist_, exampleSymbol_] :=
 Association@With[{
			    	catsid = Map[buildKey, Keys@whitelist]
				    },
				   With[{esLabeled = 
				      Map[First[#] -> catsid[[pickCategoryFromSymbol[Last[#]]]] &, 
				       exampleSymbol]},
				      GroupBy[esLabeled, Last->First,Map[customHash]]
			   		]
				]


saveExample[key_,example_]:=
	Put[example,FileNameJoin[{$ApplicationExampleFolder, StringJoin[key,".m"]}]];
getExample[key_]:=
	{
		Get[FileNameJoin[{$ApplicationExampleFolder, StringJoin[key,".m"]}]]
	};

$DataBase := $DataBase = getSettings["dataset.m",
	With[
		{$exampleSymbol = loadAllFilteredSymbolExample[$wholewhitelist]},
		Map[saveExample[customHash[#], #]&, Keys[$exampleSymbol]];
		<|
			"Examples":> getExample,
			"Categories" -> loadCategories[$whitelist, $exampleSymbol],
			"CategoriesNames" -> getCategoriesName[$whitelist],
			"ExamplesNSymbols"-> <|Map[customHash[First[#]] -> Length[Last[#]] &, $exampleSymbol]|>
		|>
	]
]