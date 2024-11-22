using '../main.bicep'

param settings = {
  subscriptionId: '<POPULATED>'
  tenantId: '<POPULATED>'
  demoName: 'isaac-devbox-demo'
  location: 'eastus'
  createDevBox: true
  createADE: true
  githubPat: '<POPULATED>'
  tags: {
    delete: true
    envname: '<POPULATED>'
  }
  environmentTypes: [
    {
      name: 'Dev'
      subscriptionId: 'aa620457-dad1-4bff-abbd-7f10455b7cf6'
      servicePrincipalId: '<POPULATED>'
      appRegistrationId: '<POPULATED>'
      appClientId: '<POPULATED>'
    }
    {
      name: 'Test'
      subscriptionId: 'aa620457-dad1-4bff-abbd-7f10455b7cf6'
      servicePrincipalId: '<POPULATED>'
      appRegistrationId: '<POPULATED>'
      appClientId: '<POPULATED>'
    }
    {
      name: 'Prod'
      subscriptionId: 'aa620457-dad1-4bff-abbd-7f10455b7cf6'
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
      userId: '318abfb1-368f-4e42-8eb2-c1f13fa06729'
      name: 'Isaac Levin'
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
