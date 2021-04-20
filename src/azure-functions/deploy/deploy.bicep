
@minLength(2)
@maxLength(15)
param appName string

param location string = resourceGroup().location

var storageAccountName = '${appName}funcstg'
var appServicePlanName = '${appName}-func-asp'
var functionAppName = '${appName}-func'

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSku string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name:storageSku
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-10-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved:true
  }
}

resource functionApp 'Microsoft.Web/sites@2020-10-01' = {
  name:functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    httpsOnly:true
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          'name': 'FUNCTIONS_EXTENSION_VERSION'
          'value': '~3'
        }
        {
          'name': 'FUNCTIONS_WORKER_RUNTIME'
          'value': 'dotnet'
        }   
      ]
    }
  }
  dependsOn: [
    storageAccount
    appServicePlan
  ]
}
