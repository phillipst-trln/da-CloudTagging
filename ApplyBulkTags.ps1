# Check Az module

$AzModuleVersion = "2.0.0"

if (!(Get-InstalledModule -Name Az -MinimumVersion $AzModuleVersion -ErrorAction SilentlyContinue)) {
    Write-Host "This script requires to have Az Module version $AzModuleVersion installed..
It was not found, please install from: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps"
    exit
} 

# Remove and re-add module if applicable:
$fnName = 'Tagging'
if(get-Module | Where-Object {$_.name -eq $fnName}){Remove-Module -Name $fnName}
Import-Module -Name ((Get-Item -Path ".\").FullName+"\Tagging.psm1") | out-null

#Connect-AzAccount;

# Resource group and subscription if required
#$subname="Jason Test"
#$ResourceGroupName="CS-WebJobs-NorthEurope-scheduler"

# Input file in format [ResourceId, Environment, Project]
$inputFile="C:\DevArea\da-CloudTagging\TagsToAdd_AdHoc.csv"

if (!(Test-Path $inputFile)){
    throw "$inputFile does not exist."
}

# Select subscription to work on if applicable
# $subs = Get-AzSubscription -SubscriptionName $subname
# Select-AzSubscription -Subscription $subs | Out-Null
$i = 0

$resrouces = Import-Csv -Path $inputFile

foreach ($resrouce in $resrouces)
{
    $r = $resrouce.ResourceId
    write-host "$i > $r"

    $resourceObj = Get-AzResource -ResourceId $r
    $tags = $resourceObj.Tags
    if (!($tags))
    {
        $tags = @{}
    }
    # Sort Environment Tag
    if ($tags["Environment"])
    {
        write-host "Old Environment Tag >" $tags["Environment"]" Overwriting..."
        $tags["Environment"] = $resrouce.Environment
    }
    else
    {
        $tags.Add("Environment", $resrouce.Environment)
    }

    # Sort project tag
    if ($tags["Project"])
    {
        write-host "Old Project Tag >" $tags["Project"]" Overwriting..."
        $tags["Project"] = $resrouce.Project
    }
    else 
    {
        $tags.Add("Project",$resrouce.Project)    
    }
    

    Set-AzResource -ResourceId $r `
        -Tag $tags `
        -Force | Out-Null

    $i = $i+1
    #break
    #if ($i -eq 10){break}
}

