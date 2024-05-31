// ---------
// Parameters
// ---------

@description('Location for the Dev Box Definition. If none is provided, the resource group location is used.')
param location string = resourceGroup().location

@minLength(3)
@maxLength(63)
@description('Dev Box Definition name')
param name string

@minLength(3)
@maxLength(26)
@description('The resource ID of the DevCenter.')
param devCenterName string

@minLength(3)
@maxLength(63)
@description('The name of the gallery.')
param galleryName string = 'default'

@minLength(3)
@description('The name of the image in the gallery to use.')
param imageName string = 'vs-22-ent-win-11-m365'

@description('The version of the image to use. If none is provided, the latest version will be used.')
param imageVersion string = 'latest'

@description('The storage in GB used for the Operating System disk of Dev Boxes created using this definition.')
param storage string = '1024'

@description('The specs on the of Dev Boxes created using this definition. For example 8c32gb would create dev boxes with 8 vCPUs and 32 GB RAM.')
param compute string = '8-vcpu-32gb-ram'

@description('Tags to apply to the resources')
param tags object = {}

// ---------
// Resources
// ---------

resource devCenter 'Microsoft.DevCenter/devcenters@2023-01-01-preview' existing = {
  name: devCenterName
}

resource gallery 'Microsoft.DevCenter/devcenters/galleries@2023-01-01-preview' existing = {
  name: galleryName
  parent: devCenter
}

resource image 'Microsoft.DevCenter/devcenters/galleries/images@2023-01-01-preview' existing = {
  name: images[imageName]
  parent: gallery
}

resource definition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2023-01-01-preview' = {
  name: name
  parent: devCenter
  location: location
  properties: {
    sku: {
      name: skus[sku]
    }
    imageReference: {
      id: '${image.id}${versionSuffix}'
    }
    osStorageType: storageInput
    hibernateSupport: 'Enabled'
  }
  tags: tags
}

// ---------
// Outputs
// ---------

output definitionId string = definition.id
output definitionName string = definition.name

// ---------
// Variables
// ---------

var versionSuffix = (empty(imageVersion) || toLower(imageVersion) == 'latest') ? '' : '/versions/${imageVersion}'
var storageInput = 'ssd_${storage}gb'
var sku = '${compute}-${storage}-ssd'

var images = {
  // Windows 10
  'win-10-ent-20h2-os': 'microsoftwindowsdesktop_windows-ent-cpc_20h2-ent-cpc-os-g2'
  'win-10-ent-20h2-m365': 'microsoftwindowsdesktop_windows-ent-cpc_20h2-ent-cpc-m365-g2'
  'win-10-ent-21h2-os': 'microsoftwindowsdesktop_windows-ent-cpc_win10-21h2-ent-cpc-os-g2'
  'win-10-ent-21h2-m365': 'microsoftwindowsdesktop_windows-ent-cpc_win10-21h2-ent-cpc-m365-g2'
  'win-10-ent-22h2-os': 'microsoftwindowsdesktop_windows-ent-cpc_win10-22h2-ent-cpc-os'
  'win-10-ent-22h2-m365': 'microsoftwindowsdesktop_windows-ent-cpc_win10-22h2-ent-cpc-m365'

  // Windows 11
  'win-11-ent-21h2-os': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os'
  'win-11-ent-21h2-m365': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
  'win-11-ent-22h2-os': 'microsoftwindowsdesktop_windows-ent-cpc_win11-22h2-ent-cpc-os'
  'win-11-ent-22h2-m365': 'microsoftwindowsdesktop_windows-ent-cpc_win11-22h2-ent-cpc-m365'

  // Visual Studio 2019
  'vs-19-pro-win-10-m365': 'microsoftvisualstudio_visualstudio2019plustools_vs-2019-pro-general-win10-m365-gen2'
  'vs-19-ent-win-10-m365': 'microsoftvisualstudio_visualstudio2019plustools_vs-2019-ent-general-win10-m365-gen2'
  'vs-19-pro-win-11-m365': 'microsoftvisualstudio_visualstudio2019plustools_vs-2019-pro-general-win11-m365-gen2'
  'vs-19-ent-win-11-m365': 'microsoftvisualstudio_visualstudio2019plustools_vs-2019-ent-general-win11-m365-gen2'

  // Visual Studio 2022
  'vs-22-pro-win-10-m365': 'microsoftvisualstudio_visualstudioplustools_vs-2022-pro-general-win10-m365-gen2'
  'vs-22-ent-win-10-m365': 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win10-m365-gen2'
  'vs-22-pro-win-11-m365': 'microsoftvisualstudio_visualstudioplustools_vs-2022-pro-general-win11-m365-gen2'
  'vs-22-ent-win-11-m365': 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
}

var skus = {
  '8-vcpu-32gb-ram-256-ssd': 'general_i_8c32gb256ssd_v2'
  '8-vcpu-32gb-ram-512-ssd': 'general_i_8c32gb512ssd_v2'
  '8-vcpu-32gb-ram-1024-ssd': 'general_i_8c32gb1024ssd_v2'
  '8-vcpu-32gb-ram-2048-ssd': 'general_i_8c32gb2048ssd_v2'
  '16-vcpu-64gb-ram-254-ssd': 'general_i_16c64gb256ssd_v2'
  '16-vcpu-64gb-ram-512-ssd': 'general_i_16c64gb512ssd_v2'
  '16-vcpu-64gb-ram-1024-ssd': 'general_i_16c64gb1024ssd_v2'
  '16-vcpu-64gb-ram-2048-ssd': 'general_i_16c64gb2048ssd_v2'
  '32-vcpu-128gb-ram-512-ssd': 'general_i_32c128gb512ssd_v2'
  '32-vcpu-128gb-ram-1024-ssd': 'general_i_32c128gb1024ssd_v2'
  '32-vcpu-128gb-ram-2048-ssd': 'general_i_32c128gb2048ssd_v2'
}
