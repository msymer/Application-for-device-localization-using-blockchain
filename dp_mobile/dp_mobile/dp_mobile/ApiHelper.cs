using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms.Internals;

namespace dp_mobile
{
    public static class ApiHelper
    {
        private static HttpClient _client = new HttpClient();
        
        /// <summary>
        /// Connect this device to an account.
        /// </summary>
        /// <param name="username">Username of the account.</param>
        /// <param name="connectionKey">The connection key.</param>
        /// <returns>The api response.</returns>
        public static async Task<ApiResponse> ConnectToAccount(string username, string connectionKey)
        {
            FormUrlEncodedContent content = new FormUrlEncodedContent(
                new List<KeyValuePair<string, string>>
                {
                    new KeyValuePair<string, string>("deviceNumber", DataHelper.DeviceNumber),
                    new KeyValuePair<string, string>("connectionKey", connectionKey),
                    new KeyValuePair<string, string>("username", username)
                });
            HttpResponseMessage httpResponse = await _client.PostAsync(DataHelper.ApiConnectUrl, content);
            string response = await httpResponse.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<ApiResponse>(response);
        } 
        
        /// <summary>
        /// Sends localization data to a server.
        /// </summary>
        /// <param name="longitude">A longitude.</param>
        /// <param name="latitude">A latitude</param>
        /// <param name="note">A note.</param>
        /// <param name="time">A time.</param>
        /// <returns></returns>
        public static async Task<ApiResponse> SendData(double longitude, double latitude, string note, DateTime time)
        {
            double jsTime = time.Subtract(new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc)).TotalMilliseconds;
            string jsonContent =
                "{" +
                $"\"deviceNumber\": \"{DataHelper.DeviceNumber}\"," +
                "\"coordinates\": {" +
                $"\"latitude\": \"{$"{latitude:F5}".Replace(',', '.')}\"," +
                $"\"longitude\": \"{$"{longitude:F5}".Replace(',', '.')}\"," +
                $"\"time\":\"{$"{jsTime}".Replace(',', '.')}\"," +
                $"\"note\": \"{note}\"" +
                "}}";

            #region This JSON solution does not work in Release mode, so that s why i rewrote the json manually.
            //object data = new
            //{
            //    deviceNumber = DataHelper.DeviceNumber,
            //    coordinates = new
            //    {
            //        latitude = $"{latitude:F5}".Replace(',', '.'),
            //        longitude = $"{longitude:F5}".Replace(',', '.'),
            //        time = $"{jsTime}".Replace(',', '.'),
            //        note
            //    }
            //};
            //string jsonContent = JsonConvert.SerializeObject(data);
            #endregion

            HttpRequestMessage request = new HttpRequestMessage
            {
                Content = new StringContent(jsonContent, Encoding.UTF8, "application/json"),
                Method = HttpMethod.Post,
                RequestUri = new Uri(DataHelper.ApiSendDataUrl)
            };

            HttpResponseMessage httpResponse = await _client.SendAsync(request);
            string response = await httpResponse.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<ApiResponse>(response);
        }

        /// <summary>
        /// Removes this device from account with an username.
        /// </summary>
        /// <param name="username">The username.</param>
        /// <returns></returns>
        public static async Task<ApiResponse> RemoveDevice(string username)
        {
            string jsonContent =
                "{" +
                $"\"deviceNumber\": \"{DataHelper.DeviceNumber}\"," +
                $"\"username\": \"{username}\"" +
                "}";

            #region This JSON solution does not work in Release mode, so that s why i rewrote the json manually.
            //object data = new
            //{
            //    deviceNumber = DataHelper.DeviceNumber,
            //    username
            //};
            //string jsonContent = JsonConvert.SerializeObject(data);
            #endregion

            HttpRequestMessage request = new HttpRequestMessage
            {
                Content = new StringContent(jsonContent, Encoding.UTF8, "application/json"),
                Method = HttpMethod.Delete,
                RequestUri = new Uri(DataHelper.ApiRemoveDeviceUrl)
            };
            
            HttpResponseMessage httpResponse = await _client.SendAsync(request);
            string response = await httpResponse.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<ApiResponse>(response);
        }
    }
}
