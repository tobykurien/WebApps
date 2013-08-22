package com.tobykurien.webapps;

import android.os.Bundle;
import android.preference.PreferenceActivity;

public class Preferences extends PreferenceActivity {
   @Override
   protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      addPreferencesFromResource(R.xml.settings);
   }
   
   @Override
   protected void onPause() {
      super.onPause();
      // tell Webview to reload with new settings
      WebAppActivity.reload = true;
   }
}
