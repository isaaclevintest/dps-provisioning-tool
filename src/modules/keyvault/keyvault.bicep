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

// ---------
// Variables
// ---------

// clean up the keyvault name an add a suffix to ensure it's unique
var keyVaultNameStart = replace(replace(replace(toLower(trim(name)), ' ', '-'), '_', '-'), '.', '-')
var keyVaultNameAlmost = length(keyVaultNameStart) <= 24 ? keyVaultNameStart : take(keyVaultNameStart, 24)
var unique = substring(uniqueString(resourceGroup().id), 1, 3)
var keyVaultName = '${keyVaultNameAlmost}-${unique}-kv'

// ---------
// Resources
// ---------

resource devCenter 'Microsoft.DevCenter/devcenters@2023-01-01-preview' existing = {
  name: '${name}-devcenter'
}

// create a key vault
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
  tags: tags
}

// assign dev center identity secrets officer role on key vault
resource keyVaultAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('kvsecretofficer${resourceGroup().id}${keyVaultName}${name}')
  properties: {
    principalId: devCenter.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
  }
  scope: keyVault
}

// add the github pat token to the key vault
resource githubPatSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'github-pat'
  parent: keyVault
  properties: {
    value: githubPat
    attributes: {
      enabled: true
    }
  }
  tags: tags
}

output githubPatSecret object = githubPatSecret
