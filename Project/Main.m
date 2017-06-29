Package["Project`"]

(* this is declaring that a certain simbol can be used IN the paclet *)
PackageScope[$SomeSymbol]

Unprotect[$TemplatePath]
$TemplatePath = Prepend[$TemplatePath,PacletManager`PacletResource["Project", "Assets"]]

$whitelist=Get[FileNameJoin[{PacletManager`PacletResource["Project", "Assets"], "category.m"}]]
$wholewhitelist=DeleteDuplicates[Flatten[Map[Values, $whitelist]]]
PackageExport[$whitelist]
PackageExport[$wholewhitelist]

$SomeSymbol = 10