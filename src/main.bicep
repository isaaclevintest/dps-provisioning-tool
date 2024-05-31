// ---------
// Scopes
// ---------

targetScope = 'subscription'

// ---------
// Parameters
// ---------

param settings object

// ---------
// Variables
// ---------

var resourceGroups = [
  '${settings.demoName}-network'
  '${settings.demoName}-devcenter'
]

// ---------
// Modules
// ---------

module resources 'modules/resources/resources.bicep' = [for resourceGroup in resourceGroups: {
  scope: subscription()
  name: 'Create-${resourceGroup}-ResourceGroup'
  params: {
    name: resourceGroup
    settings: settings
  }
}]

// Dev Center
module devCenter 'modules/devcenter/devcenter.bicep' = {
  scope: az.resourceGroup('${settings.demoName}-devcenter')
  name: 'Create-DevCenter'
  params: {
    #disable-next-line BCP334 BCP335
    name: settings.demoName
    githubPat: settings.githubPat
    environmentTypes: settings.environmentTypes
    location: settings.location
    catalog: settings.catalog
    tags: settings.tags
  }
  dependsOn: [ resources ]
}

// Projects
module project_eShop './modules/project/project.bicep' = {
  scope: az.resourceGroup('${settings.demoName}-devcenter')
  name: 'Create-Project'
  params: {
    devCenterName: devCenter.outputs.devCenterName
    name: '${settings.demoName}-project'
    description: '.NET 8 reference application shown at .NET Conf 2023 featuring .NET Aspire'
    environmentTypes: settings.environmentTypes
    location: settings.location
    userRoles: settings.userRoles
    tags: settings.tags
  }
  dependsOn: [ devCenter ]
}

// Networks

var vnets = [for network in settings.networks: {
  name: '${settings.demoName}-${network.name}-${network.location}'
  addressPrefixes: network.addressPrefixes
  subnetAddressPrefix: network.subnetAddressPrefix
  location: network.location
}]

module network './modules/network/network.bicep' = [for network in vnets: {
  scope: az.resourceGroup('${settings.demoName}-network')
  name: 'Create-${network.name}-${network.location}-Network'
  params: {
    #disable-next-line BCP334 BCP335
    name: network.name
    addressPrefixes: network.addressPrefixes
    subnetAddressPrefix: network.subnetAddressPrefix
    devCenterId: devCenter.outputs.devCenterId
    location: network.location
    tags: settings.tags
  }
  dependsOn: [ resources ]
}
]

// DevBox Definitions
module definitions './modules/devcenter/devboxDefinition.bicep' = [for def in settings.devBoxDefs: {
  scope: az.resourceGroup('${settings.demoName}-devcenter')
  name: 'Create-${def.name}-Dev-Box-Definition'
  params: {
    name: def.name
    compute: def.compute
    storage: def.storage
    #disable-next-line BCP334 BCP335
    devCenterName: devCenter.outputs.devCenterName
    galleryName: def.galleryName
    imageName: def.imageName
    location: settings.location
    tags: settings.tags
  }
  dependsOn: [ devCenter ]
}]

// DevBox Pools
module pool_backend_eastus './modules/project/pool.bicep' = [for devBoxDef in settings.devBoxDefs: {
  scope: az.resourceGroup('${settings.demoName}-devcenter')
  name: 'Create-${devBoxDef.name}-Pools'
  params: {
    name: devBoxDef.name
    demoName: settings.demoName
    #disable-next-line BCP334 BCP335
    devBoxDefinitionName: devBoxDef.name
    #disable-next-line BCP334 BCP335
    vnets: vnets
    location: settings.location
    #disable-next-line BCP334 BCP335
    projectName: project_eShop.outputs.projectName
    tags: settings.tags
  }
  dependsOn: [ definitions, network ]
}]

// // Sub CI Roles

// // CI identity must be assigned subscription reader role to all environment type subscriptions
// // otherwise it has to log out and log in again to see the environment type subscriptions
// module envReaderAssignmentIds './modules/roles/subscriptionRoles.bicep' = [for envType in settings.environmentTypes: {
//   name: 'Add-RA-for-CI-to-${envType.name}'
//   scope: subscription(envType.subscriptionId)
//   params: {
//     principalId: envType.ciPrincipalId
//     role: 'Reader'
//     principalType: 'ServicePrincipal'
//   }
// }]
