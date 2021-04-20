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
       
        private IHttpClientFactory _clientFactory = null;

        public RequestHttpTrigger(IHttpClientFactory httpClientFactory)
        {
            _clientFactory = httpClientFactory;
        }

        [FunctionName("RequestHttpTrigger")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "request")] HttpRequest req,
            ILogger log)
        {
            
            var payload = await req.ReadAsStringAsync();

            return new OkObjectResult(payload);
        }
    }
}
