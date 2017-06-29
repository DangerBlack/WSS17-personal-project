Package["Project`"]

$SnowFlakerForm = FormFunction[
	{"Solution" -> <|"Interpreter"-> "String", "Input" -> "f"|>},
	HTTPRedirect[$AppRoot <> "guess/" <> ToString[#Solution]] &
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

customHash[expr_, rest___] := 	
	IntegerString[Hash[{expr, "chiavesegreta"}, rest], 36]
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

chooseDifficulty[template_, topic_, cat_] :=
	templateResponse[
					template, {
					"cat"->cat,
					"topic"->topic
				}]

generateExercise[template_,dictionaryKey_ , cat_, keys_, difficulty_ ] :=
	With[
		{seed=RandomInteger[{1,1000}]},
		HTTPRedirect[StringJoin[$AppRoot,"category/",cat,"/",difficulty,"/",signList[{dictionaryKey[[cat]],difficulty,seed}]]]
	](*Lookup[dictionaryKey,cat]*)

playGame[___]:=
	templateResponse[
			template,
			<||>,
			<|"StatusCode" -> 404|>
			]

(*exerciseID=RandomInteger[{1,Length[$whitelist[dictionaryKey[[cat]]]]}],*)

difficulties = "easy"|"medium"|"hard";

$CompleteExpressionApp = With[{
	playOrLoginTemplate     = templateLoader["playOrLogin.html"],
	categoryTemplate     	= templateLoader["category.html"], 
	difficultyTemplate     	= templateLoader["difficulty.html"], 
	playTemplate			= templateLoader["play.html"], 
	detail   				= templateLoader["selectLoginPlay.html"],
	notfound 				= templateLoader["404.html"],
	keys = Keys[$whitelist],
	category = Keys[getKeys[$whitelist]],
	dictionaryKey = getKeys[$whitelist],
	acsf = loadAllCategorySafeExample[$whitelist, $wholewhitelist]
	},
	URLDispatcher[{
		"/" ~~ EndOfString :> templateResponse[
					playOrLoginTemplate, {
				}],
		"/category/" ~~ EndOfString :>
		 				chooseCategory[categoryTemplate,keys],
		"/category/" ~~ cat : category .. ~~ "/" ~~ EndOfString :>
		 				chooseDifficulty[difficultyTemplate,keys[[Lookup[dictionaryKey,cat]]],cat],
		"/category/" ~~ cat : category .. ~~ "/" ~~ difficulty : difficulties ~~ "/" ~~EndOfString :>
		 				generateExercise[playTemplate,dictionaryKey,cat,keys,difficulty],
		"/category/" ~~ cat : category .. ~~ "/" ~~ difficulty : difficulties ~~ "/" ~~ exerciseInfo : RegularExpression["[a-zA-Z0-9:]*"] ~~ "/" ~~EndOfString :>
		 				playGame[notfound,dictionaryKey,cat,keys,difficulty,exerciseInfo],
		"/" ~~ EndOfString :> Replace[
			$SnowFlakerForm[Replace[HTTPRequestData["FormRules"], {} -> None]],
			form_FormFunction :> 
			With[
 				{quiz = Echo@selectQuizFromCategorySafeExample[34, acsf]},
 				templateResponse[
					home, {
					"userInfo" -> First[StringSplit[ToString[$WolframID], "@"]],
					"topic" -> Keys[$whitelist][[34]],
					"question" -> Rasterize[Column[HoldForm @@@ quiz[[2]]]],
					"example" -> Rasterize[Column@quiz[[3]],ImageFormattingWidth->600],
					"point" -> 100,	
					"tooltip" -> Last[quiz[[4]]]
				}]
			]
		],
		"/SnowFlaker/" ~~ n:DigitCharacter.. ~~ EndOfString 
			:> templateResponse[detail, {
				"title" -> "SnowFlaker / "<> n,
				"description" -> "This is the snow flake "<> n <>" which is super cool.",
				"result" -> generator[FromDigits[n]],
				"number" -> FromDigits[n]
			}],
		___ :> templateResponse[
			notfound,
			<||>,
			<|"StatusCode" -> 404|>
			]
		}
	]
];

PackageExport[$CompleteExpressionApp]