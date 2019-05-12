using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace dp_mobile
{
	[XamlCompilation(XamlCompilationOptions.Compile)]
	public partial class AccountsPage : ContentPage
	{
		public AccountsPage ()
		{
			InitializeComponent ();
            accountsListView.ItemsSource = DataHelper.Accounts;
		}

        private void NewAccountToolbarItem_Clicked(object sender, EventArgs e)
        {
            Navigation.PushAsync(new NewAccountPage());
        }

        private async void RemoveButton_Clicked(object sender, EventArgs e)
        {
            try
            {
                Button button = (Button)sender;
                button.IsEnabled = false;
                string username = button.CommandParameter.ToString();
                ApiResponse response = await ApiHelper.RemoveDevice(username);
                if (response.Result || (response.Msg.Contains("does not exist.")))
                {
                    DataHelper.RemoveConnectedAccount(username);
                }
                else
                {
                    await DisplayAlert("Oops!", $"The device was not disconnected from the account. {response.Msg}", "Ok");
                    button.IsEnabled = true;
                }
            }
            catch(Exception ex)
            {
                await DisplayAlert("Error", ex.Message, "Ok");
            }
        }
    }
}