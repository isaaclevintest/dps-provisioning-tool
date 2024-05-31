> [!NOTE]
> The following steps walk through running the tool inside a Docker container inside GitHub Codespaces. You also have the ability to run the tool directly from you computer. To do that, review the [Run manually documentation](/docs/run-manually.md)

# Setup GitHub Codespaces

The most efficient way to run this tool is inside a Docker container in GitHub Codespace. This repository leverages [Dev Containers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers) to customize the environment where the tool will run. The customization file for Dev Containers is [devcontainer.json](/.devcontainer/devcontainer.json) and it installs the following tools and extensions

- [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/overview)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) with [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview)
- [Official Docker Extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
- [Official PowerShell Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)
- [Azure CLI Tools Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azurecli)
- [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
- [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)

To create a codespace, perform the following steps

- Fork this repository
![Screenshot of repository on GitHub.com with Fork repo button circled in red](/media/fork1.png)

After that, give your repository a name and click `Create fork`

![Screenshot of Create Fork Screen in GitHub.com](/media/fork2.png)
Once done, you will have your own version of the repo in your GitHub account

- Create codespace by clicking on the green `Code` button, clicking the `Codespaces` tab, and clicking the green `Create codespace on main` button.
![Screenshot of Github repository with create new codespace pane opened](/media/create-codespace.png)

- Once your codespace is created and finished configuration, you are ready to build the Docker image and run the tool in a Docker container.

## Build Docker Image

> [!NOTE]
> When you either create or attach to a codespace, Dev Container will build the Docker image, to save you from doing one step for environment provisioning. If you need to build the image manually, follow below.

The first step to running the tool inside a Docker container is to build the image that will eventually run inside the container. To do this, open up the command line wherever you want the tool to run. Navigate the root of the repository (whether you git cloned or are running in a codespace), and run the following.

```docker
# Build Docker Image
docker build -t dps-provision-tool -f Dockerfile .
```

This will create a container image with all the required prerequisites on it to provision your DPS environment.

## Create Docker Container

You have different options to create the docker container, two being using the docker cli and docker-compose.

## Environment Variables to Create Container

The docker image expects a handful of environment variables to be passed into it, those variables are:

  - subscription_id: Subscription ID of the Azure Subscription you want to deploy to.
  - app_id: The ID of the Service Principal created as part of prerequisites
  - tenant_id: The ID of the Entra ID tenant
  - sp_secret: The secret generated for the Service Principal as part of prerequisites
  - GITHUB_TOKEN: The Personal Access Token created for GitHub repo as part of prerequisites
  - action: Either "deploy" or "delete" to designate if you want to deploy or delete an environment
  - skip_deployment: Either "true" or "false" to designate if you want to deploy the resources to Azure (this is valuable if you only want to create federated credentials as well as GitHub environments)

## Parameters folder

The tool leverages a parameters file as mentioned above. In order to use the parameters file you updated with your configuration, you will need to mount a docker volume for the folder that contains the file.

## Docker CLI

One way to create the container is to use the [Docker CLI](https://docs.docker.com/reference/cli/docker/container/run/). To create an image using the CLI, run a command similar to below

```docker
# Create Docker Container using docker run
docker run -it - e subscription_id="${subscription_id}" -e app_id="${app_id}" -e tenant_id="${tenant_id}" -e sp_secret="${sp_secret}" -e GITHUB_TOKEN="${GITHUB_TOKEN}" -e action="${deploy}" -e skip_deployment="${skip_deployment}" -v  ${paramFolder}:/src/parameters/ dps-provision-tool
```

## Docker Compose

Another way to create a container is to use [docker-compose](https://docs.docker.com/compose/) which uses a `.yml` file to define the container. There is a template for the [docker-compose.yml](/docker-compose.yml) file to review.

```yml
---
services:
  dps-provision-tool:
    image: dps-provision-tool
    container_name: dps-provision-tool
    environment:
      # Update to your Azure subscription, service principal, github pat and other details
      - subscription_id=
      - app_id=
      - tenant_id=
      - sp_secret=
      - GITHUB_TOKEN=
      - action=deploy
      - skip_deployment=false
    volumes:
      # Update to your parameters folder path
      - ./src/parameters/:/src/parameters
```

After you update the .yml file, you can use the docker compose cli to create the container like below

```docker
# Create Docker Container using docker-compose
docker-compose -f docker-compose.yml up -d
```

This kicks off the deployment inside a docker container. To learn what happens, go back to the main [README](/README.md)

## Clean up Resources

Similar to creating a new environment, you can delete an environment as well. The only difference is changing the `action` environment variable, either through the docker cli or docker-compose

### Docker CLI


```docker
# Create Docker Container using docker run
docker run -it - e subscription_id="${subscription_id}" -e app_id="${app_id}" -e tenant_id="${tenant_id}" -e sp_secret="${sp_secret}" -e GITHUB_TOKEN="${GITHUB_TOKEN}" -e action="delete" -e skip_deployment="${skip_deployment}" -v  ${paramFolder}:/src/parameters/ dps-provision-tool
```

### Docker Compose

```yml
---
services:
  dps-provision-tool:
    image: dps-provision-tool
    container_name: dps-provision-tool
    environment:
      # Update to your Azure subscription, service principal, github pat and other details
      - subscription_id=
      - app_id=
      - tenant_id=
      - sp_secret=
      - GITHUB_TOKEN=
      - action=delete
      - skip_deployment=false
    volumes:
      # Update to your parameters folder path
      - \src\parameters\:/src/parameters/
```

After you update the .yml file, you can use the docker compose cli to create the container like below

```docker
# Create Docker Container using docker-compose
docker-compose -f docker-compose.yml up -d
```

This runs a environment deletion script [delete.ps1](/scripts/delete.ps1) that will remove all the created resources done by the deploment script. It is essential you have proper tags applied to your resources to avoid deleting other resources in the subscription. By default, there are tags located in [main.bicepparam](/bicep-parameters-schema.md)