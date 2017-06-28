Package["Project`"]


$selectLoginPlayTemplate = FileTemplate["template/selectLoginPlay.html", Path -> PacletManager`PacletResource["Project", "Assets"]];
$playTemplate = FileTemplate["template/play.html", Path -> PacletManager`PacletResource["Project", "Assets"]];

PackageExport[$selectLoginPlayTemplate] 
PackageExport[$playTemplate] 