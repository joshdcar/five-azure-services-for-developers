using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Newtonsoft.Json;
using System.Net.Http;

namespace Five.Functions
{
    public class RequestQueueTrigger
    {
        [FunctionName("RequestCosmosHttpTrigger")]
        public async Task Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "request")] HttpRequest req,
            [CosmosDB(
                databaseName: "RequestDB",
                collectionName: "Requests",
                ConnectionStringSetting = "CosmosDB",
                CreateIfNotExists = true,
                PartitionKey = "/id",
                PreferredLocations = "East US"
                )] IAsyncCollector<RequestDataModel> requests,
            ILogger log)
        {
            
            var payload = await req.ReadAsStringAsync();

            var request = JsonConvert.DeserializeObject<RequestModel>(payload);

            var dataModel = new RequestDataModel() { 
                    RequestId = Guid.NewGuid().ToString(), 
                    RequestValue = request.RequestValue, 
                    OriginalDate=request.RequestTime, 
                    SavedDate=DateTime.Now 
            };

            await requests.AddAsync(dataModel);
            await requests.FlushAsync();

        }

    }
}
