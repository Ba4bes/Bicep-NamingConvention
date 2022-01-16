module names 'Modules/Conventions/NamingConvention.bicep' = {
  name: 'namingconvention'
  params: {
    environment: 'production'
    function: 'website'
    index: 1
    teamName: 'infra'
  }
}

module tags 'Modules/Conventions/Tagging.bicep' = {
  name: 'tagging'
  params: {
    CostCenter: 'Finance'
    environment: 'production'
    Owner: 'Cloud Competence Center'
  }
}

var subnetName = replace(names.outputs.resourceName, '[PH]', 'snet')

module vnet 'Modules/vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    tags: tags.outputs.Tags
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    vnetName: replace(names.outputs.resourceName, '[PH]', 'vnet')
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

module keyvault 'Modules/keyVault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    tags: tags.outputs.Tags
    keyVaultName: replace(names.outputs.resourceNameShort, '[PH]', 'kv')
    objectId: 'c1f426bd-ab87-4d9b-bfc4-e96a9bab4120'
  }
}

module sta 'Modules/storageAccount.bicep' = {
  name: 'staDeployment'
  params: {
    tags: tags.outputs.Tags
    kind: 'StorageV2'
    sku: 'Standard_LRS'
    storageAccontName: names.outputs.storageAccountName
  }
}

module vm 'Modules/vm.bicep' = {
  name: 'vmDeployment'
  params: {
    tags: tags.outputs.Tags
    nicName: replace(names.outputs.resourceName, '[PH]', 'nic')
    password: 'Welcome123'
    OsDiskName: replace(names.outputs.resourceName, '[PH]', 'osdisk')
    subnetId: '${vnet.outputs.vnetId}/subnets/${subnetName}'
    vmName: names.outputs.vmName
  }
}
