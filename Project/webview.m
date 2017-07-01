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

chooseCategory[template_,keys_] :=
	templateResponse[
					template, {
					"keys":>keys,
					"n":>Length[keys]
				}]

chooseDifficulty[template_, cat_] :=
	templateResponse[
					template, {
					"cat"->cat,
					"topic"->$DataBase["CategoriesNames"][cat]
				}]

generateSeed[ cat_, keys_, difficulty_ ] :=
	(
		RandomSeed[];
		With[
			{seed=RandomInteger[{1,1000}]},
			(
				RandomSeed[seed];
				HTTPRedirect[StringJoin[$AppRoot,"category/",cat,"/",signList[{difficulty,seed,RandomChoice[$DataBase["Categories"][cat]]}],"/"]]
			)
		]
	)

(*Lookup[dictionaryKey,cat]*)



playGame[template_,failTemplate_, cat_, keys_, exerciseInfo_ ]:=
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
								"question" -> Rasterize[Column[HoldForm@@@expression
															  ]
														],
								(*Rasterize[Column[HoldForm @@@ $DataBase["Examples"][examples]]],*)
								"example" -> Rasterize[Column[Identity @@@ $DataBase["Examples"][exId]],ImageFormattingWidth->600],
								"point" -> getCurrentPoint[],	
								"exerciseInfo" -> exerciseInfo,
								"category"->cat,
								"numberOfSolution"->Length[getSolution[expression]],
								"tips"-> If[difficulty=="easy",StringLength@Values[First[getSolution[expression]]],0]
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

guessGame[cat_, exerciseInfo_ ,solution_]:=
	Replace[
		unsign[exerciseInfo], {
			{difficulty_, seed_, exId_} :> (
					SeedRandom[seed];
					With[
						{
							expression = tweakFunction[$DataBase["Examples"][exId],difficulty]
						},
				 		If[MatchQ[Values[getSolution[expression]],solution],
				 			( 
				 				addPoint[difficulty, seed, exId, calculateScore[difficulty,seed,exId]];
				 				HTTPRedirect[$AppRoot <> "category/" <> cat <> "/success/" <> exerciseInfo <> "/" <> StringJoin@Riffle[solution,":"] <> "/" ]
				 			),				 			
				 			HTTPRedirect[$AppRoot <> "category/" <> cat <> "/lose/"<> exerciseInfo <> "/" <> StringJoin@Riffle[solution,":"] <> "/" ]
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
		 				chooseCategory[categoryTemplate,keys],
		"/category/" ~~ cat : category .. ~~ "/" ~~ EndOfString :>
		 				chooseDifficulty[difficultyTemplate,cat],
		"/category/" ~~ cat : category .. ~~ "/" ~~ difficulty : difficulties ~~ "/" ~~EndOfString :>
		 				generateSeed[cat,keys,difficulty],
		"/category/" ~~ cat : category .. ~~ "/" ~~ exerciseInfo : (WordCharacter | ":" | "-") .. ~~ "/" ~~EndOfString :>
		 				playGame[playTemplate,notfound,cat,keys,exerciseInfo],
		"/guess/" ~~EndOfString :>
						(**showResult[successTemplate,failTemplate,exerciseInfo],**)
						$victoryDispatcher[Replace[HTTPRequestData["FormRules"], {} -> None]],
		"/category/" ~~ cat : category .. ~~ "/guess/"  ~~ exerciseInfo : (WordCharacter | ":" | "-") .. ~~ "/" ~~ solution : (WordCharacter | ":") .. ~~ "/" ~~EndOfString :>
						guessGame[cat,exerciseInfo,StringSplit[solution,":"]],
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