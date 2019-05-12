using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace dp_mobile
{
	[XamlCompilation(XamlCompilationOptions.Compile)]
	public partial class NewAccountPage : ContentPage
	{
		public NewAccountPage ()
		{
			InitializeComponent ();
		}

        private async void ConnectButton_Clicked(object sender, EventArgs e)
        {
            connectButton.IsEnabled = false;
            try
            {
                string username = usernameEntry.Text;
                ApiResponse response = await ApiHelper.ConnectToAccount(username, connectionKeyEntry.Text);
                if (response.Result)
                {
                    if (!DataHelper.Accounts.Contains(username))
                    {
                        DataHelper.SaveConnectedAccount(username);
                        await DisplayAlert("Success!", $"Device was connected to {usernameEntry.Text} account.", "Ok");
                    }
                    else
                    {
                        await DisplayAlert("Already connected.", "The device already has a connected record about this account. ", "Ok");
                    }
                }
                else
                {
                    await DisplayAlert("Oops!", response.Msg, "Ok");
                }
            }
            catch(Exception ex)
            {
                await DisplayAlert("Error", ex.Message, "Ok");
            }
            connectButton.IsEnabled = true;
        }
    }
}