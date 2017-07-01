Package["Project`"]

PackageExport[getListPlot]
PackageExport[getCurrentPoint]
PackageExport[addPoint]
PackageExport[exerciseDoneQ]
PackageExport[getExercisePoint]


(*best use case DateListPlot *)
getListPlot[]:=
	With[
		{key = customHash[$RequesterWolframID,"SHA256"]},
		Values@$store[key][[All, {"date","point"}]]
	]

getCurrentPoint[]:=
	With[
		{key = customHash[$RequesterWolframID,"SHA256"]},
		Total@$store[[key,All,"point"]][]
	]

addPoint[difficulty_, seed_, exId_, point_ ]:=
	With[
		{key = customHash[$RequesterWolframID,"SHA256"]},
		AssociateTo[$store[key],
 					{difficulty, seed, exId} ->
  						<|
   							"point" -> point,
   							"date" -> Now
   						|>
 					
 		]
 	]
 getExercisePoint[difficulty_, seed_, exId_]:=
 	With[
		{key = customHash[$RequesterWolframID,"SHA256"]},
		$store[key][{difficulty,seed,exId}]
	]
 exerciseDoneQ[difficulty_, seed_, exId_]:=
 	With[
		{key = customHash[$RequesterWolframID,"SHA256"]},
		KeyExistsQ[$store[key], {difficulty, seed, exId}]
	]
 	