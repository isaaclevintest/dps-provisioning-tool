// ---------
// Parameters
// ---------

@description('Location of the Pool. If none is provided, the resource group location is used.')
param location string = resourceGroup().location

@minLength(3)
@maxLength(63)
@description('Name of the Pool')
param name string

@minLength(3)
@maxLength(63)
@description('Name of the Project')
param projectName string

@minLength(3)
@maxLength(63)
@description('Name of a Dev Box definition in parent Project of this Pool')
param devBoxDefinitionName string

@allowed([ 'Disabled', 'Enabled' ])
@description('Indicates whether owners of Dev Boxes in this pool are added as local administrators on the Dev Box. Default is Enabled')
param localAdministrator string = 'Enabled'

@description('Tags to apply to the resources')
param tags object = {}

param vnets array

param demoName string

// ---------
// Resources
// ---------

resource project 'Microsoft.DevCenter/projects@2023-01-01-preview' existing = {
  name: projectName
}

resource pool 'Microsoft.DevCenter/projects/pools@2023-01-01-preview' = [for vnet in vnets: if (!contains(vnet.name, 'paw') &&!contains(vnet.name, 'firewall') ) {
  name: '${vnet.name}-${devBoxDefinitionName}-pool'
  parent: project
  location: location
  properties: {
    devBoxDefinitionName: devBoxDefinitionName
    licenseType: 'Windows_Client'
    localAdministrator: localAdministrator
    networkConnectionName: vnet.name
  }
  tags: tags
}]
