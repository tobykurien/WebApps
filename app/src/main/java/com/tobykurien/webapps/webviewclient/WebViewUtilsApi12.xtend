package com.tobykurien.webapps.webviewclient

import android.content.Context
import android.net.Uri
import android.webkit.CookieManager
import android.webkit.WebView
import com.tobykurien.webapps.data.Webapp
import android.annotation.TargetApi

@TargetApi(12)
class WebViewUtilsApi12 extends WebViewUtilsApi11 {
	
	override setupWebView(Context context, WebView wv, Uri siteUrl, Webapp webapp, int defaultFontSize) {
		super.setupWebView(context, wv, siteUrl, webapp, defaultFontSize)

		CookieManager.setAcceptFileSchemeCookies(false);
	}
	
}