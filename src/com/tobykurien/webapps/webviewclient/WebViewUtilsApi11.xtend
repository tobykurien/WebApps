package com.tobykurien.webapps.webviewclient

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.webkit.CookieManager
import android.webkit.CookieSyncManager
import android.webkit.WebIconDatabase
import android.webkit.WebSettings
import android.webkit.WebSettings.PluginState
import android.webkit.WebSettings.TextSize
import android.webkit.WebView
import com.tobykurien.webapps.data.Webapp
import com.tobykurien.webapps.utils.Settings
import android.annotation.TargetApi

@TargetApi(11)
class WebViewUtilsApi11 extends WebViewUtils {

	override void setupWebView(Context context, WebView wv, 
		Uri siteUrl, Webapp webapp, int defaultFontSize) {
		WebIconDatabase.getInstance().open(
				context.getDir("icons", Context.MODE_PRIVATE).getPath());
		CookieSyncManager.createInstance(context);
		CookieManager.getInstance().setAcceptCookie(true);

		var settings = wv.getSettings();
		settings.setJavaScriptEnabled(true);
		settings.setJavaScriptCanOpenWindowsAutomatically(false);

		// Enable local database per site
		// NOTE: No longer works on API 19+
		settings.setDatabaseEnabled(true);
		var databasePath = context.getApplicationContext().getCacheDir()
				+ "db-" + siteUrl.getHost();
		settings.setDatabasePath(databasePath);

		// Enable caching each site individually
		// NOTE: No longer works on API 19+
		var cachePath = context.getApplicationContext().getCacheDir()
				+ "/cache-" + siteUrl.getHost();		
		settings.setAppCachePath(cachePath);
		settings.setAppCacheEnabled(true);		
		settings.setAppCacheMaxSize(1024 * 1024 * 8);		
		settings.setCacheMode(WebSettings.LOAD_DEFAULT);

		// allow access to documents for upload		
		settings.allowContentAccess = true
		settings.allowFileAccess = true

		settings.setPluginState(PluginState.OFF);
		settings.setDomStorageEnabled(true);
		settings.setSupportZoom(true);
		settings.setBuiltInZoomControls(false);
		settings.setGeolocationEnabled(true); // allow maps, etc. to work
		settings.setJavaScriptCanOpenWindowsAutomatically(false);
		settings.setSaveFormData(false);
		settings.setSavePassword(false);
		settings.setLoadsImagesAutomatically(Settings.getSettings(context)
				.isLoadImages());

		// set preferred text size
		if (webapp.getFontSize() >= 0) {
			setTextSize(wv, webapp.getFontSize());
		} else {
			setTextSize(wv, defaultFontSize);
		}

		// set preferred user agent
		var userAgent = Settings.getSettings(context).getUserAgent();
		if (webapp.userAgent != null && webapp.userAgent.trim.length > 0) {
			userAgent = webapp.userAgent
		}
		if (userAgent != null && userAgent.trim.length > 0) {
			wv.getSettings().setUserAgentString(userAgent);
		}

		wv.addJavascriptInterface([
			throw new IllegalStateException("not supported");
		], "window");

		wv.onLongClickListener = [view|
			var url = wv.getHitTestResult().getExtra();
			if (url != null) {
				var i = new Intent(Intent.ACTION_VIEW);
				i.setData(Uri.parse(url));
				i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(i);
				return true;
			}

			return false;
		]
	}

}