# Azure Deployment Environment Provisioning via CI/CD

The tool configures Azure Deployment Environments to provision new versions of the environment when new branches are published. This is done via CI/CD with GitHub Actions You can validate that by following these steps.

## Clone the repository

1. In your terminal, cd into a folder where you'd like to clone your repository locally.

2. Clone the repository. Be sure to replace `< Organization/Repository >` in the following command with your GitHub organization and repository name.

    ```azurecli
    git clone https://github.com/< Organization/Repository >.git
    ```

3. Navigate into the cloned directory.

    ```azurecli
    cd Repository
    ```

4. Next, create a new branch and publish it remotely.

    ```azurecli
    git checkout -b feature1
    ```

    ```azurecli
    git push -u origin feature1
    ```

    A new environment is created in Azure specific to this branch.

5. Go to [GitHub](https://github.com) and navigate to the main page of your newly created repository.

6. Under your repository name, select **Actions**.

   You should see a new Create Environment workflow running.

## Make a change to the code

1. Open the locally cloned repo in VS Code.

1. In the repository, make a change to any file.

1. Save your change.

## Push your changes to update the environment

1. Stage your changes and push to the `feature1` branch.

   ``` azurecli
   git add .
   git commit -m '<commit message>'
   git push
   ```

1. On your repository's **Actions** page, you see a new Update Environment workflow running.

## Create a pull request

1. Create a pull request on GitHub.com `main <- feature1`.

1. On your repository's **Actions** page, you see a new workflow is started to create an environment specific to the PR using the Test environment type.

## Merge the PR

1. On [GitHub](https://github.com), navigate to the pull request you created.

1. Merge the PR.

    Your changes are published into the production environment, and the branch and pull request environments are deleted.