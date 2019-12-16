# Remove and re-add module if applicable:
$fnName = 'Tagging'
if(get-Module | Where-Object {$_.name -eq $fnName}){Remove-Module -Name $fnName}
Import-Module -Name ((Get-Item -Path ".\").FullName+"\Tagging.psm1") | out-null


#$Subscription="TfGM EDW"
$Subscription="Open Data Project Live"
#$ResourceGroupName='SQL-ManagedInstance-02-RG'
$ResourceGroupName = "Api-Default-North-Europe"


#$tags1 = @{"Environment"=""; "Dept"=""}
$tags1 = @{"Environment"=""; "Project"=""}

Select-AzSubscription -Subscription $Subscription | Out-Null
$t = getResourcesWithTags $tags1 $ResourceGroupName

$t


