Package["Project`"]

(* this is declaring that a certain simbol can be used IN the paclet *)
PackageScope[$SomeSymbol]

Unprotect[$TemplatePath]
$TemplatePath = Prepend[$TemplatePath,PacletManager`PacletResource["Project", "Assets"]]


buildKey[text_]:= StringReplace[ToLowerCase[text]," "->"-"]
customHash[expr_, rest___] := 	
	IntegerString[Hash[{expr, "d15f2334-4dab-4618-875b-e1d3632e3276"}, rest], 36]

(*)
getKeysToNameCategory[whitelist_] := With[
							{keys = Keys[whitelist]},
							Association @ Table[buildKey[keys[[i]]] -> keys[[i]], {i, 1, Length[keys]}]
						]

getKeysToExerciseCategory[whitelist_] := With[
							{keys = Keys[whitelist]},
							Association @ Table[buildKey[keys[[i]]] -> Left[$whitelist[[i]]], {i, 1, Length[keys]}]
						]*)

PackageExport[buildKey]
PackageExport[customHash]
PackageExport[getKeysToNameCategory]
PackageExport[refactorWhiteList]

$SomeSymbol = 10