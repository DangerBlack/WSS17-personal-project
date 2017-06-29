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

$CompleteExpressionApp = With[{
	playOrLoginTemplate     = templateLoader["playOrLogin.html"],
	categoryTemplate     	= templateLoader["category.html"], 
	home     				= templateLoader["play.html"], 
	detail   				= templateLoader["selectLoginPlay.html"],
	notfound 				= templateLoader["404.html"],
	keys = Keys[$whitelist],
	acsf = loadAllCategorySafeExample[$whitelist, $wholewhitelist]
	
	},
	URLDispatcher[{
		"/" ~~ EndOfString -> templateResponse[
					playOrLoginTemplate, {
				}],
		"/category/" ~~ EndOfString ->
 				templateResponse[
					categoryTemplate, {
					"keys"->keys,
					"n"->Length[keys]
				}
			],
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