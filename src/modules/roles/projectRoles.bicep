// ---------
// Parameters
// ---------

@minLength(36)
@maxLength(36)
@description('The principal id of the User to assign permissions to the Project.')
param principalId string

@minLength(3)
@maxLength(63)
@description('The Project name.')
param projectName string

@allowed([ 'ProjectAdmin', 'DevBoxUser', 'EnvironmentsUser', 'Reader' ])
@description('The Role assignment to assign the user. Defaults to DevBoxUser')
param roles array = [
  'DevBoxUser'
  'EnvironmentsUser'
]

@allowed([ 'Device', 'ForeignGroup', 'Group', 'ServicePrincipal', 'User' ])
@description('The principal type of the assigned principal ID.')
param principalType string = 'User'

// ---------
// Variables
// ---------

var readerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
var projectAdminRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '331c37c6-af14-46d9-b9f4-e1909e1b95a0')
var devBoxUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '45d50f46-0b78-4001-a660-4198cbe8cd05')
var environmentsUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18e40d4e-8d2e-438d-97e1-9528336e149c')

// ---------
// Resources
// ---------

resource project 'Microsoft.DevCenter/projects@2023-01-01-preview' existing = {
  name: projectName
}

resource projectAssignmentIds 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for role in roles: {
  name: guid('project${role}${resourceGroup().id}${projectName}${principalId}')
  properties: {
    roleDefinitionId: role == 'ProjectAdmin' ? projectAdminRoleId : role == 'DevBoxUser' ? devBoxUserRoleId : role == 'EnvironmentsUser' ? environmentsUserRoleId : readerRoleId
    principalId: principalId
    principalType: principalType
  }
  scope: project
}]
