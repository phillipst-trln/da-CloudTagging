
# Get a reference to the resource group that will be the scope of the assignment
$sub = "TfGM EDW"
Select-AzSubscription -Subscription $sub | Out-Null
$Subscription = Get-AzSubscription -SubscriptionName $sub
$rg = Get-AzResourceGroup -Name 'TestVM2'

# Get a reference to the built-in policy definition that will be assigned
#$definition = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq 'Audit VMs that do not use managed disks' }
$definition = "C:\DevArea\da-CloudTagging\TagPolicyDefinition.json"
$params = "C:\DevArea\da-CloudTagging\TagPolicyParams.json"

# Create the policy assignment with the built-in definition against your resource group
$pName = 'TfGM default tagging policy'
$dName = 'TfGM default tagging policy'
$dep = $true

if ($dep)
{
    New-AzPolicyDefinition -Name $pName `
        -DisplayName $dName `
        -Policy $definition `
        -Mode Indexed `
        -Parameter $params `

    $Policy = Get-AzPolicyDefinition -Name $pName

    $policyParams = '{ "allowedEnvironments": { "value": ["dev","int","uat","staging","prod"] } }'
        
    #-Scope "/subscriptions/$($Subscription.Id)"
    New-AzPolicyAssignment -Name $pName `
        -DisplayName $dName `
        -Scope "/subscriptions/$($Subscription.Id)" `
        -PolicyDefinition $Policy `
        -PolicyParameter $policyParams

    # -Scope $rg.ResourceId `
    # -Scope "/subscriptions/$($Subscription.Id)" `

}
else {
    Remove-AzPolicyAssignment -Name $pName -Scope $rg.ResourceId # -Force

    Remove-AzPolicyDefinition -Name $pName `
        -Force
    <#
    Remove-AzPolicyAssignment -Name $pName `
    -Scope $rg.ResourceId
    #>
}

