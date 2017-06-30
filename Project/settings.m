Package["Project`"]

PackageExport[$store]
PackageExport[$uuid]

SetAttribute[getSettings,HoldRest]
getSettings[path_,failCallback_]:=
	With[
		{data = Quiet@Get[FileNameJoin[{PacletManager`PacletResource["Project", "Assets"], path}]]},
		If[	data =!= $Failed,
			data,
			With[
				{
					res=failCallback
				},
				Put[res,FileNameJoin[{PacletManager`PacletResource["Project", "Assets"], path}]];
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