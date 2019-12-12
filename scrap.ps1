# Remove and re-add module if applicable:
$fnName = 'Tagging'
if(get-Module | Where-Object {$_.name -eq $fnName}){Remove-Module -Name $fnName}
Import-Module -Name ((Get-Item -Path ".\").FullName+"\Tagging.psm1") | out-null

#$tags1 = @{"Environment"=""; "Dept"=""}
$tags1 = @{"Project"=""}

$t = getResourcesWithTags $tags1 "Default-Web-NorthEurope"


