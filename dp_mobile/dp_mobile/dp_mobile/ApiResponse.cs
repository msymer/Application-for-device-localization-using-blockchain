using System;
using System.Collections.Generic;
using System.Text;
using Xamarin.Forms.Internals;

namespace dp_mobile
{
    [Preserve(AllMembers = true)]
    public struct ApiResponse
    {
        public bool Result { get; set; }
        public string Msg { get; set; }
    }
}
