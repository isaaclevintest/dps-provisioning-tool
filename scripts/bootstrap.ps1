$login = az login --service-principal -u $Env:app_id -p $Env:sp_secret --tenant $Env:tenant_id

az account set --subscription $Env:subscription_id

$account = az account show

Write-Host "Logged into subscription $($($account | ConvertFrom-Json).name)"

az provider register --namespace Microsoft.DevCenter

$azdLogin = azd auth login --client-id "$Env:app_id" --tenant-id "$Env:tenant_id" --client-secret "$Env:sp_secret"

Write-Host "Logged into Azure Developer CLI"

gh auth status

if ($Env:action -eq "deploy" -and $Env:skip_deployment -eq "false") {
    #get org of logged in user with github cli using powershell
    $Env:Org = gh api /user | ConvertFrom-Json | Select-Object -ExpandProperty login

    $templateRepoExists = gh api "/repos/$Env:Org/platform-engineering-template" | ConvertFrom-Json

    #use github cli to create a fork if it does not exist
    if ($null -eq $templateRepoExists.id) {
        Write-Host "Forking the pe-template repository..."
        gh repo fork isaacrlevin/platform-engineering-template --default-branch-only --clone=false
        Start-Sleep -Seconds 1.0
    }

    #check if fork exists with github cli using powershell
    $eShopForkExists = gh api "/repos/$Env:Org/eShop" | ConvertFrom-Json

    #use github cli to create a fork if it does not exist
    if ($null -eq $eShopForkExists.id) {
        Write-Host "Forking the sample repository..."
        gh repo fork isaacrlevin/eShop --default-branch-only --clone=false
        Start-Sleep -Seconds 1.0
    }

    Write-Host "Adding branch rules to repository..."
    $GHRulesFile = Join-Path -Path $pwd -ChildPath "scripts" | Join-Path -ChildPath "gh-rules-api-body.json"
    #use github cli to protect the main branch
    $ghRules = gh api -X PUT "/repos/$Env:Org/eShop/branches/main/protection" --input $GHRulesFile
}