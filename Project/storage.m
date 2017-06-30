Package["Project`"]

PackageExport[getListPlot]
PackageExport[getCurrentPoint]
PackageExport[addPoint]
PackageExport[exerciseDoneQ]

$userDatabase := $userDatabase =	$store[customHash[$RequesterWolframID,"SHA256"]]


(*best use case DateListPlot *)
getListPlot[]:=
	Map[{#["date"], #["point"]} &, Values[store["nnn"]]]

getCurrentPoint[]:=
	Total@Map[#["point"] &, Values[$userDatabase]]

addPoint[difficulty_, seed_, exId_, point_ ]:=
	AssociateTo[$userDatabase,
 					{difficulty, seed, exId} ->
  						<|
   							"point" -> point,
   							"date" -> Now[]
   						|>
 					
 		]

 exerciseDoneQ[difficulty_, seed_, exId_]:=
 	KeyExistsQ[$userDatabase, {difficulty, seed, exId}]