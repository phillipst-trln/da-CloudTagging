

<#
    https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-using-tags

#>

$AzModuleVersion = "2.0.0"

if (!(Get-InstalledModule -Name Az -MinimumVersion $AzModuleVersion -ErrorAction SilentlyContinue)) {
    Write-Host "This script requires to have Az Module version $AzModuleVersion installed..
It was not found, please install from: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps"
    exit
} 

$Subscription="TfGM EDW"
$ResourceGroupName='SQL-ManagedInstance-01-RG'

# Shouldnt need this
#Connect-AzAccount;

$subs = Get-AzSubscription
$i = 0

foreach ($sub in $subs)
{
    #write-host $sub.Name+"....."
    Select-AzSubscription -Subscription $sub
    $rgs = Get-AzResourceGroup
    foreach ($rg in $rgs)
    {
        if ($rg.ResourceGroupName -eq "Default-SQL-NorthEurope")
        {
            Write-Host $rg.ResourceGroupName"=================="
            Get-AzResource -ResourceGroupName $rg.ResourceGroupName -TagName "Project" | SELECT Name, ResourceType, Tags | Format-Table
            break;
        }
    }
    if ($i -eq 1){break;}
    $i=$i+1
}

#(Find-AzureRmResource -ResourceGroupNameEquals $resourceGroupName -ResourceNameEquals $resourceName).Tags