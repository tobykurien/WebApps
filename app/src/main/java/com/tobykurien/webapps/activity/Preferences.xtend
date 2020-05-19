package com.tobykurien.webapps.activity

import org.xtendroid.utils.BasePreferences
import com.tobykurien.webapps.R
import android.os.Bundle
import android.support.v7.app.AppCompatActivity

class Preferences extends AppCompatActivity {
	override protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState)
		setContentView(R.layout.preferences)
	}

	override protected void onPause() {
		super.onPause() // tell Webview to reload with new settings
		BasePreferences.clearCache()
		BaseWebAppActivity.reload = true
	}

}
