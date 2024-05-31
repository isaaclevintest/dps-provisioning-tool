// ---------
// Scopes
// ---------

targetScope = 'subscription'

// ---------
// Resources
// ---------

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: name
  location: settings.location
  tags: settings.tags
}

param settings object
param name string
