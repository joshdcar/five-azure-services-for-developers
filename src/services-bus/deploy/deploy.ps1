
$LOCATION='eastus'
$NAMEPREFIX='fivetx'
$RESOURCEGROUP='texas-azure'

################################
### Create Service Bus
################################

# Step #1 - Create Service Bus Namespace
az servicebus namespace create `
    --name "${NAMEPREFIX}-sbns" `
    --resource-group $RESOURCEGROUP `
    --location $LOCATION
  
# Step #2 - Create Queue
az servicebus queue create `
    --resource-group $RESOURCEGROUP `
    --namespace-name "${NAMEPREFIX}-sbns" `
    --name Requests

#3 step #3 - Retrieve the Connection string used in the Function App

$SBCONNECTIONSTRING=$(az servicebus namespace authorization-rule keys list `
                        --resource-group $RESOURCEGROUP `
                        --namespace-name "${NAMEPREFIX}-sbns" `
                        --name RootManageSharedAccessKey `
                        --query primaryConnectionString -o tsv)

echo $SBCONNECTIONSTRING