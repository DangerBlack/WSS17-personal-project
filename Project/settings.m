Package["Project`"]

PackageExport[$store]
PackageExport[$uuid]
PackageExport[getSettings]
PackageExport[$ApplicationRoot]
PackageExport[$ApplicationExampleFolder]

$ApplicationRoot := $ApplicationRoot = 
	If[
		$CloudEvaluation,
		CreateDirectory[
			FileNameJoin[{$HomeDirectory,"CTE","Assets"}]
		],
		PacletManager`PacletResource["Project", "Assets"]
	]

$ApplicationExampleFolder := $ApplicationExampleFolder=
	Replace[
		CreateDirectory[
			FileNameJoin[{$ApplicationRoot,"Examples"}]
		],
		{
			$Failed :> FileNameJoin[{$ApplicationRoot,"Examples"}],
			x_ :> x
		}] 

SetAttribute[getSettings,HoldRest]
getSettings[path_,failCallback_]:=
	With[
		{data = Quiet@Get[FileNameJoin[{$ApplicationRoot, path}]]},
		If[	data =!= $Failed,
			data,
			Print["canot find "<> path];
			With[
				{
					res=failCallback
				},
				Put[res,FileNameJoin[{$ApplicationRoot, path}]];
				res
			]
		]
	]

$store  = getSettings["database.m",CreateCloudExpression[<| |>]]

$uuid  = getSettings["uuid.m",CreateUUID[]]



(*
database = CreateCloudExpression[<| |>]

Put
*)