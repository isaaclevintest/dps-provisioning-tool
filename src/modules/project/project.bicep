// ---------
// Parameters
// ---------

@sys.description('Location of the Project. If none is provided, the resource group location is used.')
param location string = resourceGroup().location

@minLength(3)
@maxLength(26)
@sys.description('Name of the Project')
param name string
param description string = ''

param devCenterName string

param createDevBox bool

param createADE bool

param userRoles array

@sys.description('Tags to apply to the resources')
param tags object = {}

param environmentTypes array

// ---------
// Resources
// ---------

resource devCenter 'Microsoft.DevCenter/devcenters@2023-01-01-preview' existing = {
  name: devCenterName
}

resource project 'Microsoft.DevCenter/projects@2023-01-01-preview' = {
  name: name
  location: location
  properties: {
    devCenterId: devCenter.id
    description: (!empty(description) ? description : null)
  }
  tags: tags
}

// ---------
// Modules
// ---------

module readerEnv '../roles/projectRoles.bicep' = [for environmentTypes in environmentTypes: if (createADE) {
  name: guid('roles', devCenterName, name, environmentTypes.servicePrincipalId)
  params: {
    principalId: environmentTypes.servicePrincipalId
    projectName: project.name
    principalType: 'ServicePrincipal'
    roles: [ 'Reader' ]
  }
}]

module user_Roles '../roles/projectRoles.bicep' = [for user in userRoles: {
  name: guid('roles', devCenterName, name, user.userId)
  params: {
    principalId: user.userId
    projectName: project.name
    roles: user.roles
  }
}]

module projectEnvTypes 'projectEnvironmentType.bicep' = [for envType in environmentTypes:if (createADE) {
  name: 'env-type-${name}-${envType.name}'
  params: {
    name: envType.name
    location: location
    projectName: project.name
    subscriptionId: envType.subscriptionId
    devCenterName: devCenterName
    servicePrincipalId: envType.servicePrincipalId
    tags: tags
  }
}]

// ---------
// Outputs
// ---------

output projectName string = project.name
