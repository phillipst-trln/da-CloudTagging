
$Environments = @(
    "dev"    
    ,"int"
    ,"uat"
    ,"staging"
    ,"prod"
)

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
    $s = @()
    
    #$r = (Get-AzResource -Tag $tags -ResourceGroupName $rg).ResourceId
    $r = Get-AzResource -Tag $tags -ResourceGroupName $rg

    # Loop over resources in resource group
    foreach ($res in $r)
    {
        $add = $true
        # Loop over tags
        foreach ($t in $res.Tags.Keys)
        {
            if (isValueInKeyList $tags $t)
            {
                # If tags contain uppercase chars, mark flag as false
                if ($res.Tags[$t] -cmatch "[A-Z]")
                {
                    #write-host "Got to case check"
                    $add = $false
                    break
                }
                # if environment tag is not valid from environments array
                if ($t -eq "Environment" -and (!($Environments.Contains($res.Tags[$t]))))
                {
                    #write-host "Got to value check"
                    $add = $false
                    break                
                }
            }
        }
        # If the tags are valid add to output list
        if ($add) {$s += $res.ResourceId}
    }
    
    # Handle null array
    #if ($s -eq $null -or $s )
    if ($s.count -eq 0)
    {
        $s += "null"
    }
    return $s
}

function convertHTtoString
{
    param([Hashtable]$tags)
    $ret=""
    foreach ($t in $tags.Keys)
    {
        if (!($t -match "^hidden-related"))
        {
            $ret = $ret+$t+"="+$tags[$t]+"; "
        }
    }
    return $ret
}


function amalgamateLists{
    param([list]$tag1, [list]$tag2)
    $r = @()

    foreach ($v in $tag1)
    {
        foreach ($w in $tag2)
        {
            if ($w -eq $v)
            {
                $r += $v
            }
        }
    }
    return $r
}

function isValueInKeyList
{
    param([Hastable]$ht, $v)
    $res = $false
    foreach($k in $ht.Keys)
    {
        if ($k -eq $v)
        {
            $res = $true
            break
        }
    }
    return $res
}