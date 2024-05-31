# Entra ID Tenant Requirements

### Useful Links
- [Accelerate Developer Productivity Presentation](https://microsoft.sharepoint.com/:p:/r/teams/MicrosoftGitHubGTMNinjas/_layouts/15/doc2.aspx?sourcedoc=%7B6595071E-1282-45DD-9F2E-5CA294680FA9%7D&file=Accelerate%20Developer%20Productivity%20OBS%20L100%20pitch%20deck(WIP).pptx&action=edit&mobileredirect=true&DefaultItemOpen=1&share=IQEeB5VlghLdRZ8uXKKUaA-pAYjzY7Iu-I8z1nfjXYmiOq4&ovuser=72f988bf-86f1-41af-91ab-2d7cd011db47%2Cv-isaaclevin%40microsoft.com&clickparams=eyJBcHBOYW1lIjoiVGVhbXMtRGVza3RvcCIsIkFwcFZlcnNpb24iOiI0OS8yMzA4MjAwMDkzMSIsIkhhc0ZlZGVyYXRlZFVzZXIiOmZhbHNlfQ%3D%3D)
- [MCAPS Hybrid Subscription Information](https://dev.azure.com/servicesdocs/DevOps/_wiki/wikis/AzureInWCB%20wiki/32334/Hybrid-Subscription)
- [Azure Internal Billing Registration (AIRS)](http://aka.ms/airs)
- [CDX Create a Tenant](https://cdx.transform.microsoft.com/my-tenants/create-tenant)


**NOTE: There are 2 different ways to create a demo subscription to be able to generate the end-to-end experience. If you are in the MCAPS(Microsoft Customer and Partner Solutions) organization, you should create an external MCAPS environment. If you are not in the MCAPS org, you will need to create a CDX(Microsoft Customer Digital Experiences) Tenant, as well as create an Extenal AIRS subscription and link them together.**

## Setup MCAPS Environment

In order to demo the end-to-end experience for Developer Productivity Services, you will need to create an environment to do so. Due to many circumstances, you cannot use an internal M365 tenant to do this, as there are quotas and limits on services the experience is dependent on. To do that, follow the steps outlined [here](https://dev.azure.com/OneCommercial/NoCode/_wiki/wikis/NoCode.wiki/12/Hybrid-Subscription) paying attention to selecting "External Subscription"

![MCAPS Option](/media/mcaps.png)

## Non-MCAPS Environment Setup

### CDX Tenant Creation
If you are not in the MCAPS organization, you will not be able to use the above process to create an environment to demo Microsoft Dev Box and Azure Deployment Environments. You can however create a temporary M365 tenant that is external to the MSFT tenant via [CDX](CDX Link). To create an environment via CDX, go to the CDX portal.

- Navigate to [`My Environments`](https://cdx.transform.microsoft.com/my-tenants)
- Click `Create Tenant`

![CDX Create Tenant](/media/cdx-environments.png)

- For period select `1 year`

![CDX Select Period](/media/cdx-create-period.png)

- Select tenant location
- Choose `Create Tenant` for *Microsoft 365 Enterprise Demo Content* and accept and continue

![CDX Create Tenant](/media/cdx-create.png)
- Once completed, you will see a Tenant Summary screen, with Name, Email and Password for admin account. Save these off somewhere.

![CDX Create Tenant](/media/cdx-create-summary.png)

### Internal Azure Subscription

Once you have an external MSFT tenant, you will need to create an AIRs subscription that is linked to an external tenant. To do that, you will need to create a new Azure Internal Billing Registration

- Navigate to [Azure Internal Billing Registration](https://azuremsregistration.microsoft.com/Default.aspx) page
- Click `New Registration`

![CDX Create Tenant](/media/airs.png)
- Populate `alias`, `Full name`, `Manager`, `Business Group`
- In Account Information section, select `External Test Account` for *Account Type*, and CDX account admin email for *Account Owner ID*
- Provide `Sponorship Start/End Date`,
- Work with manager to obtain `Monetary Usage Cap Amount`, `PC Code for cross charging`, `PFAM for cross charging`, `Program Name`, `Paid Support`, `PC Code for cross charging Paid Support`, `Program Name for Paid Support`
- Provide Finance and Budget approver alias, as well as contact information and click `Submit`

There is a workflow to approve new Azure subscriptions. When that is complete, you should have a new Azure subscription added to your CDX tenant. You can verify this by going to the Azure portal and logging in with your CDX admin account. At this time, you are now ready to create the Advanced Developer Productivty environment.