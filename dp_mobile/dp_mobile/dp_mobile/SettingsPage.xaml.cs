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
	public partial class SettingsPage : ContentPage
	{
		public SettingsPage ()
		{
			InitializeComponent ();
            serverEntry.BindingContext = DataHelper.ServerURL;
		}

        private void AccountsButton_Clicked(object sender, EventArgs e)
        {
            Navigation.PushAsync(new AccountsPage());
        }

        private void SaveServerButton_Clicked(object sender, EventArgs e)
        {
            if ((!string.IsNullOrEmpty(serverEntry.Text)) && (serverEntry.Text.Trim().Length > 0))
            {
                saveServerButton.IsEnabled = false;
                DataHelper.ServerURL = serverEntry.Text.Trim();
                DisplayAlert("Saved.", "Server URL was changed.", "Ok");
            }
            else
                DisplayAlert("Incorrect server URL.", "Server URL can not be empty.", "Ok");
        }

        private void ServerEntry_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (DataHelper.ServerURL != serverEntry.Text)
                saveServerButton.IsEnabled = true;
            else
                saveServerButton.IsEnabled = false;
        }
    }
}