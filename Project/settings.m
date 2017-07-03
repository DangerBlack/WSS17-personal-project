Package["Project`"]

PackageExport[$store]
PackageExport[$uuid]
PackageExport[getSettings]
PackageExport[$ApplicationRoot]
PackageExport[$ApplicationExampleFolder]

$ApplicationRoot := $ApplicationRoot = 
	With[
		{path = If[
			TrueQ[$CloudEvaluation], 
			FileNameJoin[{$HomeDirectory, "CTE", "Assets"}],
			FileNameJoin[{$TemporaryDirectory, "CTE", "Assets"}]
		]},
		Quiet[CreateDirectory[path], CreateDirectory::filex];
		path
	]

$ApplicationExampleFolder := $ApplicationExampleFolder=
	With[
		{path = FileNameJoin[{$ApplicationRoot, "Examples"}]},
		Quiet[CreateDirectory[path], CreateDirectory::filex];
		path
	]

SetAttribute[getSettings,HoldRest]
getSettings[path_,failCallback_]:=
	With[
		{data = Quiet @ Get[FileNameJoin[{$ApplicationRoot, path}]]},
		If[	data =!= $Failed,
			data,
			With[
				{res = failCallback},
				Put[res, FileNameJoin[{$ApplicationRoot, path}]];
				res
			]
		]
	]

$store  = getSettings["database.m",CreateCloudExpression[<| |>]];

$uuid  = getSettings["uuid.m",CreateUUID[]];



(*
database = CreateCloudExpression[<| |>]

Put
*)