Package["Project`"]

PackageExport[getListPlot]
PackageExport[getCurrentPoint]
PackageExport[addPoint]
PackageExport[exerciseDoneQ]
PackageExport[getExercisePoint]
PackageExport[getAllExerciseDone]
PackageExport[getGlobalScore]
(*PackageExport[getAccumulateListPlot]*)

hashType = "MD5"
storageHash[key_,hashType_]:=
	IntegerString[Hash[key,hashType], 16, 32]

(*best use case DateListPlot *)
getListPlot[]:=
	Replace[
		With[
			{key = storageHash[$RequesterWolframID,hashType]},
			$store[key]
		],{
			_Failure :> {{Now,0}},
			x___ :> Values@x[[All, {"date", "total"}]]			
		}
	]

(*
getColorFromKey[key_]:=
	RGBColor @@ 
		Map[FromDigits[#, 2]/255 &, 
		  	Partition[
		   		Map[If[# > 109, 1, 0] &, ToCharacterCode[key]][[25 ;; 50]],
		   		8
			]
		]

makeAutomata[key_] :=
	Rasterize@ArrayPlot[
  				CellularAutomaton[30, 
   				Map[
   					If[# > 109, 1, 0] &, 
   					ToCharacterCode[key]][[1 ;; 25]
   				], 
   				25],
   				ColorRules-> {1->getColorFromKey[key],0->White}(*ColorRules -> {1 -> Red, 0 -> Yellow}*)
	]
*)

getGlobalScore[]:=
	With[
		{key = storageHash[$RequesterWolframID,hashType]},
		KeyValueMap[<|"hash"->#1, #2 |> &, 
					Sort[$store[][[All, -1]], #1["total"] > #2["total"] &]
		]
	]
(*
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
	]*)
getCurrentPoint[]:=
	Replace[
		With[
			{key = storageHash[$RequesterWolframID,hashType]},
			Quiet@Total@$store[[key,All,"point"]][]
		],
		{
			total_Integer :> total,
			___ :> 0
		}
	]

addPoint[difficulty_, seed_, exId_, point_ ]:=
	With[
		{key = storageHash[$RequesterWolframID,hashType]},
		AssociateTo[$store[key],
 					{difficulty, seed, exId} ->
  						<|
   							"point" -> point,
   							"date" -> Now,
   							"total" -> getCurrentPoint[] + point
   						|>
 					
 		]
 	]
 getExercisePoint[difficulty_, seed_, exId_]:=
 	With[
		{key = storageHash[$RequesterWolframID,hashType]},
		$store[key][{difficulty,seed,exId}]
	]
 exerciseDoneQ[difficulty_, seed_, exId_]:=
 	With[
		{key = storageHash[$RequesterWolframID,hashType]},
		KeyExistsQ[$store[key], {difficulty, seed, exId}]
	]
 
 getAllExerciseDone[difficulty_]:=
 	With[
		{key = storageHash[$RequesterWolframID,hashType]},
		Cases[Keys@$store[key], {difficulty, _, _}]
	]
