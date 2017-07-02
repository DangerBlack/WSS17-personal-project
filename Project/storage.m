Package["Project`"]

PackageExport[getListPlot]
PackageExport[getCurrentPoint]
PackageExport[addPoint]
PackageExport[exerciseDoneQ]
PackageExport[getExercisePoint]
PackageExport[getAllExerciseDone]
PackageExport[getAccumulateListPlot]


(*best use case DateListPlot *)
getListPlot[]:=
	With[
		{key = customHash[$RequesterWolframID,"SHA256"]},
		Values@$store[key][[All, {"date","point"}]]
	]

getAccumulateListPlot[]:=
	With[
		{gList= getListPlot[]},
		With[
			  {
			  	apoint = Accumulate@gList[[All, "point"]]
			  },
			  Table[<| "date" -> gList[[i, "date"]], "point" -> apoint[[i]]|>, 
			  		{i,1, Length[apoint]}
			  ]
		]
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
 
 getAllExerciseDone[difficulty_]:=
 	With[
		{key = customHash[$RequesterWolframID,"SHA256"]},
		Cases[Keys@$store[key], {difficulty, _, _}]
	]
