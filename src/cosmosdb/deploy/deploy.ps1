$BICEP_FILE = "deploy.bicep"
$LOCATION='eastus'
$NAMEPREFIX='fivetx'
$RESOURCEGROUP='texas-azure'

az group create -n $RESOURCEGROUP -l $LOCATION

az deployment group create `
    --name fiveservicesfuncdeploy `
    --resource-group $RESOURCEGROUP `
    --template-file $BICEP_FILE `
    --parameters '{\"appName\": {\"value\": \"fivetx\"}}'

$connectionString = az cosmosdb keys list `
                        --type connection-strings `
                        --name "${NAMEPREFIX}-cosmos" `
                        --resource-group $RESOURCEGROUP `
                        --query connectionStrings[0].connectionString -o tsv

echo $connectionString