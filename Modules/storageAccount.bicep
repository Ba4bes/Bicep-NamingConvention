param storageAccontName string
param location string = resourceGroup().location
@allowed([
  'StorageV2'
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
])
param kind string
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param sku string

param tags object = {}

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccontName
  location: location
  tags: tags
  kind: kind
  sku: {
    name: sku
  }
}
