// ---------
// Parameters
// ---------

@maxLength(63)
@description('Name of the attached Network Connection in DevCenter. If not provided, the Network Connection name is used.')
param name string = ''

@minLength(3)
@maxLength(26)
@description('Name of the DevCenter.')
param devCenterName string

@minLength(121)
@description('The resource ID of the Network Connection.')
param networkConnectionId string

// ---------
// Variables
// ---------

// Use the network connection name if no name was provided
var attachName = !empty(name) ? name : last(split(networkConnectionId, '/'))

// ---------
// Resources
// ---------

resource devCenter 'Microsoft.DevCenter/devcenters@2023-01-01-preview' existing = {
  name: devCenterName
}

resource networkAttach 'Microsoft.DevCenter/devcenters/attachednetworks@2023-01-01-preview' = {
  name: attachName
  parent: devCenter
  properties: {
    networkConnectionId: networkConnectionId
  }
}
