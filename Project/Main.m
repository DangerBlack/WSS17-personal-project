Package["Project`"]

(* this is declaring that a certain simbol can be used IN the paclet *)
PackageScope[$SomeSymbol]

Unprotect[$TemplatePath]
$TemplatePath = Prepend[$TemplatePath,PacletManager`PacletResource["Project", "Assets"]]

$SomeSymbol = 10