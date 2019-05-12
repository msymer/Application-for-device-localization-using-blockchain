using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms;

namespace dp_mobile
{
    public partial class MainPage : ContentPage
    {
        public MainPage()
        {
            InitializeComponent();

            autoTrackingSwitch.BindingContext = DataHelper.IsAutomaticTracking;
            frequencyPicker.ItemsSource = DataHelper.Frequencies;
            frequencyPicker.BindingContext = DataHelper.Frequencies.Find((f) => f.Seconds == DataHelper.TrackingFrequency);
        }
        

        private void Settings_Clicked(object sender, EventArgs e)
        {
            Navigation.PushAsync(new SettingsPage());
        }

        private void StartTracking_Clicked(object sender, EventArgs e)
        {
            Navigation.PushAsync(new TrackingPage());
        }
        
        private void AutoTrackingSwitch_Toggled(object sender, ToggledEventArgs e)
        {
            DataHelper.IsAutomaticTracking = e.Value;
        }

        private void FrequencyPicker_SelectedIndexChanged(object sender, EventArgs e)
        {
            Picker picker = (Picker)sender;
            int selectedIndex = picker.SelectedIndex;

            if (selectedIndex != -1)
            {
                DataHelper.TrackingFrequency = ((Frequency)picker.ItemsSource[selectedIndex]).Seconds;
            }
        }
    }
}
