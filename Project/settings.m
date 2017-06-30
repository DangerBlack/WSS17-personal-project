Package["Project`"]

PackageExport[$store]
PackageExport[$uuid]

$store := $store = getSettings["database.m",CreateCloudExpression[<| |>]]

$uuid := $uuid = getSettings["uuid.m",CreateUUID[]]

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
(*
database = CreateCloudExpression[<| |>]

Put
*)