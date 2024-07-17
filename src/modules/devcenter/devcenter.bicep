// ---------
// Parameters
// ---------

@description('Location of the Dev Center. If none is provided, the resource group location is used.')
param location string = resourceGroup().location

@minLength(3)
@maxLength(26)
@description('Name of the Dev Center')
param name string

@secure()
@description('Personal Access Token from GitHub with the repo scope')
param githubPat string

@description('Tags to apply to the resources')
param tags object = {}

param createDevBox bool

param createADE bool

param environmentTypes array

param catalog object

// ---------
// Resources
// ---------

resource devCenter 'Microsoft.DevCenter/devcenters@2023-01-01-preview' = {
  name: '${name}-devcenter'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
}

// create the eShop catalog
resource catalogResource 'Microsoft.DevCenter/devcenters/catalogs@2023-01-01-preview' = {
  parent: devCenter
  name: catalog.name
  properties: {
    gitHub: {
      uri: 'https://github.com/${catalog.gitHubOrg}/${catalog.gitHubRepo}.git'
      branch: catalog.branch
      //path: catalog.path
      secretIdentifier: keyVault.outputs.githubPatSecret.properties.secretUri
    }
  }
}

// create dev box customizations catalog
resource customizationsCatalogResource 'Microsoft.DevCenter/devcenters/catalogs@2023-01-01-preview' = {
  parent: devCenter
  name: 'default-devcenter-catalog'
  properties: {
    gitHub: {
      uri: 'https://github.com/microsoft/devcenter-catalog.git'
      branch: 'main'
    }
  }
}

// create the dev center level environment types
resource envTypes 'Microsoft.DevCenter/devcenters/environmentTypes@2023-01-01-preview' = [for envType in environmentTypes: if (createADE) {
  parent: devCenter
  name: envType.name
  properties: {}
}]

// ---------
// Modules
// ---------

module keyVault '../keyvault/keyvault.bicep' = {
  name: guid('kv${name}')
  params: {
    githubPat: githubPat
    location: location
    name: name
    tags: tags
  }
  dependsOn: [ devCenter ]
}

// assign dev center identity owner role on subscription
module subscriptionAssignment '../roles/subscriptionRoles.bicep' = {
  name: guid('owner${name}${subscription().subscriptionId}')
  scope: subscription()
  params: {
    principalId: devCenter.identity.principalId
    role: 'Owner'
    principalType: 'ServicePrincipal'
  }
}

// assign dev center identity owner role on each environment type subscription
module envSubscriptionsAssignment '../roles/subscriptionRoles.bicep' = [for envType in environmentTypes: if (createADE) {
  name: guid('owner${name}${envType.name}')
  scope: subscription(envType.subscriptionId)
  params: {
    principalId: devCenter.identity.principalId
    role: 'Owner'
    principalType: 'ServicePrincipal'
  }
}]

// ---------
// Outputs
// ---------

output devCenterId string = devCenter.id
output devCenterName string = devCenter.name
output devCenterIdentity string = devCenter.identity.principalId
