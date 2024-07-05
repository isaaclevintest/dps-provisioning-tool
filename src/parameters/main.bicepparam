using '../main.bicep'

param settings = {
  subscriptionId: '<POPULATED>'
  tenantId: '<POPULATED>'
  demoName: 'vs-demo'
  location: 'eastus'
  githubPat: '<POPULATED>'
  tags: {
    delete: true
    envname: '<POPULATED>'
  }
  environmentTypes: [
    {
      name: 'Dev'
      subscriptionId: '7b8baf4b-6488-490d-aa2e-e8c5bf90dbe4'
      servicePrincipalId: '<POPULATED>'
      appRegistrationId: '<POPULATED>'
      appClientId: '<POPULATED>'
    }
    {
      name: 'Test'
      subscriptionId: '7b8baf4b-6488-490d-aa2e-e8c5bf90dbe4'
      servicePrincipalId: '<POPULATED>'
      appRegistrationId: '<POPULATED>'
      appClientId: '<POPULATED>'
    }
    {
      name: 'Prod'
      subscriptionId: '7b8baf4b-6488-490d-aa2e-e8c5bf90dbe4'
      servicePrincipalId: '<POPULATED>'
      appRegistrationId: '<POPULATED>'
      appClientId: '<POPULATED>'
    }
  ]
  networks: [
    {
      name: 'vnet'
      addressPrefixes: [ '10.4.0.0/16' ]
      subnetAddressPrefix: '10.4.0.0/24' // 250 + 5 Azure reserved addresses
      location: 'eastus'
    }
    {
      name: 'vnet-firewall'
      addressPrefixes: [ '10.5.0.0/16' ]
      subnetAddressPrefix: '10.5.0.0/24'
      location: 'eastus'
    }
    {
      name: 'vnet'
      addressPrefixes: [ '10.6.0.0/16' ]
      subnetAddressPrefix: '10.6.0.0/24' // 250 + 5 Azure reserved addresses
      location: 'westus3'
    }
    {
      name: 'vnet-paw'
      addressPrefixes: [ '10.7.0.0/16' ]
      subnetAddressPrefix: '10.7.0.0/24' // 250 + 5 Azure reserved addresses
      location: 'westus3'
    }
  ]
  devBoxDefs: [
    {
      name: 'Backend-Dev-Def'
      compute: '8-vcpu-32gb-ram'
      storage: '1024'
      galleryName: 'default'
      imageName: 'vs-22-ent-win-11-m365'
    }
    {
      name: 'Frontend-Dev-Def'
      compute: '8-vcpu-32gb-ram'
      storage: '1024'
      galleryName: 'default'
      imageName: 'vs-22-ent-win-11-m365'
    }
  ]
  userRoles: [
    {
      userId: '6d4c7075-5d3c-475b-a2c0-392ee50730a7'
      name: 'Isaac Levin'
      roles: [
        'ProjectAdmin'
        'DevBoxUser'
        'EnvironmentsUser'
      ]
    }
    {
      userId: '90cd39f2-7fa1-4369-b591-6355d6e98f20'
      name: 'Anna Soracco'
      roles: [
        'DevBoxUser'
      ]
    }
  ]
  catalog: {
    name: 'Platform-Engineering-Template'
    gitHubOrg: '<POPULATED>'
    gitHubRepo: 'platform-engineering-template'
    catalogItem: 'Aspire'
    branch: 'main'
    path: '/Environments'
  }
}
