# Run Demo Generation Manually

If you would like to run the generation tool manually, you can follow this guide.

### Environment Prerequisites

- Powershell installed (will need to run the scripts, you can get Powershell for [Windows](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows), [MacOS](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos), and [Linux](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux))
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed on your local machine (if you don't the tool will install for you)
- [GitHub CLI](https://cli.github.com) installed on your local machine (needed to create repo variables and secrets)
- Create users in your Entra ID tenant to grant dev box and ADE access (these users MUST be full Users, not guests).
- [Docker Desktop](https://docs.docker.com/desktop/) installed

## Deployment Script

You can run the deployment script with this command from the root of this repo
```
.\run.ps1 "deploy"
```

> [!NOTE]
> If you have already provisioned the environment, and just want to create the federated identity and GitHub variables, you can skip the environment provisioning like so

```
.\run.ps1 "deploy" -skip $true
```

## Clean up Resources

You can run the delete script with this command from the root of this repo
```
.\run.ps1 "delete"
```