using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace Five.Functions
{

    [JsonObject(NamingStrategyType = typeof(CamelCaseNamingStrategy))]
    public class RequestDataModel
    {
        [JsonProperty("id")]
        public string RequestId{get;set;}
        public String RequestValue {get;set;}
        public DateTime OriginalDate {get;set;}
        public DateTime SavedDate {get;set;}
        
    }
}