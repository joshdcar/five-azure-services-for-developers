$LOCATION='eastus'
$NAMEPREFIX='fivetx'
$RESOURCEGROUP='texas-azure'

# Create resource group 
az group create --name $RESOURCEGROUP --location $LOCATION

################################
### Create App Service (Web App)
################################

# Step #1 - Create App Service Plan - S1 is smallest with deployment slots
az appservice plan create `
    --name "${NAMEPREFIX}-web-asp" `
    --resource-group $RESOURCEGROUP `
    --location $LOCATION `
    --sku S1 

# Step #2 - Create a Web Application
az webapp create `
    --name "${NAMEPREFIX}-web" `
    --resource-group $RESOURCEGROUP `
    --plan "${NAMEPREFIX}-web-asp" `
    --runtime 'DOTNETCORE"|"3.1'

# Step #3 - Create a Deployment Slot (Staging)
az webapp deployment slot create `
    --name "${NAMEPREFIX}-web" `
    --resource-group $RESOURCEGROUP `
    --slot staging 