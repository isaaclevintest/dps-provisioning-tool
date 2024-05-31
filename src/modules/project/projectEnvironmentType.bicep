// ---------
// Parameters
// ---------

param location string = resourceGroup().location

param name string

param subscriptionId string

param devCenterName string

param projectName string

param servicePrincipalId string

// Contributor
var creatorRoleAssignment = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@sys.description('Tags to apply to the resources')
param tags object = {}

// ---------
// Resources
// ---------

resource project 'Microsoft.DevCenter/projects@2023-01-01-preview' existing = {
  name: projectName
}

resource environmentType 'Microsoft.DevCenter/projects/environmentTypes@2023-01-01-preview' = {
  name: name
  parent: project
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    status: 'Enabled'
    #disable-next-line use-resource-id-functions
    deploymentTargetId: '/subscriptions/${subscriptionId}'
    creatorRoleAssignment: {
      roles: {
        '${creatorRoleAssignment}': {}
      }
    }
  }
  tags: tags
}


// Have to assign resources here in case the environmentType is in a different subscription
resource environmentTypeAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('ade', devCenterName, projectName, name, servicePrincipalId)
  properties: {
    // DevCenter Environments User
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18e40d4e-8d2e-438d-97e1-9528336e149c')
    principalId: servicePrincipalId
    principalType: 'ServicePrincipal'
  }
  scope: environmentType
}
