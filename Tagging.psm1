# Pulls most recent exclusion list from Github
function pullExclusions($fullPath)
{
    $cl = (Get-Item -Path ".\").FullName
    Set-Location $fullPath
    git pull
    Set-Location $cl
}

# Takes a file path and extracts the resources currently excluded from tagging
function getTagAllowed($exclusion_file_path)
{

    if (!(Test-Path $exclusion_file_path))
    {
        Write-Host "File doesnt exist"
        exit
    }
    
    $exclusions = Import-Csv $exclusion_file_path
    $canTag = @()
    
    $i = 0
    
    foreach ($line in $exclusions)
    {
        if($line.("supportsTags") -eq "TRUE")
        {
            $canTag += $line.("providerName")+"/"+$line.("resourceType")
        }
        #Write-Host $line.("providerName") $line.("resourceType") $line.("supportsTags") #$line.("costReport")
        $i = $i+1
        #if ($i -eq 10){break}
    }
    
    return $canTag

}

function getResourcesWithTags{
    param([hashtable]$tags, $rg)
    $r = @()
    $r = (Get-AzResource -Tag $tags -ResourceGroupName $rg).ResourceId
    if ($r -eq $null)
    {
        $r = ("null")
    }
    return $r
}
