(* ::Package:: *)

(* ::Input::Initialization:: *)
(**Function for extracting RowBox from documentation**)
Clear[extractFunctionFromRowBox]
extractFunctionFromRowBox[box_]:=ToExpression[Catch @ ReplaceAll[box,f_RowBox:>Throw[f]],StandardForm,Hold]
	
(**Find function example in documentation as RowBox**)
Clear[findFunctionsExampleInDoc]
findFunctionsExampleInDoc[functionName_]:=Flatten[Lookup[WolframLanguageData[functionName,"DocumentationExampleInputs"],"BasicExamples"]]

(**Pick a random sample from documentation about functionName**)
Clear[extractRandomFunction]
Clear[extractNFunction]
extractRandomFunction[functionName_]:=extractFunctionFromRowBox[RandomChoice[findFunctionsExampleInDoc[functionName]]]
extractNFunction[functionName_,n_]/; 0<n&&n<=Length[findFunctionsExampleInDoc[functionName]]:=extractFunctionFromRowBox[findFunctionsExampleInDoc[functionName][[n]]]

(**Substitute part of the function with ?**)
Clear[tweakFunction]
(**SetAttributes[tweakFunction,HoldFirst]**)
ClearAttributes[tweakFunction,HoldFirst]
tweakFunction[Hold[expr_]]:=With[
{l=RandomInteger[{0,Length[Unevaluated[expr]]}]},
ReplacePart[HoldForm[expr],{1,l}->Placeholder["?"]]]
(**Better use this one the other is not fair!**)
tweakFunction[Hold[expr_],n_]/; 0<= n<= Length[Unevaluated[expr]]:=ReplacePart[HoldForm[expr],{1,n}->Placeholder["?"]]
(**this is very unsafe to use but wonderful**)
tweakFunction[Hold[expr_],n_List]:=With[
{s=n/.List->Sequence},
ReplacePart[HoldForm[expr],{1,s}->Placeholder["?"]]]

(**This function sobstitute all the keyword in pattern_ as Placeholder.**)
Clear[removeExpressionPart]
SetAttributes[removeExpressionPart,HoldAllComplete]
(**pattern=_Symbol?SymbolQ**)
removeExpressionPart[expr_]:=With[
{pattern=_Image|_Graph|_Graphics|_Graphics3D|_Random|_RandomWord},
expr/.pattern->Placeholder[]]

(**
 This function find the position of all the expressione that can be removed from a function 
 making it harder to guess but still meaningful.
It avoid selecting path to Placeholder, Hold, Rule,RuleDelayed, List, etc..
**)
Clear[positionsOfRemovablePart]
Clear[symbolQ]
SetAttributes[positionsOfRemovablePart,HoldAllComplete]
(**avoidedEspression = Placeholder|_Placeholder|_Hold|_Rule|_RuleDelayed|_List|_List|_Random|_RandomInteger**)
SetAttributes[symbolQ,HoldAllComplete]

(**
Tooltip: Use _Placeholder for The Whole element, use Placeholder for only the head of expression
 example: 
 List[1,2,4] \[Rule]  \[Placeholder][1,2,3]  avoid this happen with List
List[1,2,4] \[Rule]  List[\[Placeholder],2,3]  avoid this happen in the other removeExpressionPart 
**)
symbolQ[Placeholder|Hold|Rule|RuleDelayed|List|Random|RandomInteger]:=False
symbolQ[_]:=True

positionsOfRemovablePart[exrp_]:=With[
{pos=Position[exrp,_Integer|_Real|symbolQ|_Symbol?symbolQ]},
Map[Extract[exrp,#,Function[i,If[Length[Rest[#]]==0,{0},Rest[#]]:>i,HoldFirst]]&,pos][[1;;-1]](**TODO: fix Random[]**)
]

Clear[listRemovablePartFromEspression]
SetAttributes[listRemovablePartFromEspression,HoldAllComplete]
listRemovablePartFromEspression[espr_]:=positionsOfRemovablePart[removeExpressionPart[espr]]

(** Select one of the possible sobstitution from a random function of documentation**)
Clear[selectQuizFromDocumentation]
selectQuizFromDocumentation[functionName_]:=With[
{espr= extractRandomFunction[functionName]},
{
tweakFunction[espr,First[RandomChoice[listRemovablePartFromEspression[espr]]]],
espr,
ReleaseHold[espr]
}
]
selectQuizFromDocumentation[functionName_,n_]:=With[
{espr= extractNFunction[functionName,n]},
{
tweakFunction[espr,First[RandomChoice[listRemovablePartFromEspression[espr]]]],
espr,
ReleaseHold[espr]
}
]