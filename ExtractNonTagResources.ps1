
function pullExclusions($fullPath)
{
    $cl = (Get-Item -Path ".\").FullName
    Set-Location $fullPath
    git pull
    Set-Location $cl
}

function getTagExclusions($exclusion_file_path)
{

    if (!(Test-Path $exclusion_file_path))
    {
        Write-Host "File doesnt exist"
        exit
    }
    
    $exclusions = Import-Csv $exclusion_file_path
    $cantTag = @()
    
    $i = 0
    
    foreach ($line in $exclusions)
    {
        if($line.("supportsTags") -eq "FALSE")
        {
            $cantTag += $line.("providerName")+"/"+$line.("resourceType")
        }
        #Write-Host $line.("providerName") $line.("resourceType") $line.("supportsTags") #$line.("costReport")
        $i = $i+1
        if ($i -eq 10){break}
    }
    
    return $cantTag

}

$exclusionsDirPath = (Get-Item -Path ".\").FullName+"\TagExclusions\resource-capabilities\"
$exclusionsFileName = "\tag-support.csv"
$exclusionsFilePath = $exclusionsDirPath+$exclusionsFileName

# Get latest exclusion file from Git Hub 
pullExclusions $exclusionsDirPath

# Return array of resources to be excluded.
getTagExclusions $exclusionsFilePath
