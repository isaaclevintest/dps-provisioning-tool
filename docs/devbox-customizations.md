### Test Microsoft Dev Box with Customizations

In this section, we will go over the steps needed to create a Microsoft Dev Box with customizations enabled.

#### View/Edit the devbox-customizations.yaml File

The provisioning tool enables the ability to create Microsoft Dev Boxes with [customizations](https://learn.microsoft.com/en-us/azure/dev-box/how-to-customize-dev-box-setup-tasks) which allows you to configure your developer environment beyond the image the Dev Box is created with. This is done with a customization file, that is authored in yaml.

There are samples available to test the customizations experience. When you ran the provisioning tool, a repo was forked into you GitHub account called `platform-engineering-template` which contains both Azure Deployment Environment Definitions as well as Dev Box Customizations tasks. You can review them as follows.

- Navigate to the `platform-engineering-template` repo in your GitHub account

![Screenshot of forked platform engineering template repo in the GitHub Portal](/media/pe-template.png)

- In that repo, there is a folder called `Dev Box Samples` that contains a handful of customization files that you can use for testing.

![Screenshot of Dev Box Samples folder in Platform Engineering Template repo](/media/dev-box-samples.png)

- You can use any of these samples when you create a Dev Box. The steps below uses the `Intelligent Apps` sample that installs both team-level customizations and user-level customizations

#### Create a Dev Box

To create a Dev Box, navigate to the [Microsoft Developer Portal](https://devportal.microsoft.com/)

![Screenshot of Dev Portal](/media/devportal-home.png)

- Click on the `New` Button and choose `New dev box`

![Screenshot of portion of Developer Portal with New Dev box circled in red](/media/new-devbox.png)

- On the right side there will be a `Add a dev box` form to populate. Add a name and select a project (project is populated from projects that exist in Dev Center)

![Screenshot of Dev Portal Add a dev box pane](/media/add-devbox-empty.png)

- Select a Dev Box pool (defined in project that was selected)

![Screenshot of Add a dev box pane with populated Dev box pool](/media/new-devbox-populated.png)

- From here, you can provide a customization file in 1 of 2 ways
  - Provide a repository that contains your customization file ([Read here](https://techcommunity.microsoft.com/t5/microsoft-developer-community/accelerate-developer-onboarding-with-the-configuration-as-code/ba-p/4062416) to learn more)
  - Upload a customization file (this tutorial follows this process)

- Click `Add customizations from file` and add the following `.yaml` files in this order (this files are in this repo [here](../Demos/DevBox/))
  - [`team.yaml`](../Demos/DevBox/team.yaml)
  - [`user.yaml`](../Demos/DevBox/team.yaml)

- The Dev Portal will validate your customization tasks and when that is complete, you can create the Dev Box

![Screenshot of Add a dev box pane with customization validation circled in red](/media/valid-customizations.png)

- Your dev box will start to be created and you can see it in Dev Portal

![Screenshot of dev box being created](/media/devbox-creating.png)

- You can also see the details of the customization by clicking `See details`

![Screenshot of Customization Details pane](/media/customization-details-creating.png)

- When your Dev Box is created, it will say `Running` and you can click `Customizations` to see those details

![Screenshot of Dev Box running in Dev Portal](/media/devbox-running.png)


![Screenshot of completed Customization details](/media/customization-details-done.png)

- You can than connect to your Dev Box either via RDP or in the browser

![Screenshot of Connect with the Remote Desktop Client](/media/connect-to-devbox.png)

- Once connected to your Dev Box, you can confirm that your customizations have been completed

![Screenshot of Dev Box with python verison, pip list, Ubuntu creation screen and VS Code with Extension Panes open](/media/connected-devbox.png
)

You can now use your Dev Box to showcase whatever you like, as it has been setup with everything you need.