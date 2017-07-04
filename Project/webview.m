Package["Project`"]

$victoryDispatcher = FormFunction[
	{
		"Solution1" -> <|"Interpreter"-> "String", "Input" -> ""|>,
		"Solution2" -> <|"Interpreter"-> "String", "Input" -> "", "Required" -> False,"Default"->""|>,
		"exerciseInfo"-> <|"Interpreter"-> "String", "Input" -> ""|>,
		"category"-> <|"Interpreter"-> "String", "Input" -> ""|>
	},
	HTTPRedirect[$AppRoot <> "category/" <> ToString[#category] <> "/guess/" <> ToString[#exerciseInfo] <> "/" <> ToString[#Solution1]<>":"<>ToString[#Solution2] <> "/" ] &
]


victoryChecker[difficulty_, seed_, exId_, expression_, response_, urlWin_, urlLose_] :=
	If[MatchQ[Values[getSolution[expression]],Values[response]],
		( 
			addPoint[difficulty, seed, exId, calculateScore[difficulty,seed,exId]];
			HTTPRedirect[urlWin]
		),				 			
		With[
			{number = RandomReal[]},
			(
				SeedRandom[number];
				res1 = Identity @@@ $DataBase["Examples"][exId];
				SeedRandom[number];
				res2 = relaseAllPlaceholder[expression,response];
				If[res1==res2,
					( 
	 				addPoint[difficulty, seed, exId, calculateScore[difficulty,seed,exId]];
	 				HTTPRedirect[urlWin]
	 			),
	 			HTTPRedirect[urlLose]
				]
			)
		]
	]

(*
this should work!
victoryChecker[difficulty,
				seed,
				exId,
				expression,
				Values@response, $AppRoot <> "category/" <> cat <> "/success/" <> exerciseInfo <> "/" <> StringJoin@Riffle[Values[response],":"] <> "/", 
				$AppRoot <> "category/" <> cat <> "/lose/"<> exerciseInfo <> "/" <> StringJoin@Riffle[Values[response],":"] <> "/"
			]
*)
victoryDispatcher[playTemplate_ ,notfound_, cat_, exerciseInfo_ ]:=
	Replace[
		unsign[exerciseInfo], {
			{difficulty_, seed_, exId_} :> (
				SeedRandom[seed];
				With[
					{
						expression = tweakFunction[$DataBase["Examples"][exId],difficulty],
						form = generateVictoryDispatcher[difficulty][Replace[HTTPRequestData["FormRules"], {} -> None]]
					},
					Replace[
						form,{
							_FormFunction :> playGame[playTemplate,notfound,cat,keys,exerciseInfo,form],
							response_Association:>								
								If[MatchQ[Values[getSolution[expression]],Values[response]],
						 			( 
						 				addPoint[difficulty, seed, exId, calculateScore[difficulty,seed,exId]];
						 				HTTPRedirect[$AppRoot <> "category/" <> cat <> "/success/" <> exerciseInfo <> "/" <> StringJoin@Riffle[Values[response],":"] <> "/" ]
						 			),				 			
						 			HTTPRedirect[$AppRoot <> "category/" <> cat <> "/lose/"<> exerciseInfo <> "/" <> StringJoin@Riffle[Values[response],":"] <> "/" ]
						 		]		
						}
					]			 		
				]
			),
			$Failed :> templateResponse[
				failTemplate,
				<||>,
				<|"StatusCode" -> 400|>
			]
		}
	]

generateVictoryDispatcher[n_Integer] := FormFunction[
 Table[StringJoin["Solution", ToString@i] -> "String", {i, 1, n}]]

generateVictoryDispatcher["easy"|"medium"] := generateVictoryDispatcher[1]
generateVictoryDispatcher["hard"] := generateVictoryDispatcher[2]

$AppRoot := Replace[$EvaluationCloudObject, {None -> "/", c_CloudObject :> First[c] <> "/"}]; 

templateLoader[path_] := FileTemplate[
	FileNameJoin[{"template", path}],
	Path -> PacletManager`PacletResource["Project", "Assets"]
]

templateResponse[path_String, rest___] :=
	templateResponse[templateLoader[path], rest]

templateResponse[template_, context_, meta_:<||>] := 
	HTTPResponse[
		TemplateApply[
			template, <|
				context, 
				"AppRoot" -> $AppRoot
			|>
		],
		meta
	]

signList[s_List] :=
 	With[{l = Map[ToString, s]},
  	StringJoin[Riffle[Append[l, customHash[l, "SHA256"]], ":"]]
  ]
unsign[{l__, h_}] :=
	 If[MatchQ[customHash[{l}, "SHA256"], h], {l}, $Failed]
unsign[s_String] :=
 	unsign[StringSplit[s, ":"]]
unsign[__] := $Failed

chooseCategory[template_,categories_] :=
	templateResponse[
					template, {
					"categories":>Normal@categories,
					"n":>Length[Normal@categories]
				}]

showProfile[template_] :=
	templateResponse[
					template, {
					"userInfo":>First[StringSplit[ToString[$RequesterWolframID], "@"]],
					"plot":>Rasterize@DateListPlot[getListPlot[],PlotLegends -> {"point"},PlotLabel -> "Cumulative points through time"],
					"point":>getCurrentPoint[]
				}]

showLeaderBoard[template_] :=
	With[
		{gs=getGlobalScore[]},
		templateResponse[
						template, {
						"userInfo":>First[StringSplit[ToString[$RequesterWolframID], "@"]],
						"score":>gs,
						"n":> Length[gs],
						"point":>getCurrentPoint[]
					}]
	]

chooseDifficulty[template_, cat_] :=
	templateResponse[
					template, {
					"cat"->cat,
					"topic"->$DataBase["CategoriesNames"][cat],
					"userInfo":>First[StringSplit[ToString[$RequesterWolframID], "@"]],
					"point":>getCurrentPoint[]
				}]

getFilterdExerciseFromDifficulty["easy"|"medium",cat_] := $DataBase["Categories"][cat]
getFilterdExerciseFromDifficulty["hard",cat_]:= 
					Complement[
								$DataBase["Categories"][cat],
								Keys @ Select[$DataBase["ExamplesNSymbols"], # == 1 &]
							]

generateSeed[ cat_, keys_, difficulty_ ,listOfExAvailable_] :=
	(
		RandomSeed[];
		With[
			{
				seed = RandomInteger[{1,1000}]
			},
			If[ (*I have to check only exId and not the seed!!!! *)
				Length[listOfExAvailable]<=0,(* Check if you arleady did this exercise and if change random seed *)
				HTTPRedirect[$AppRoot <> "category/"],
				HTTPRedirect[StringJoin[$AppRoot,"category/",cat,"/",signList[{
																			difficulty,
																			seed,
																			RandomChoice[
																				listOfExAvailable
																			]
																		}]
																		,"/"]]
			]
		]
	)

generateSeed[ cat_, keys_, difficulty_ ] := 
	generateSeed[
					cat,
					keys,
					difficulty,
					Complement[
							getFilterdExerciseFromDifficulty[difficulty,cat],
							getAllExerciseDone[difficulty][[All,3]]
					]
				]
(*Lookup[dictionaryKey,cat]*)



playGame[template_,failTemplate_, cat_, keys_, exerciseInfo_, form_ ]:=
	Replace[
		unsign[exerciseInfo], {
			{difficulty_, seed_, exId_} :> (
					SeedRandom[seed];
					With[
						{
							expression = tweakFunction[$DataBase["Examples"][exId],difficulty]
						},
				 		templateResponse[
							template,
							{
								"userInfo" -> First[StringSplit[ToString[$RequesterWolframID], "@"]],
								"topic" -> $DataBase["CategoriesNames"][cat],
								"question" -> Rasterize[Column[HoldForm@@@expression (*InputForm should be better or maybe FullForm?*)
															  ]
														],
								(*Rasterize[Column[HoldForm @@@ $DataBase["Examples"][examples]]],*)
								"example" -> Rasterize[Column[Identity @@@ $DataBase["Examples"][exId]],ImageFormattingWidth->600],
								"point" -> getCurrentPoint[],	
								"exerciseInfo" -> exerciseInfo,
								"category"->cat,
								"numberOfSolution"->Length[getSolution[expression]],
								"tips"-> If[difficulty=="easy",StringLength@Values[First[getSolution[expression]]],0],
								"error"->error,
								"form"-> form
							}
						]
					]
				),
			$Failed :> templateResponse[
			failTemplate,
			<||>,
			<|"StatusCode" -> 404|>
			]
		}
	]


winGame[template_,cat_,exerciseInfo_,solution_]:=
		Replace[
		unsign[exerciseInfo], {
			{difficulty_, seed_, exId_} :> (
					SeedRandom[seed];
					With[
						{
							expression = tweakFunction[$DataBase["Examples"][exId],difficulty],
							earnedPoint = getExercisePoint[difficulty,seed,exId],
							point = getCurrentPoint[]
						},
				 		templateResponse[
							template,
							{
								"userInfo" -> First[StringSplit[ToString[$RequesterWolframID], "@"]],
								"topic" -> $DataBase["CategoriesNames"][cat],
								"point" -> point,
								"earnedPoint"-> earnedPoint["point"],
								"date":> DateString[earnedPoint["date"]],
								"exerciseInfo" -> exerciseInfo,
								"category"->cat,
								"difficulty"->difficulty
							}
						]
					]
				),
			$Failed :> templateResponse[
			failTemplate,
			<||>,
			<|"StatusCode" -> 404|>
			]
		}
	]

loseGame[template_,cat_,exerciseInfo_,solution_]:=
		Replace[
		unsign[exerciseInfo], {
			{difficulty_, seed_, exId_} :> (
					SeedRandom[seed];
					With[
						{
							expression = tweakFunction[$DataBase["Examples"][exId],difficulty],
							point = getCurrentPoint[]
						},
				 		templateResponse[
							template,
							{
								"userInfo" -> First[StringSplit[ToString[$RequesterWolframID], "@"]],
								"topic" -> $DataBase["CategoriesNames"][cat],
								"point" -> point,
								"date":> DateString[earnedPoint["date"]],
								"exerciseInfo" -> exerciseInfo,
								"category"->cat,
								"difficulty"->difficulty
							}
						]
					]
				),
			$Failed :> templateResponse[
			failTemplate,
			<||>,
			<|"StatusCode" -> 404|>
			]
		}
	]

(*exerciseID=RandomInteger[{1,Length[$whitelist[dictionaryKey[[cat]]]]}],*)

difficulties = "easy"|"medium"|"hard";


$CompleteExpressionApp := With[{
	playOrLoginTemplate     = templateLoader["playOrLogin.html"],
	categoryTemplate     	= templateLoader["category.html"], 
	profileTemplate     	= templateLoader["profile.html"], 
	leaderBoardTemplate    	= templateLoader["leaderboard.html"], 
	difficultyTemplate     	= templateLoader["difficulty.html"], 
	playTemplate			= templateLoader["play.html"], 
	detail   				= templateLoader["selectLoginPlay.html"],
	winTemplate				= templateLoader["win.html"],
	loseTemplate			= templateLoader["lose.html"],
	notfound 				= templateLoader["404.html"],
	keys = Values[$DataBase["CategoriesNames"]],
	category = Keys[$DataBase["CategoriesNames"]]
	},
	URLDispatcher[{
		"/" ~~ EndOfString :> templateResponse[
					playOrLoginTemplate, {
				}],
		"/category/" ~~ EndOfString :>
		 				chooseCategory[categoryTemplate,$DataBase["CategoriesNames"]],
		"/profile/" ~~ EndOfString :>
		 				showProfile[profileTemplate],
		"/leaderboard/" ~~ EndOfString :>
		 				showLeaderBoard[leaderBoardTemplate],
		"/category/" ~~ cat : category .. ~~ "/" ~~ EndOfString :>
		 				chooseDifficulty[difficultyTemplate,cat],
		"/category/" ~~ cat : category .. ~~ "/" ~~ difficulty : difficulties ~~ "/" ~~EndOfString :>
		 				generateSeed[cat,keys,difficulty],
		"/category/" ~~ cat : category .. ~~ "/" ~~ exerciseInfo : (WordCharacter | ":" | "-") .. ~~ "/" ~~EndOfString :>
						(**Replace[HTTPRequestData["FormRules"], {} -> None],**)
						victoryDispatcher[playTemplate, notfound, cat,exerciseInfo],
		"/category/" ~~ cat : category .. ~~ "/success/"  ~~ exerciseInfo : (WordCharacter | ":" | "-") .. ~~ "/" ~~ solution : (WordCharacter | ":") .. ~~ "/" ~~EndOfString :>
		 				winGame[winTemplate,cat,exerciseInfo,StringSplit[solution,":"]],
		"/category/" ~~ cat : category .. ~~ "/lose/"  ~~ exerciseInfo : (WordCharacter | ":" | "-") .. ~~ "/" ~~ solution : (WordCharacter | ":") .. ~~ "/" ~~EndOfString :>
		 				loseGame[loseTemplate,cat,exerciseInfo,StringSplit[solution,":"]],
		___ :> templateResponse[
			notfound,
			<||>,
			<|"StatusCode" -> 404|>
			]
		}
	]
];

PackageExport[$CompleteExpressionApp]