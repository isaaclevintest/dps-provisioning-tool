using '../main.bicep'

param settings = {
  subscriptionId: '<POPULATED>'
  tenantId: '<POPULATED>'
  demoName: 'isaac-demo'
  location: 'eastus'
  githubPat: '<POPULATED>'
  tags: {
    delete: true
    envname: '<POPULATED>'
  }
  environmentTypes: [
    {
      name: 'Dev'
      subscriptionId: 'e4476698-fa3e-410b-9b4d-d565e43c7dd1'
      servicePrincipalId: '<POPULATED>'
      appRegistrationId: '<POPULATED>'
      appClientId: '<POPULATED>'
    }
    {
      name: 'Test'
      subscriptionId: 'e4476698-fa3e-410b-9b4d-d565e43c7dd1'
      servicePrincipalId: '<POPULATED>'
      appRegistrationId: '<POPULATED>'
      appClientId: '<POPULATED>'
    }
    {
      name: 'Prod'
      subscriptionId: 'e4476698-fa3e-410b-9b4d-d565e43c7dd1'
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
      userId: 'b5e2d09a-b921-4b4f-883b-918cdc46a2b5'
      name: 'Test DPS'
      roles: [
        'ProjectAdmin'
        'DevBoxUser'
        'EnvironmentsUser'
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
