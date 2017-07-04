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
calculateWeight[categorySymbol_, expr_] := 
 Total[Map[Length[#]&, 
   			Position[expr,
   					 Alternatives @@Map[ToExpression[#, InputForm, HoldPattern] &, categorySymbol],
   					 Infinity, 
    				Heads -> True]
    				]]/(1+Length[extractAllSymbols[exp]])

pickCategoryFromSymbol[expr_,whitelist_] :=
 		With[
 			{wl = KeyValueMap[
     			#1 -> calculateWeight[#2, expr] &,
     			whitelist
     		]},
  			Last@Keys@Sort@wl
  			]

loadCategories[whitelist_, exampleSymbol_] :=
 Association@
		   With[{esLabeled = 
		      Map[First[#] -> pickCategoryFromSymbol[First[#],whitelist] &, 
		       exampleSymbol]},
		      GroupBy[esLabeled, Last->First,Map[customHash]]
	   		]


saveExample[key_,example_]:=
	Put[example,FileNameJoin[{$ApplicationExampleFolder, StringJoin[key,".m"]}]];
getExample[key_]:=
	{
		Get[FileNameJoin[{$ApplicationExampleFolder, StringJoin[key,".m"]}]]
	};


$aree := $aree = <|
  "MathFunctions" -> "BasicSymbols",
  "AssociationSymbols" -> "BasicSymbols" ,
  "ArraySymbols" -> "BasicSymbols",
  "StructuralSymbols" -> "BasicSymbols",
  "CalculusSymbols" -> "BasicSymbols",
  "StatisticsSymbols" -> "GraphTheorySymbols",
  "SeriesSymbols" -> "BasicSymbols",
  "FormattingSymbols" -> "StringSymbols",
  "QuantitySymbols" -> "EntitySymbols",
  "FrontEndSymbols" -> "StringSymbols",
  "LogicSymbols" -> "BasicSymbols",
  "ExpressionSizeSymbols" -> "ExtractionSymbols",
  "ColorSymbols" -> "ImageSymbols",
  "VectorCalculusSymbols" -> "RegionSymbols",
  "MatrixSymbols" -> "BasicSymbols",
  "MessagesAndPrintingSymbols" -> "EntitySymbols",
  "CellSymbols" -> "FormSymbols",
  "ControlObjectSymbols" -> "PlottingSymbols",
  "GraphicsSymbols" -> "ImageSymbols",
  "NamedGraphSymbols" -> "GraphTheorySymbols",
  "SoundSymbols" -> "EntitySymbols",
  "GeodesySymbols" -> "GeoGraphicsSymbols",
  "AstronomySymbols" -> "GeoGraphicsSymbols",
  "MachineLearningSymbols" -> "ClusteringSymbols",
  "HistogramSymbols" -> "ChartSymbols",
  "TemplateSymbols" -> "StyleSymbols"|>;

getCategoryMagic[newCatByFun_,exampleSymbol_]:=
	KeyValueMap[#1 -> 
	    Lookup[$aree, newCatByFun[First[#2]], newCatByFun[First[#2]]] &, 
	  Association@exampleSymbol];

$DataBase := $DataBase = getSettings["dataset.m",
	With[
		{
			$exampleSymbol = loadAllFilteredSymbolExample[$wholewhitelist],
			newCatByFun = 
			  First /@ DeleteMissing[
			    AssociationMap[
			     WolframLanguageData[#, 
			       "FunctionalityAreas"] &, $wholewhitelist]]
		},
		With[
		{
			precategory=getCategoryMagic[newCatByFun,$exampleSymbol]
		},
		With[
			{
				category=Select[GroupBy[precategory, Last -> First, Map[customHash]], Length[#] > 17 &]
			},
			Map[saveExample[customHash[#], #]&, Keys[$exampleSymbol]];
			<|
				"Examples":> getExample,
				"Categories" -> category,
				"CategoriesNames" -> Association@Map[# -> StringDelete[#, "Symbols"] &, Keys@category],
				"ExamplesNSymbols"-> <|Map[customHash[First[#]] -> Length[Last[#]] &, $exampleSymbol]|>
			|>
		]
		]
	]
]