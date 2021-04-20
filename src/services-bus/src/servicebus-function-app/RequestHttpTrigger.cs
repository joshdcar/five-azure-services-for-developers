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
    public class RequestHttpTrigger
    {
        const string _queueName = "requests";
        private IHttpClientFactory _clientFactory = null;

        public RequestHttpTrigger(IHttpClientFactory httpClientFactory)
        {
            _clientFactory = httpClientFactory;
        }

        [FunctionName("RequestHttpTrigger")]
        public static async Task<IActionResult> Run(
            [ServiceBus(_queueName, Connection="ServiceBus")]IAsyncCollector<RequestModel> queue,
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "request")] HttpRequest req,
            ILogger log)
        {
            
            var payload = await req.ReadAsStringAsync();
            var request = JsonConvert.DeserializeObject<RequestModel>(payload);
            
            for(int count=1; count <= request.Count; count++){
                var newRequest = new RequestModel() { RequestTime=request.RequestTime, RequestValue=$"Request {count} of batch {request.Count}" };
                
                await queue.AddAsync(newRequest);
                
            }
           
            string responseMessage = "Requests Submitted to Messaging Queue";

            return new OkObjectResult(responseMessage);
        }
    }
}
