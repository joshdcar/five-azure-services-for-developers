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


   