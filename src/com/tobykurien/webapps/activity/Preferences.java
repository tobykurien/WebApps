package com.tobykurien.webapps.activity;

import org.xtendroid.utils.BasePreferences;

import com.tobykurien.webapps.R;
import com.tobykurien.webapps.R.xml;

import android.os.Bundle;
import android.preference.PreferenceActivity;
import android.support.v7.app.AppCompatActivity;

public class Preferences extends AppCompatActivity {
   @Override
   protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      setContentView(R.layout.preferences);
   }
   
   @Override
   protected void onPause() {
      super.onPause();
      // tell Webview to reload with new settings
      BasePreferences.clearCache();
      BaseWebAppActivity.reload = true;
   }
}
