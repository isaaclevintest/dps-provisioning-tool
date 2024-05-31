// ---------
// Scopes
// ---------

targetScope = 'subscription'

// ---------
// Parameters
// ---------

@description('The identity principalId to assign role role')
param principalId string

@allowed([ 'Owner', 'Contributor', 'Reader' ])
@description('The Role assignment to assign the user. Defaults to Reader')
param role string = 'Reader'

@allowed([ 'Device', 'ForeignGroup', 'Group', 'ServicePrincipal', 'User' ])
@description('The principal type of the assigned principal ID.')
param principalType string = 'ServicePrincipal'

// ---------
// Variables
// ---------

var readerDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
var contributorDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var ownerDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')

// ---------
// Resources
// ---------

resource subAssignmentId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('${role}${subscription().subscriptionId}${principalId}')
  properties: {
    roleDefinitionId: role == 'Owner' ? ownerDefinitionId : role == 'Contributor' ? contributorDefinitionId : readerDefinitionId
    principalId: principalId
    principalType: principalType
  }
  scope: subscription()
}
