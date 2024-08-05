$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = 'Stop'

function GetSettings {
    $ParameterFile = Join-Path -Path $pwd -ChildPath "src" | Join-Path -ChildPath "parameters\main.parameters.json"
    $settingsJson = (Get-Content -Path $ParameterFile -raw | ConvertFrom-Json)
    return $settingsJson
}
function CreateFederatedCredentials {
    if ([System.Convert]::ToBoolean($Env:create_ade)) {
        $settingsJson = GetSettings
        $RestBodyFileTemplate = Join-Path -Path $pwd -ChildPath "src" | Join-Path -ChildPath "parameters\rest-body.json"
        $restJsonTemplate = (Get-Content -Path $RestBodyFileTemplate -raw | ConvertFrom-Json)
        $OrgRepo = $settingsJson.parameters.settings.value.catalog.gitHubOrg + "/eShop"
        foreach ($environmentType in $settingsJson.parameters.settings.value.environmentTypes) {
            $JSONFileName = "parameters\rest-body-" + $environmentType.name + ".json"
            $RestBodyFile = Join-Path -Path $pwd -ChildPath "src" | Join-Path -ChildPath $JSONFileName
            $restJson = $restJsonTemplate
            $restJson.name = $settingsJson.parameters.settings.value.demoName + $environmentType.name
            $restJson.subject = "repo:" + $OrgRepo + ":environment:" + $environmentType.name
            $restJson.description = $environmentType.name
            $restJson | ConvertTo-Json -depth 32 | set-content $RestBodyFile

            $registration = $environmentType.appRegistrationId
            $URI = "https://graph.microsoft.com/beta/applications/$registration/federatedIdentityCredentials"
            # check to see if federated credentials already exist in Azure
            $fedCreds = az rest --method GET --uri $URI | ConvertFrom-Json
            if ($null -ne $fedCreds.value.name) {
                Write-Host "==> Federated Identity for $($settingsJson.parameters.settings.value.demoName)$($environmentType.name) already exists"
                continue
            }
            $fedCreds = az rest --method POST --uri $URI  --body "@$RestBodyFile"
            Write-Host "==> Created Federated Identity for $($settingsJson.parameters.settings.value.demoName)$($environmentType.name)"
        }
    }
}

function PopulateGitHubRepo {
    if ([System.Convert]::ToBoolean($Env:create_ade)) {
        $settingsJson = GetSettings
        $OrgRepo = $settingsJson.parameters.settings.value.catalog.gitHubOrg + "/eShop"

        Write-Host ""
        Write-Host "==> Adding these items to GitHub Repository Variables using GitHub CLI"
        Write-Host "   ==> AZURE_DEVCENTER	        Set to: $($settingsJson.parameters.settings.value.demoName.Trim())-devcenter"
        Write-Host "   ==> AZURE_PROJECT	        Set to: $($settingsJson.parameters.settings.value.demoName.Trim())-project"
        Write-Host "   ==> AZURE_CATALOG	        Set to: $($settingsJson.parameters.settings.value.catalog.name)"
        Write-Host "   ==> AZURE_CATALOG_ITEM       Set to: $($settingsJson.parameters.settings.value.catalog.catalogItem)"
        Write-Host "   ==> AZURE_SUBSCRIPTION_ID    Set to: $($settingsJson.parameters.settings.value.subscriptionId)"
        Write-Host "   ==> AZURE_TENANT_ID	        Set to: $($settingsJson.parameters.settings.value.tenantId)"

        $repo_variables = $( gh variable list -R "$OrgRepo" )

        Write-Host ""
        gh variable set -R "$OrgRepo" AZURE_DEVCENTER -b "$($settingsJson.parameters.settings.value.demoName.Trim())-devcenter"
        gh variable set -R "$OrgRepo" AZURE_PROJECT -b "$($settingsJson.parameters.settings.value.demoName.Trim())-project"
        gh variable set -R "$OrgRepo" AZURE_CATALOG -b "$($settingsJson.parameters.settings.value.catalog.name)"
        gh variable set -R "$OrgRepo" AZURE_CATALOG_ITEM -b "$($settingsJson.parameters.settings.value.catalog.catalogItem)"
        gh variable set -R "$OrgRepo" AZURE_TENANT_ID -b "$($settingsJson.parameters.settings.value.tenantId)"
        gh variable set -R "$OrgRepo" AZURE_SUBSCRIPTION_ID -b "$($settingsJson.parameters.settings.value.subscriptionId)"

        Write-Host "Checking if Repo contains variable 'AZURE_CLIENT_ID' (not allowed)"

        if ($repo_variables -like "*AZURE_CLIENT_ID*") {
            Write-Host "ERROR: Repository should not have a variable 'AZURE_CLIENT_ID'"
            Exit 1
        }
        else {
            Write-Host "Repository does not contain variable 'AZURE_CLIENT_ID'"
        }

        foreach ($environmentType in $settingsJson.parameters.settings.value.environmentTypes) {
            Write-Host ""
            Write-Host "Ensuring Repository Environment '$($environmentType.name)' exists"
            gh api -X PUT "/repos/$OrgRepo/environments/$($environmentType.name)" --silent

            if ($environmentType.name -eq "Prod") {
                Write-Host "Add protection rules to Prod Environment"
                $GHRulesFile = Join-Path -Path $pwd -ChildPath "scripts" | Join-Path -ChildPath "gh-prod-rules-api-body.json"
                #use github cli to protect the main branch
                $gh = gh api -X PUT "/repos/$OrgRepo/environments/Prod" --input $GHRulesFile --verbose
            }

            Write-Host "Saving secret to Repository for Environment '$($environmentType.name)'"
            gh secret set AZURE_CLIENT_ID -R "$OrgRepo" -b "$($environmentType.appClientId)" --env "$($environmentType.name)"
        }
    }
}

Write-Host ""
Write-Host ""
Write-Host "---------------------------------------------------------"
Write-Host "MICROSOFT DEVBOX AND AZURE DEPLOYMENT ENVIRONMENTS DEMO GENERATOR"
Write-Host "---------------------------------------------------------"
Write-Host ""

if ($Env:skip_deployment -eq "false") {

    Write-Host ""
    Write-Host "==> Gathering Azure Tenant and Subscription Data..."
    $AZURE_SUBSCRIPTION_ID = $(az account show --query id --output tsv)
    $AZURE_TENANT_ID = $(az account show --query tenantId --output tsv)

    Write-Host ""
    Write-Host "==> Building Bicep Parameters file..."
    $BicepParameterFile = Join-Path -Path $pwd -ChildPath "src" | Join-Path -ChildPath "parameters\main.bicepparam"

    $ParameterFile = Join-Path -Path $pwd -ChildPath "src" | Join-Path -ChildPath "parameters\main.parameters.json"
    az bicep build-params --file $BicepParameterFile --outfile $ParameterFile

    $settingsJson = (Get-Content -Path $ParameterFile -raw | ConvertFrom-Json)

    Write-Host "==> Adding GitHub Personal Access Token to main.parameters.json file..."
    $settingsJson.parameters.settings.value.githubPat = $Env:GITHUB_TOKEN

    $AZURE_PROJECT = $settingsJson.parameters.settings.value.demoName + "-project"

    Write-Host ""
    Write-Host "==> Creating Entra ID App Registrations for Dev, Test and Prod..."
    $DEV_APPLICATION_ID = az ad app create --display-name $AZURE_PROJECT-Dev --query id -o tsv
    $DEV_AZURE_CLIENT_ID = az ad app show --id $DEV_APPLICATION_ID --query appId -o tsv

    $TEST_APPLICATION_ID = az ad app create --display-name $AZURE_PROJECT-Test --query id -o tsv
    $TEST_AZURE_CLIENT_ID = az ad app show --id $TEST_APPLICATION_ID --query appId -o tsv

    $PROD_APPLICATION_ID = az ad app create --display-name $AZURE_PROJECT-Prod --query id -o tsv
    $PROD_AZURE_CLIENT_ID = az ad app show --id $PROD_APPLICATION_ID --query appId -o tsv

    Write-Host ""
    Write-Host "==> Creating Entra ID Service Principals for Dev, Test and Prod..."

    $d = az ad sp list --display-name "$AZURE_PROJECT-Dev" | ConvertFrom-Json
    if ($null -ne $d.id) {
        Write-Output "   ==> Service principal $($d.displayName) exists. Deleting..."
        az ad sp delete --id $d.id
        Write-Output "   ==> Service principal deleted."
    }

    $t = az ad sp list --display-name "$AZURE_PROJECT-Test" | ConvertFrom-Json
    if ($null -ne $t.id) {
        Write-Output "Service principal $($t.displayName) exists. Deleting..."
        az ad sp delete --id $t.id
        Write-Output "   ==> Service principal deleted."
    }

    $p = az ad sp list --display-name "$AZURE_PROJECT-Prod" | ConvertFrom-Json
    if ($null -ne $p.id) {
        Write-Output "   ==> Service principal $($p.displayName) exists. Deleting..."
        az ad sp delete --id $p.id
        Write-Output "   ==> Service principal deleted."
    }

    $DEV_SERVICE_PRINCIPAL_ID = az ad sp create --id $DEV_AZURE_CLIENT_ID --query id -o tsv
    $TEST_SERVICE_PRINCIPAL_ID = az ad sp create --id $TEST_AZURE_CLIENT_ID --query id -o tsv
    $PROD_SERVICE_PRINCIPAL_ID = az ad sp create --id $PROD_AZURE_CLIENT_ID --query id -o tsv
    Write-Host "   ==> Dev:"    $DEV_SERVICE_PRINCIPAL_ID
    Write-Host "   ==> Test:"   $TEST_SERVICE_PRINCIPAL_ID
    Write-Host "   ==> Prod:"   $PROD_SERVICE_PRINCIPAL_ID

    Write-Host ""
    Write-Host "==> Adding Service Principals to main.parameters.json file..."

    foreach ($environmentType in $settingsJson.parameters.settings.value.environmentTypes) {
        Switch ($environmentType.name) {
            "Dev" {
                $environmentType.servicePrincipalId = $DEV_SERVICE_PRINCIPAL_ID
                $environmentType.appRegistrationId = $DEV_APPLICATION_ID
                $environmentType.appClientId = $DEV_AZURE_CLIENT_ID
            }
            "Test" {
                $environmentType.servicePrincipalId = $TEST_SERVICE_PRINCIPAL_ID
                $environmentType.appRegistrationId = $TEST_APPLICATION_ID
                $environmentType.appClientId = $TEST_AZURE_CLIENT_ID
            }
            "Prod" {
                $environmentType.servicePrincipalId = $PROD_SERVICE_PRINCIPAL_ID
                $environmentType.appRegistrationId = $PROD_APPLICATION_ID
                $environmentType.appClientId = $PROD_AZURE_CLIENT_ID
            }
        }
    }

    $Env:Org = gh api /user | ConvertFrom-Json | Select-Object -ExpandProperty login

    $settingsJson.parameters.settings.value.subscriptionId = $AZURE_SUBSCRIPTION_ID
    $settingsJson.parameters.settings.value.tenantId = $AZURE_TENANT_ID
    $settingsJson.parameters.settings.value.tags.envname = $settingsJson.parameters.settings.value.demoName
    $settingsJson.parameters.settings.value.catalog.gitHubOrg = $Env:Org
    $settingsJson.parameters.settings.value.createDevBox = [System.Convert]::ToBoolean($Env:create_devbox)
    $settingsJson.parameters.settings.value.createADE = [System.Convert]::ToBoolean($Env:create_ade)

    Write-Host ""
    Write-Host "==> Adding Values to main.parameters.json file..."
    Write-Host "   ==> Azure Subscription ID:   $($settingsJson.parameters.settings.value.subscriptionId)"
    Write-Host "   ==> Azure Tenant Id:         $($settingsJson.parameters.settings.value.tenantId)"
    Write-Host "   ==> GitHub User:             $($Env:Org)"

    Write-Host ""
    $settingsJson | ConvertTo-Json -depth 32 | set-content $ParameterFile
    Write-Host "==> Parameters file saved to: $ParameterFile"

    try {
        $DEPLOYMENT_NAME = $settingsJson.parameters.settings.value.demoName + "-Deployment"
        $BicepMainFile = Join-Path -Path $pwd -ChildPath "src" | Join-Path -ChildPath "main.bicep"

        if ($env:CI -eq "true") {

            az deployment sub what-if `
                --name $DEPLOYMENT_NAME `
                --location $settingsJson.parameters.settings.value.location `
                --template-file  "$BicepMainFile" `
                --parameters "$ParameterFile"
        }
        else {
            Write-Host ""
            Write-Information "==> Deploying resources..."

            az deployment sub create `
                --name $DEPLOYMENT_NAME `
                --location $settingsJson.parameters.settings.value.location `
                --template-file "$BicepMainFile" `
                --parameters "$ParameterFile" --no-wait

            Write-Host "==> Azure Deployment Started: https://portal.azure.com/#view/HubsExtension/DeploymentDetailsBlade/~/overview/id/%2Fsubscriptions%2F$($settingsJson.parameters.settings.value.tenantId)%2Fproviders%2FMicrosoft.Resources%2Fdeployments%2F$DEPLOYMENT_NAME"
            $dep = az deployment sub wait --created --name $DEPLOYMENT_NAME
            Write-Host ""
            Write-Host "==> Azure Deployment Complete"
            Write-Host ""
        }
        CreateFederatedCredentials

        PopulateGitHubRepo

        Write-Host ""
        Write-Host ""
        Write-Host "==> Your environment is ready to use! Please follow the instructions in the README.md file to complete the setup."
    }
    catch {
        Write-Warning "Failed to create environment `nMESSAGE: $($_.Exception.Message)"
        Write-Host ""
        Write-Host "==> Deleting Entra Apps, Service Principals and Federated Credential files..."
        foreach ($environmentType in $settingsJson.parameters.settings.value.environmentTypes) {
            $p = az ad app list --filter "id eq '$($environmentType.appRegistrationId)'" | ConvertFrom-Json
            if ($p.count -ne 0) {
                Write-Host "   ==> Deleting $($environmentType.name) Entra App"
                $a = az ad app delete --id $environmentType.appRegistrationId
            }
        }
        exit 1
    }
}
else {
    Write-Host ""
    Write-Host "==> Skipping Deployment, using existing environment information"

    $ParameterFile = Join-Path -Path $pwd -ChildPath "src" | Join-Path -ChildPath "parameters\main.parameters.json"

    if (Test-Path $ParameterFile) {
        CreateFederatedCredentials

        PopulateGitHubRepo

        Write-Host ""
        Write-Host ""
        Write-Host "Your environment is ready to use! Please follow the instructions in the README.md file to complete the setup."
    }
    else {
        Write-Host "No parameters file found. File is needed to continue. Exiting..."
        Write-Host ""
        Write-Host ""
    }
}
