$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host ""
Write-Host "---------------------------------------------------------"
Write-Host "MICROSOFT DEVBOX AND AZURE DEPLOYMENT ENVIRONMENTS DEMO DELETE SCRIPT"
Write-Host "---------------------------------------------------------"
Write-Host ""

$ParameterFile = Join-Path -Path $pwd -ChildPath "src" | Join-Path -ChildPath "parameters\main.parameters.json"
if (Test-Path $ParameterFile) {
    $settingsJson = (Get-Content -Path $ParameterFile -raw | ConvertFrom-Json)

    Write-Host "==> Getting Dev Center Resource Group to Delete First..."
    $envName = $settingsJson.parameters.settings.value.tags.envname

    $devCententerRGs = az group list --query "[?tags.delete == 'True' && tags.envname == '$envName' && contains(name,'devcenter')].{name:name}" -o tsv;

    foreach ($rg in $devCententerRGs)
    {
        if ($(az group exists --name $rg) -eq "true")
        {
            $kvs = az keyvault list --resource-group $rg --query "[].{name:name}" -o tsv;
            foreach ($kv in $kvs) {
                Write-Host "   ==> Deleting and Purging Keyvault $kv in $rg"
                az keyvault delete --name $kv --resource-group $rg --only-show-errors;
                az keyvault purge --name $kv --only-show-errors;
            }
            Write-Host "   ==> Deleting resource group $rg";
            az group delete --name $rg --yes;
        }
    }

    Write-Host "==> Getting Remaining Resource Groups"
    $rgGroups = az group list --query "[?tags.delete == 'True' && tags.envname == '$envName'].{name:name}" -o tsv;

    foreach ($rg in $rgGroups)
    {
        if ($(az group exists --name $rg) -eq "true")
        {
            $kvs = az keyvault list --resource-group $rg --query "[].{name:name}" -o tsv;
            foreach ($kv in $kvs) {
                Write-Host "   ==> Deleting and Purging Keyvault $kv in $rg"
                az keyvault delete --name $kv --resource-group $rg --only-show-errors;
                az keyvault purge --name $kv --only-show-errors;
            }
            Write-Host "==> Deleting resource group $rg";
            az group delete --name $rg --yes;
        }
    }

    Write-Host "==> Ensuring Key Vaults are purged..."
    $kvs = az keyvault list-deleted  --resource-type vault --query "[].{name:name}" -o tsv
    foreach ($kv in $kvs) {
        Write-Host "==> Purging Keyvault $kv..."
        az keyvault purge --name $kv;
    }


    Write-Host "==> Deleting Entra Apps, Service Principals and Federated Credential files..."
    foreach ($environmentType in $settingsJson.parameters.settings.value.environmentTypes) {
        $p = az ad app list --filter "appId eq '$($environmentType.appClientId)'" | ConvertFrom-Json
        if ($p.count -ne 0) {
            Write-Host "   ==> Deleting $($environmentType.name) Entra App"
            $a = az ad app delete --id $environmentType.appRegistrationId
        }

        $JSONFileName = "parameters\rest-body-" + $environmentType.name + ".json"
        $RestBodyFile = Join-Path -Path $pwd -ChildPath "src" | Join-Path -ChildPath $JSONFileName

        if ($Env:running_in_action -eq "false")
        {
            if (Test-Path $RestBodyFile)
            {
                Write-Host "   ==> Deleting $($environmentType.name) Federated Credential File"
                Remove-Item $RestBodyFile
            }
        }
    }
    Write-Host ""
    Write-Host "==> Deleting GitHub Repository Variables and Environments..."
    $OrgRepo = $settingsJson.parameters.settings.value.catalog.gitHubOrg + "/eShop"

    $eShopForkExists = gh api "/repos/$OrgRepo" | ConvertFrom-Json

    if ($null -ne $eShopForkExists.id)
    {
        $repo_variables = $( gh variable list -R "$OrgRepo" )

        if ($repo_variables -like "*AZURE_DEVCENTER*") {
            gh variable delete -R "$OrgRepo" AZURE_DEVCENTER
        }

        if ($repo_variables -like "*AZURE_PROJECT*") {
            gh variable delete -R "$OrgRepo" AZURE_PROJECT
        }

        if ($repo_variables -like "*AZURE_CATALOG*") {
            gh variable delete -R "$OrgRepo" AZURE_CATALOG
        }

        if ($repo_variables -like "*AZURE_CATALOG_ITEM*") {
            gh variable delete -R "$OrgRepo" AZURE_CATALOG_ITEM
        }

        if ($repo_variables -like "*AZURE_TENANT_ID*") {
            gh variable delete -R "$OrgRepo" AZURE_TENANT_ID
        }

        if ($repo_variables -like "*AZURE_SUBSCRIPTION_ID*") {
            gh variable delete -R "$OrgRepo" AZURE_SUBSCRIPTION_ID
        }

        Write-Host ""
        Write-Host "==> Deleting GitHub Repository Environments"
        foreach ($environmentType in $settingsJson.parameters.settings.value.environmentTypes) {
            $envExists = gh api "/repos/$OrgRepo/environments/$($environmentType.name)" | ConvertFrom-Json
            if ($null -ne $envExists.id)
            {
                Write-Host "   ==> Deleting Repository Environment '$($environmentType.name)'"
                gh api -X DELETE "/repos/$OrgRepo/environments/$($environmentType.name)" --silent
            }
        }
    }
    Write-Host ""
    Write-Host "==> Deleting temporary parameters file..."
    if ($Env:running_in_action -eq "false")
    {
        Remove-Item $ParameterFile
    }

    Write-Host ""
    Write-Host ""
    Write-Host "Your environment is removed."
}
else {
    Write-Host "No parameters file found. Nothing to delete. Exiting..."
    Write-Host ""
    Write-Host ""
}