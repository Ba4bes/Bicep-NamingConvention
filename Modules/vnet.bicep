param vnetName string
param location string = resourceGroup().location
param addressPrefixes array

param subnets array = []

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
  }
}

output vnet object = virtualNetwork
output vnetId string = virtualNetwork.id
