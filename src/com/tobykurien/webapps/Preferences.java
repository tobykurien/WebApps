package com.tobykurien.webapps;

import org.xtendroid.utils.BasePreferences;

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
      BasePreferences.clearCache();
      BaseWebAppActivity.reload = true;
   }
}
