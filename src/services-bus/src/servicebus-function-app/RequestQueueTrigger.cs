using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using System.IO;
using System.Threading.Tasks;

namespace Five.Functions
{
    public class RequestQueueTrigger
    {
        [FunctionName("RequestQueueTrigger")]
        public async Task Run(
            [ServiceBusTrigger("Requests", Connection = "ServiceBus")]RequestModel request, 
            [CosmosDB(
                databaseName: "RequestDB",
                collectionName: "Requests",
                ConnectionStringSetting = "CosmosDB",
                CreateIfNotExists = false,
                PartitionKey = "/id",
                PreferredLocations = "East US"
                )] IAsyncCollector<RequestDataModel> requests,
            ILogger log)
        {
            log.LogInformation($"C# ServiceBus queue trigger function processed message: {request.RequestValue}");

            var dataModel = new RequestDataModel() { RequestId = Guid.NewGuid().ToString(), RequestValue = request.RequestValue, OriginalDate=request.RequestTime, SavedDate=DateTime.Now };

            await requests.AddAsync(dataModel);
            await requests.FlushAsync();

        }

    }
}
