# Developer Productivity Services End to End Demo Environment Generation

This repo is the first iteration of the process to generate an environment to demo Developer Productivity Services (Microsoft Dev Box and Azure Deployment Environments). To see the tool in action, please take a look at this [end to end video](http://aka.ms/dps/demogen/video).

## Get an Environment

In order to run this demo generation tool, you need access to an Entra ID tenant where you are a tenant admin. To learn how to get an environment, read the [tenant requirements doc](/docs/tenant-requirements.md).

## Setup Repo to Run GitHub Action

- Fork this repository
![Screenshot of repository on GitHub.com with Fork repo button circled in red](/media/fork1.png)

After that, give your repository a name and click `Create fork`

![Screenshot of Create Fork Screen in GitHub.com](/media/fork2.png)
Once done, you will have your own version of the repo in your GitHub account

## Creating Environment

The environment generation tool takes advantage of Docker to run all the necessary scripts and deployments to have a fully functioning Developer Productivity Services environment. In order to run the tool, please complete the following prerequisites

### Environment Prerequisites

- [Create users in your Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/how-to-create-delete-users#create-a-new-user) tenant to grant dev box and ADE access (these users MUST be full Users, not guests).
- [Create Service Principal](/docs/create-sp.md) in Entra ID for tool
- Create GitHub Personal Access TokenConfigure GitHub Repository and Create Personal Access Token ([guide here](/docs/setup-github-repo.md))

## Setting up Environment to run the tool

This tool is optimized to run inside GitHub Actions Runner triggered by manually running. This runner builds and runs a Docker container. You can also run this tool as a container inside a GitHub Codespace(review this [doc](/docs/codespaces.md) to learn more), running the scripts manually inside a codespace, Windows, WSL or anywhere you can run a Docker container. Regardless of where you run the tool, you will need to populate a few files with values obtained from creating a service principal or GitHub Personal Access Token.

### Add base parameters for environment

The environment generation tool relies Azure CLI, Azure Bicep and the GitHub CLI to build the environment. Azure Bicep relies on a parameter file called [`main.bicepparam`](/src/parameters/main.bicepparam) which will need to populated. For more information about the schema of the parameter file, see the [readme](/bicep-parameters-schema.md). All required variables are labeled `<TODO>` whereas variables that are populated by the script are labeled `<POPULATED>`. You can also customize this parameters file anyway you like with configuration that best suits your needs.

### Add Github Repository Secrets for GitHub Actions

In order for the tool to run inside a GitHub Action Workflow, the repository needs a handful of secrets added to it. You can reach the secrets page of your repo by navigating to `Settings --> Secrets and variables --> Actions`. From there, populate the following Repository Secrets

  - SUBSCRIPTION_ID: Subscription ID of the Azure Subscription you want to deploy to.
  - APP_ID: The ID of the Service Principal created as part of prerequisites
  - TENANT_ID: The ID of the Entra ID tenant
  - SP_SECRET: The secret generated for the Service Principal as part of prerequisites
  - GH_TOKEN: The Personal Access Token created for GitHub repo as part of prerequisites

![Screenshot of repository secrets page for repo on GitHub.com](/media/action-secrets.png)

## Dispatching GitHub Action to Run Tool

To run the rool, you can take advantage of the `workflow_dispatch` functionality of GitHub Actions. This allows you to trigger a workflow and provide some inputs. To do that, follow the below steps.

1. Navigate to the `Actions` page of the repo

![Screenshot of actions for repo on GitHub.com](/media/actions-page.png)

2. Click the `Create Developer Productivity Services Environment` Action from the pane on the left.

3. Click the `Run workflow` button on the right of the page.

4. There you will be prompted with inputs for the workflow. If you are creating an environment, leave `Skip Azure Resources Deployment...` false and leave `Run ID of previous...` blank, and click `Run workflow`

![Screenshot of running GitHub Action screen workflow dialog for GitHub Actions on GitHub.com](/media/run-workflow.png)

5. Once your workflow has started, you can see it running, click into it, and see the logs

![Screenshot of running GitHub Action screen on GitHub.com](/media/running-action1.png)

![Screenshot of running GitHub Action Summary screen on GitHub.com](/media/running-action2.png)

![Screenshot of running GitHub Action logs screen on GitHub.com](/media/action-logs.png)

6. If you leave this page, and eventually come back to the Actions page, you will see the Action has completed, allowing you to see the Summary as well as Logs.

![Screenshot of running GitHub Action screen on GitHub.com](/media/completed-action1.png)

![Screenshot of running GitHub Action Summary screen on GitHub.com](/media/completed-action2.png)

![Screenshot of running GitHub Action logs screen on GitHub.com](/media/completed-action-logs.png)

## What Does this Tool Do?

The tool leverages scripting and Azure Bicep to complete the following tasks:

- Forks and configures ["Demo" GitHub Repo](https://github.com/isaacrlevin/eShop) that will be deployed via Azure Deployment Environments(more info [here](/docs/setup-github-repo.md))
- Populates all variables in [`main.bicepparam`](/src/parameters/main.bicepparam) labeled `<POPULATED>`
- Using ARM deploys the following resources to the provided Azure subscription
  - Dev Center
  - Virtual Networks
  - Dev Center Network Connections
  - Dev Center Project
  - Azure Key Vault
  - Dev Box Definitions
  - Dev Center Project Pools
- Creates App Registrations and Service Principals to be able to configure Azure Deployment Environments generation via CI/CD in GitHub Actions. Walkthrough of process outlined [here]([Learn Module](https://learn.microsoft.com/en-us/azure/deployment-environments/tutorial-deploy-environments-in-cicd-github#51-generate-deployment-identities)).
- [Creates federated identity credentials](https://learn.microsoft.com/en-us/graph/api/application-post-federatedidentitycredentials?view=graph-rest-beta&preserve-view=true) for the Environments that were created.
- Creates GitHub repository environments based on the values in the parameters file using the GitHub CLI
- Adds GitHub repository variables based on values in the parameters file using the GitHub CLI
- Adds GitHub environment secrets to connect federated credentials to Azure

## Post Deployment Scenarios

After the environment is provisioned, you are now able to demo different scenarios in Developer Productivity Services.

### Azure Deployment Environment Provisioning via CI/CD

This tool enables you to showcase being able to demo app environment resource provisioning via CI/CD with GitHub Actions. Follow the [walkthrough](/docs/ade-demo.md) here to do that.

### Dev Box Customizations

This tool also enables you to showcase Dev Box customizations. Follow the walkthrough [here](/docs/devbox-customizations.md) to do that.

To learn more about Dev Box Customizations, read the [introductory blog post](https://techcommunity.microsoft.com/t5/microsoft-developer-community/accelerate-developer-onboarding-with-the-configuration-as-code/ba-p/4062416)

## Contributing
This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the Microsoft Open Source Code of Conduct. For more information see the Code of Conduct FAQ or contact opencode@microsoft.com with any additional questions or comments.

## Trademarks
This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft's Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.