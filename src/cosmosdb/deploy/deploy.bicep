
@minLength(3)
@maxLength(15)
param appName string

param location string = resourceGroup().location

var cosmosAccountName = '${appName}-cosmos'
var cosmosDatabaseName = 'RequestDB'
var cosmosContainerName = 'Requests'

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2020-03-01' = {
  name: cosmosAccountName
  location: location
  kind:'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    consistencyPolicy: {
      defaultConsistencyLevel:'Eventual'
    }
    locations: [
      {
        locationName: 'eastus'
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
  }
}

resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2020-03-01' = {
  name: '${cosmosAccount.name}/${cosmosDatabaseName}'
  properties:{
    resource: {
      id: cosmosDatabaseName
    }
    options: {
      throughput: '400'
    }
  }
  dependsOn: [
    cosmosAccount
  ]
}

resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2020-03-01' = {
  name: '${cosmosDatabase.name}/${cosmosContainerName}'
  properties: {
    resource: {
      id: cosmosContainerName
      partitionKey:{
        paths: [
          '/model'
        ]
        kind:'Hash'
      }
    }
    options:{
      throughput: '400'
    }
  }
  dependsOn:[
    cosmosDatabase
  ]
}


