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
		settings.allowFileAccessFromFileURLs = false
		settings.allowUniversalAccessFromFileURLs = false
	}
	
	override setTextSize(WebView wv, int size) {
		wv.settings.textZoom = switch(size) {
			case 0: 50
			case 1: 75
			case 2: 100
			case 3: 125
			case 4: 150
			default: 100
		}
	}
	
}