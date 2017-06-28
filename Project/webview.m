Package["Project`"]

Unprotect[$TemplatePath]
$TemplatePath = Prepend[$TemplatePath,PacletManager`PacletResource["Project", "Assets"]]

$selectLoginPlayTemplate = FileTemplate["template/selectLoginPlay.html", Path -> PacletManager`PacletResource["Project", "Assets"]];
$playTemplate = FileTemplate["template/play.html", Path -> PacletManager`PacletResource["Project", "Assets"]];

PackageExport[$selectLoginPlayTemplate] 
PackageExport[$playTemplate] 