package com.tobykurien.webapps.webviewclient

import com.tobykurien.webapps.webviewclient.WebViewUtilsApi12
import android.content.Context
import android.webkit.WebView
import android.net.Uri
import com.tobykurien.webapps.data.Webapp
import android.annotation.TargetApi

@TargetApi(16)
class WebViewUtilsApi16 extends WebViewUtilsApi12 {
	
	override setupWebView(Context context, WebView wv, Uri siteUrl, Webapp webapp, int defaultFontSize) {
		super.setupWebView(context, wv, siteUrl, webapp, defaultFontSize)
		
		var settings = wv.getSettings();		
		settings.setAllowUniversalAccessFromFileURLs(false);
		settings.setAllowFileAccessFromFileURLs(false);		
	}
	
}