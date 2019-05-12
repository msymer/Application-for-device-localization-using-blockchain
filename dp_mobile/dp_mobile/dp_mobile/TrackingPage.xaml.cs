using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Essentials;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace dp_mobile
{
	[XamlCompilation(XamlCompilationOptions.Compile)]
	public partial class TrackingPage : ContentPage
	{
        private bool _noteAttached = false;
        private bool _isTracking = false;
        

		public TrackingPage ()
		{
			InitializeComponent ();
            InitTrackingStyle();
        }

        protected override bool OnBackButtonPressed()
        {
            _isTracking = false;
            return base.OnBackButtonPressed();
        }

        private void AttachNoteButton_Clicked(object sender, EventArgs e)
        {
            if((!string.IsNullOrEmpty(noteEntry.Text)) && (noteEntry.Text.Trim().Length > 0))
            {
                attachNoteButton.IsEnabled = false;
                attachNoteButton.Text = "Attached";
                _noteAttached = true;
            }
        }

        private async void TrackButton_Clicked_Auto(object sender, EventArgs e)
        {
            try
            {
                if (!_isTracking)
                {
                    _isTracking = true;
                    trackButton.Text = "Stop tracking";
                    await AutoTracking();
                }
                else
                {
                    StopAutoTracking();
                }
            }
            catch(Exception ex)
            {
                await DisplayAlert("Error", ex.Message, "Ok");
            }
            
        }

        private async void TrackButton_Clicked_NotAuto(object sender, EventArgs e)
        {
            trackButton.IsEnabled = false;
            activityIndicator.IsRunning = true;
            try
            {
                ApiResponse response = await ProcessTrackingPosition();
                if (!response.Result)
                    throw new Exception(response.Msg);
            }
            catch (Exception ex)
            {
                await DisplayAlert("Oops!", ex.Message, "Ok");
            }
            activityIndicator.IsRunning = false;
            trackButton.IsEnabled = true;
        }

        private void NoteEntry_TextChanged(object sender, TextChangedEventArgs e)
        {
            ResetAttachNote();
        }

        /// <summary>
        /// Sets everything for specific tracking style.
        /// </summary>
        private void InitTrackingStyle()
        {
            if (DataHelper.IsAutomaticTracking)
            {
                trackButton.Text = "Start tracking";
                trackButton.Clicked += TrackButton_Clicked_Auto;
                errorLabel.IsVisible = true;
            }
            else
            {
                trackButton.Text = "Track this position";
                trackButton.Clicked += TrackButton_Clicked_NotAuto;
            }
        }

        /// <summary>
        /// Resets controls for note attaching.
        /// </summary>
        private void ResetAttachNote()
        {
            attachNoteButton.IsEnabled = true;
            attachNoteButton.Text = "Attach note";
            _noteAttached = false;
        }

        /// <summary>
        /// Returns note and set controls.
        /// </summary>
        /// <returns>The note.</returns>
        private string GetNote()
        {
            if (!(string.IsNullOrEmpty(noteEntry.Text)) && _noteAttached)
            {
                string note = noteEntry.Text;
                if (!attachSwitch.IsToggled)
                {
                    ResetAttachNote();
                    noteEntry.Text = string.Empty;
                }
                return note;
            }
            return null;
        }

        /// <summary>
        /// Gets and sends one actual location.
        /// </summary>
        /// <returns></returns>
        private async Task<ApiResponse> ProcessTrackingPosition()
        {
            try
            {
                string note = GetNote();
                Location location = await LocationHelper.GetLocation();
                ApiResponse response = await ApiHelper.SendData(location.Longitude, location.Latitude, note, location.Timestamp.UtcDateTime);
                if (response.Result)
                {
                    longitudeLabel.Text = $"{location.Longitude:F5}";
                    latitudeLabel.Text = $"{location.Latitude:F5}";
                    noteLabel.Text = note;
                    timeLabel.Text = location.Timestamp.UtcDateTime.ToString();
                }
                else
                {
                    errorLabel.Text = response.Msg;
                    StopAutoTracking();
                }
                return response;
            }
            catch(Exception e)
            {
                errorLabel.Text = e.Message;
                StopAutoTracking();
                throw e;
            }
        }

        /// <summary>
        /// Starts auto tracking.
        /// </summary>
        /// <returns></returns>
        private async Task AutoTracking()
        {
            try
            {
                activityIndicator.IsRunning = true;
                ApiResponse response = await ProcessTrackingPosition();
                if (!response.Result)
                    throw new Exception(response.Msg);
            }
            catch (Exception ex)
            {
                StopAutoTracking();
                await DisplayAlert("Oops!", ex.Message, "Ok");
            }

            Device.StartTimer(TimeSpan.FromSeconds(DataHelper.TrackingFrequency), () =>
            {
                if (!_isTracking)
                    return false;

                ProcessTrackingPosition();

                if (!_isTracking)
                    return false;
                return true;
            });
        }

        /// <summary>
        /// Stops auto tracking and sets all controls and variables.
        /// </summary>
        private void StopAutoTracking()
        {
            activityIndicator.IsRunning = false;
            _isTracking = false;
            trackButton.IsEnabled = false;
            trackButton.Text = "Tracking done";
        }
        
    }
}