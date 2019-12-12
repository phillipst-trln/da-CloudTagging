

<#
    https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-using-tags

#>

<#
$AzModuleVersion = "2.0.0"

if (!(Get-InstalledModule -Name Az -MinimumVersion $AzModuleVersion -ErrorAction SilentlyContinue)) {
    Write-Host "This script requires to have Az Module version $AzModuleVersion installed..
It was not found, please install from: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps"
    exit
} 
#>

$Subscription="TfGM EDW"
$ResourceGroupName='SQL-ManagedInstance-01-RG'

# Shouldnt need this
#Connect-AzAccount;

$subs = Get-AzSubscription
$i = 0

foreach ($sub in $subs)
{
    if ($sub.Name -eq $Subscription)
    {
        #write-host $sub.Name+"....."
        Select-AzSubscription -Subscription $sub | Out-Null
        $rgs = Get-AzResourceGroup
        foreach ($rg in $rgs)
        {
            if ($rg.ResourceGroupName -eq "SQL-ManagedInstance-02-RG")
            {
                #Write-Host $rg.ResourceGroupName"=================="
                foreach ($resource in (Get-AzResource -ResourceGroupName $rg.ResourceGroupName))
                {
                    #if ($resource.Tags -eq $null)
                    #{
                        Get-AzResource -ResourceGroupName $rg.ResourceGroupName -TagName "Project" | SELECT Name, ResourceType, Tags | Format-Table
                        write-host $rg.ResourceGroupName"`t"$resource.Name"`t"$resource.ResourceType
                        #Set-AzResource -Tag @{ "Dept"="IT"; "Environment"="Test" } -ResourceId $resource.ResourceId -Force
                        $i = 1
                    #}
                }
            }

            #if ($i -ge 1){Write-Host "=============================================================="; $i=0}
        }
    }
}
