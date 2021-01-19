#!/bin/bash

LOCATION='eastus'
NAMEPREFIX=five$RANDOM
RESOURCEGROUP='five-azure-services-for-devs'

# Create resource group 
az group create --name $RESOURCEGROUP --location $LOCATION

################################
### Create App Service (Web App)
################################

# Step #1 - Create App Service Plan - S1 is smallest with deployment slots
az appservice plan create \
    --name "${NAMEPREFIX}-web-asp" \
    --resource-group $RESOURCEGROUP \
    --location $LOCATION \
    --sku S1 

# Step #2 - Create a Web Application
az webapp create \
    --name "${NAMEPREFIX}-web" \
    --resource-group $RESOURCEGROUP \
    --plan "${NAMEPREFIX}-web-asp" \
    --runtime "DOTNETCORE|3.1" 

# Step #3 - Create a Deployment Slot (Staging)
az webapp deployment slot create \
    --name "${NAMEPREFIX}-web" \
    --resource-group $RESOURCEGROUP \
    --slot staging 


################################
### Create Function App
################################

# Step #1 - Create a Storage Account
az storage account create \
  --name "${NAMEPREFIX}funcstg" \
  --location $LOCATION \
  --resource-group $RESOURCEGROUP \
  --sku Standard_LRS

az functionapp create \
  --name "${NAMEPREFIX}-func" \
  --storage-account "${NAMEPREFIX}funcstg" \
  --consumption-plan-location $LOCATION \
  --resource-group $RESOURCEGROUP \
  --functions-version 3
  --disable-app-insights


################################
### Create Service Bus
################################

# Step #1 - Create Service Bus Namespace
az servicebus namespace create \
    --name "${NAMEPREFIX}SBNS" \
    --resource-group $RESOURCEGROUP \
    --location $LOCATION

# Step #2 - Create Queue
az servicebus queue create \
    --resource-group $RESOURCEGROUP \
    --namespace-name "${NAMEPREFIX}SBNS" \
    --name Requests

#3 step #3 - Retrieve the Connection string used in the Function App

SBCONNECTIONSTRING=$(az servicebus namespace authorization-rule keys list \
                        --resource-group $RESOURCEGROUP \
                        --namespace-name "${NAMEPREFIX}SBNS" \
                        --name RootManageSharedAccessKey \
                        --query primaryConnectionString -o tsv)


################################
### Create CosmosDB
################################


# Step #1 - 
az cosmosdb create \
    --name "${NAMEPREFIX}-cosmos" \
    --resource-group $RESOURCEGROUP \
    --default-consistency-level Eventual \
    --locations regionName='East US' failoverPriority=0 isZoneRedundant=False \
    --locations regionName='West US' failoverPriority=1 isZoneRedundant=False \
    --enable-multiple-write-locations

# Step #2 Create Database (SQL Core)
az cosmosdb sql database create \
    --account-name "${NAMEPREFIX}-cosmos" \
    --resource-group $RESOURCEGROUP \
    --name "RequestDB"

# Step #3 Create Container 
az cosmosdb sql container create \
    --account-name "${NAMEPREFIX}-cosmos" \
    --resource-group $RESOURCEGROUP \
    --database-name "RequestDB" \
    --name "Requests" \
    -p "/id" \
    --throughput 400 


#4 Step #4 Get Connection String
cosmosConnectionString=$(az cosmosdb keys list \
                            --type connection-strings \
                            --name "${NAMEPREFIX}-cosmos" \
                            --resource-group $RESOURCEGROUP \
                            --query connectionStrings[0].connectionString -o tsv)

echo $cosmosConnectionString

#cleanup

################################
### Create Application Insights
################################

# Step #1 - Create Workspace First
az deployment group create \
    --resource-group $RESOURCEGROUP \
    --name workspacedeploy \
    --template-file workspace.json \
    --parameters "{\"workspaceName\": {\"value\": \"${NAMEPREFIX}-workspace\"},\"location\": {\"value\": \"${LOCATION}\"},\"sku\": {\"value\": \"Standalone\"}}"

# Step #2 - Create App INsights Instance (NOTE: THis will prompt for extension install on azure cli the first time)
az monitor app-insights component create \
    --app "${NAMEPREFIX}-ai" \
    --location $LOCATION \
    --kind web \
    --resource-group $RESOURCEGROUP \
    --workspace "${NAMEPREFIX}-workspace"

# Step #3 - Get the App Insights Instrumentation Key for later use

instrumentationKey=$(az monitor app-insights component show \
    --app "${NAMEPREFIX}-ai" \
    --resource-group $RESOURCEGROUP \
    --query "instrumentationKey" -o tsv)

echo $instrumentationKey

#############################################
### Update AppSettings for Function & Web App
#############################################

az webapp config appsettings set \
    --resource-group $RESOURCEGROUP \
    --name "${NAMEPREFIX}-web" \
    --settings "AppSettings:APIUrl=https://${NAMEPREFIX}-func.azurewebsites.net"

echo "AppSettings:APIUrl=https://${NAMEPREFIX}-func.azurewebsites.net"

az webapp config appsettings set \
    --resource-group $RESOURCEGROUP \
    --name "${NAMEPREFIX}-web" \
    --settings "APPINSIGHTS_INSTRUMENTATIONKEY=$instrumentationKey"

echo "APPINSIGHTS_INSTRUMENTATIONKEY=$instrumentationKey"

az functionapp config appsettings set \
    --resource-group $RESOURCEGROUP \
    --name "${NAMEPREFIX}-func" \
    --settings "APPINSIGHTS_INSTRUMENTATIONKEY=$instrumentationKey"

az functionapp config appsettings set \
    --resource-group $RESOURCEGROUP \
    --name "${NAMEPREFIX}-func" \
    --settings "ServiceBus=$SBCONNECTIONSTRING"

echo "ServiceBus=$SBCONNECTIONSTRING"

az functionapp config appsettings set \
    --resource-group $RESOURCEGROUP \
    --name "${NAMEPREFIX}-func" \
    --settings "CosmosDB=$cosmosConnectionString"

echo "CosmosDB=$cosmosConnectionString"



#############################################
### Cleanup and Helpful Commands
#############################################

# az group delete --name $resourceGroup

# az webapp list --resource-group $RESOURCEGROUP
