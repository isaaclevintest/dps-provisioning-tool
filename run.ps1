# if user passes in "deploy" as a parameter, then run the deploy.ps1 script
param (
    [string]$action,

    [bool]$skip = $false
)

# Bootstrap the environment
.\scripts\bootstrap.ps1

if ($action -eq "deploy") {
    .\scripts\deploy.ps1 -skip $skip
}
elseif ($action -eq "delete") {
    .\scripts\delete.ps1
}
else {
    Write-Host "Invalid action"
    exit 1
}