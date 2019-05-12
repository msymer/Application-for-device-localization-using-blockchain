using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Essentials;

namespace dp_mobile
{
    public static class LocationHelper
    {
        public static async Task<Location> GetLocation()
        {
            try
            {
                GeolocationRequest request = new GeolocationRequest(GeolocationAccuracy.Medium);
                Location location = await Geolocation.GetLocationAsync(request);
                if (!location.IsFromMockProvider)
                    return location;
                throw new Exception("This location is from mock provider and can not be accepted.");
            }
            catch (FeatureNotSupportedException)
            {
                throw new Exception("The device does not support this feature.");
            }
            catch (FeatureNotEnabledException)
            {
                throw new Exception("Geolocation is not enabled.");
            }
            catch (PermissionException)
            {
                throw new Exception("Application does not have permission for this feature.");
            }
        }
    }
}
