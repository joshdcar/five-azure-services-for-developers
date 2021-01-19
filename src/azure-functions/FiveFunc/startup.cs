using System;
using System.IO;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;

[assembly: FunctionsStartup(typeof(Five.Functions.Startup))]

namespace Five.Functions
{
  
    public class Startup: FunctionsStartup {

        public override void Configure(IFunctionsHostBuilder builder)
        {           
            builder.Services.AddHttpClient();

        }

    }

}