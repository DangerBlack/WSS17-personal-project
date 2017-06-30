Package["Project`"]

$victoryDispatcher = FormFunction[
	{
		"Solution" -> <|"Interpreter"-> "String", "Input" -> ""|>,
		"exerciseInfo"-> <|"Interpreter"-> "String", "Input" -> ""|>,
		"category"-> <|"Interpreter"-> "String", "Input" -> ""|>
	},
	HTTPRedirect[$AppRoot <> "category/" <> ToString[#category] <> "/guess/" <> ToString[#exerciseInfo] <> "/" <> ToString[#Solution] <> "/" ] &
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
								"point" -> 100,	
								"exerciseInfo" -> exerciseInfo,
								"category"->cat
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
				 		If[MatchQ[Values[getSolution[expression]],{solution}],
				 			HTTPRedirect[$AppRoot <> "category/" <> cat <> "/success/" <> exerciseInfo <> "/" <> solution <> "/" ],
				 			HTTPRedirect[$AppRoot <> "category/" <> cat <> "/lose/"<> exerciseInfo <> "/" <> solution <> "/" ]
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
							expression = tweakFunction[$DataBase["Examples"][exId],difficulty]
						},
				 		templateResponse[
							template,
							{
								"userInfo" -> First[StringSplit[ToString[$RequesterWolframID], "@"]],
								"topic" -> $DataBase["CategoriesNames"][cat],
								"point" -> 150,
								"earnedPoint"-> 50,	
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
						$victoryDispatcher[HTTPRequestData["FormRules"]],
		"/category/" ~~ cat : category .. ~~ "/guess/"  ~~ exerciseInfo : (WordCharacter | ":" | "-") .. ~~ "/" ~~ solution : WordCharacter .. ~~ "/" ~~EndOfString :>
						guessGame[cat,exerciseInfo,solution],
		"/category/" ~~ cat : category .. ~~ "/success/"  ~~ exerciseInfo : (WordCharacter | ":" | "-") .. ~~ "/" ~~ solution : WordCharacter .. ~~ "/" ~~EndOfString :>
		 				winGame[winTemplate,cat,exerciseInfo,solution],
		"/category/" ~~ cat : category .. ~~ "/lose/"  ~~ exerciseInfo : (WordCharacter | ":" | "-") .. ~~ "/" ~~ solution : WordCharacter .. ~~ "/" ~~EndOfString :>
		 				winGame[loseTemplate,cat,exerciseInfo,solution],
		___ :> templateResponse[
			notfound,
			<||>,
			<|"StatusCode" -> 404|>
			]
		}
	]
];

PackageExport[$CompleteExpressionApp]