using Newtonsoft.Json;
using Plugin.DeviceInfo;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;
using Xamarin.Forms;

namespace dp_mobile
{
    public static class DataHelper
    {
        #region Constants, Private variables
        private const string _baseServerUrl = "https://localhost:3000";
        private const string _connectUrl = "/api/connect";
        private const string _sendDataUrl = "/api/send-data";
        private const string _removeDeviceUrl = "/api/remove-device";

        private static ObservableCollection<string> _accounts = new ObservableCollection<string>();
        private static List<Frequency> _frequencies = new List<Frequency>();
        #endregion

        #region Getters, Setters
        public static bool IsAutomaticTracking
        {
            get
            {
                if (!Application.Current.Properties.ContainsKey("isAutomaticTracking"))
                {
                    Application.Current.Properties["isAutomaticTracking"] = false;
                }
                return (bool)Application.Current.Properties["isAutomaticTracking"];
            }

            set
            {
                Application.Current.Properties["isAutomaticTracking"] = value;
            }

        }

        public static int TrackingFrequency
        {
            get
            {
                if (!Application.Current.Properties.ContainsKey("trackingFrequency") || ((int)Application.Current.Properties["trackingFrequency"] == 0))
                {
                    Application.Current.Properties["trackingFrequency"] = 300;
                    return 300;
                }
                return (int)Application.Current.Properties["trackingFrequency"];
            }

            set
            {
                Application.Current.Properties["trackingFrequency"] = value;
            }
        }
        
        public static string DeviceNumber
        {
            get
            {
                if (!Application.Current.Properties.ContainsKey("deviceNumber") || (string.IsNullOrEmpty(Application.Current.Properties["deviceNumber"] as string)))
                {
                    Application.Current.Properties["deviceNumber"] = GetUniqueDeviceId();
                }
                return Application.Current.Properties["deviceNumber"] as string;
            }
        }

        public static string ServerURL
        {
            get
            {
                if (!Application.Current.Properties.ContainsKey("serverUrl") || (string.IsNullOrEmpty(Application.Current.Properties["serverUrl"] as string)))
                {
                    Application.Current.Properties["serverUrl"] = _baseServerUrl;
                }
                return Application.Current.Properties["serverUrl"] as string;
            }

            set
            {
                Application.Current.Properties["serverUrl"] = value;
            }
        }

        public static string ApiConnectUrl
        {
            get
            {
                return ServerURL + _connectUrl;
            }
        }

        public static string ApiSendDataUrl
        {
            get
            {
                return ServerURL + _sendDataUrl;
            }
        }

        public static string ApiRemoveDeviceUrl
        {
            get
            {
                return ServerURL + _removeDeviceUrl;
            }
        }

        public static List<Frequency> Frequencies
        {
            get
            {
                if (_frequencies.Count == 0)
                    InitFrequencyValues();
                return _frequencies;
            }
        }

        public static ObservableCollection<string> Accounts
        {
            get
            {
                if (_accounts.Count < 1)
                {
                    if (Application.Current.Properties.ContainsKey("accounts") && (!string.IsNullOrEmpty(Application.Current.Properties["accounts"] as string)))
                    {
                        foreach (string username in GetConnectedAccounts())
                            _accounts.Add(username);
                    }
                }
                return _accounts;
            }
        }

        
        #endregion

        #region Private methods
        private static void InitFrequencyValues()
        {
            _frequencies.Add(new Frequency() { Text = "every 30 seconds", Seconds = 30 });
            _frequencies.Add(new Frequency() { Text = "every 1 minute", Seconds = 60 });
            _frequencies.Add(new Frequency() { Text = "every 2 minutes", Seconds = 120 });
            _frequencies.Add(new Frequency() { Text = "every 5 minutes", Seconds = 300 });
            _frequencies.Add(new Frequency() { Text = "every 10 minutes", Seconds = 600 });
            _frequencies.Add(new Frequency() { Text = "every 15 minutes", Seconds = 900 });
            _frequencies.Add(new Frequency() { Text = "every 30 minutes", Seconds = 1800 });
            _frequencies.Add(new Frequency() { Text = "every 1 hour", Seconds = 3600 });
            _frequencies.Add(new Frequency() { Text = "every 2 hours", Seconds = 7200 });
            _frequencies.Add(new Frequency() { Text = "every 5 hours", Seconds = 18000 });
            _frequencies.Add(new Frequency() { Text = "every 10 hours", Seconds = 36000 });
            _frequencies.Add(new Frequency() { Text = "every 24 hours", Seconds = 86400 });
        }
        private static List<string> GetConnectedAccounts()
        {
            if (Application.Current.Properties.ContainsKey("accounts") || (!string.IsNullOrEmpty(Application.Current.Properties["accounts"] as string)))
                return JsonConvert.DeserializeObject<List<string>>(Application.Current.Properties["accounts"] as string);
            return null;
        }

        #endregion

        /// <summary>
        /// Gets unique device id.
        /// </summary>
        /// <returns></returns>
        public static string GetUniqueDeviceId()
        {
            return CrossDeviceInfo.Current.Id;
        }

        /// <summary>
        /// Saves new account.
        /// </summary>
        /// <param name="username">The username of the account.</param>
        public static void SaveConnectedAccount(string username)
        {
            if(_accounts == null)
            {
                _accounts = new ObservableCollection<string>();
            }
            _accounts.Add(username);
            Application.Current.Properties["accounts"] = JsonConvert.SerializeObject(_accounts);
        }

        /// <summary>
        /// Removes connected account from this device.
        /// </summary>
        /// <param name="username">The username of the account.</param>
        public static void RemoveConnectedAccount(string username)
        {
            if (_accounts == null)
            {
                _accounts = new ObservableCollection<string>();
            }
            else
            {
                if (_accounts.Remove(username))
                {
                    Application.Current.Properties["accounts"] = JsonConvert.SerializeObject(_accounts);
                }
            }
        }
        
    }
}
