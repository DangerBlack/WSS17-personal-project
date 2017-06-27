Package["Project`"]

(* ::Input::Initialization:: *)
(**Function for extracting RowBox from documentation**)
(**extractFunctionFromRowBox[box_RowBox]:=ToExpression[Catch @ ReplaceAll[box,f_RowBox:>Throw[f]],StandardForm,hold]**)
extractFunctionFromRowBox[box_] := Map[ToExpression[Cases[#,_BoxData,Infinity],StandardForm,hold]&,box]

(**Find function example in documentation as RowBox**)
(*findFunctionsExampleInDoc[functionName_]:=Flatten[Lookup[WolframLanguageData[functionName,"DocumentationExampleInputs"],"BasicExamples"]]*)
findFunctionsExampleInDoc[functionName_]:=Lookup[WolframLanguageData[functionName,"DocumentationExampleInputs"],"BasicExamples"]

(**Pick a random sample from documentation about functionName**)
extractRandomFunction[functionName_]:=extractFunctionFromRowBox[RandomChoice[findFunctionsExampleInDoc[functionName]]]
extractNFunction[functionName_,n_]/; 0<n&&n<=Length[findFunctionsExampleInDoc[functionName]]:=extractFunctionFromRowBox[findFunctionsExampleInDoc[functionName][[n]]]

SetAttributes[extractAllExampleInDoc,{HoldAllComplete,Listable}]
extractAllExampleInDoc[functionName_String] := Map[extractFunctionFromRowBox,findFunctionsExampleInDoc[functionName]]
extractAllExampleInDoc[functionName_Symbol] := extractAllExampleInDoc @@ {SymbolName[Unevaluated[functionName]]}
PackageExport[extractAllExampleInDoc]

(**Substitute part of the function with ?**)
(**SetAttributes[tweakFunction,HoldFirst]**)
tweakFunction[Hold[expr_]]:=With[
									{l=RandomInteger[{0,Length[Unevaluated[expr]]}]},
									ReplacePart[
										HoldForm[expr],{1,l}->Placeholder["?"]
									]
								]
(**Better use this one the other is not fair!**)
tweakFunction[Hold[expr_],n_]/; 0<= n<= Length[Unevaluated[expr]]:=
								ReplacePart[HoldForm[expr],{1,n}->Placeholder["?"]]

(**this is very unsafe to use but wonderful**)
tweakFunction[Hold[expr_],n_List]:=With[
										{s=n/.List->Sequence},
										ReplacePart[HoldForm[expr],{1,s}->Placeholder["?"]]
									]

PackageExport[tweakFunction]


(**This function sobstitute all the keyword in pattern_ as Placeholder.**)
SetAttributes[removeExpressionPart,HoldAllComplete]
(**pattern=_Symbol?SymbolQ**)
removeExpressionPart[expr_]:=With[
	{pattern=_Image|_Graph|_Graphics|_Graphics3D|_Random|_RandomWord},
	expr/.pattern->Placeholder[]
]

(**
 This function find the position of all the expressione that can be removed from a function
 making it harder to guess but still meaningful.
It avoid selecting path to Placeholder, Hold, Rule,RuleDelayed, List, etc..
**)
SetAttributes[positionsOfRemovablePart,HoldAllComplete]
(**avoidedEspression = Placeholder|_Placeholder|_Hold|_Rule|_RuleDelayed|_List|_List|_Random|_RandomInteger**)
SetAttributes[symbolQ,HoldAllComplete]

(**
Tooltip: Use _Placeholder for The Whole element, use Placeholder for only the head of expression
 example:
 List[1,2,4] \[Rule]  \[Placeholder][1,2,3]  avoid this happen with List
List[1,2,4] \[Rule]  List[\[Placeholder],2,3]  avoid this happen in the other removeExpressionPart
**)
symbolQ[Placeholder|Hold|Rule|RuleDelayed|List|Random|RandomInteger|hold]:=False
symbolQ[_]:=True

positionsOfRemovablePart[exrp_]:=With[
	{pos=Position[exrp,symbolQ|_Symbol?symbolQ]},(**_Integer|_Real|**)
	Map[Extract[exrp,#,Function[i,If[Length[Rest[#]]==0,{0},Rest[#]]:>i,HoldFirst]]&,pos][[1;;-1]](**TODO: fix Random[]**)
]

Clear[listRemovablePartFromEspression]
SetAttributes[listRemovablePartFromEspression,HoldAllComplete]
listRemovablePartFromEspression[espr_]:=positionsOfRemovablePart[removeExpressionPart[espr]]

PackageExport[listRemovablePartFromEspression]

(** Select one of the possible sobstitution from a random function of documentation**)
selectQuizFromCategorySafeExample[category_, categorySafeExample_] :=

  With[
  	{ acsfNoS = Map[First[#] -> Keys[Last[#]] &, categorySafeExample] },
  With[
   	{ problem = RandomChoice[acsfNoS[[category, 2]]] },
   	With[
    		  {head = First[First[problem]], 
     tail = {Rest[First[problem]], Rest[problem]}},
    		   {
     			problem,
     			Flatten[{{tweakFunction[Hold @@ Echo@head, 
         First[RandomChoice[
           listRemovablePartFromEspression[Unevaluated @@ head]]]]}, 
       tail}, 2],
     			Apply[Identity, problem, {2}]
     		}
    	      ]
         ]
  ]

PackageExport[selectQuizFromCategorySafeExample]