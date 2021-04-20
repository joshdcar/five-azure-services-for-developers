using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;


namespace FiveApp.Pages
{
    public class RequestModel{
        public int Count {get;set;}
        public DateTime RequestTime {get;set;}
        public string RequestValue {get;set;}
    }

    public class IndexModel : PageModel
    {
        [BindProperty]
        public int RequestCount{get;set;}

        private readonly IHttpClientFactory _clientFactory;
        private readonly IConfiguration _configuration;
        private string _apiUrl;

        private readonly ILogger<IndexModel> _logger;

        public IndexModel(IConfiguration configuration, 
                            IHttpClientFactory clientFactory,
                            ILogger<IndexModel> logger)
        {
            _configuration = configuration;
            _clientFactory = clientFactory;
            _logger = logger;

            _apiUrl = _configuration["AppSettings:ApiUrl"];
        }

        public void OnGet()
        {

        }

        public async Task<IActionResult> OnPostRequest(){


             var client = _clientFactory.CreateClient();

            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            var request = new RequestModel() { Count=RequestCount, RequestTime=DateTime.Now, RequestValue=$"Original Batch: {RequestCount}"};

            StringContent content = new StringContent(JsonSerializer.Serialize(request));
            content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            
            var response = await client.PostAsync($"{_apiUrl}/api/request",content);

            if(!response.IsSuccessStatusCode){
                var errorContent = await response.Content.ReadAsStringAsync();
                throw new Exception($"Error adding to cart: {errorContent}");
            }

            return Page();

        }

    }
}
