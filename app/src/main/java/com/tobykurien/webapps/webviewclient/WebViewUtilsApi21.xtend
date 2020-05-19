package com.tobykurien.webapps.webviewclient

import android.annotation.TargetApi
import android.content.Context
import android.net.Uri
import android.webkit.WebView
import com.tobykurien.webapps.data.Webapp
import android.webkit.*

@TargetApi(21)
class WebViewUtilsApi21 extends WebViewUtilsApi19 {
	
	override setupWebView(Context context, WebView wv, Uri siteUrl, Webapp webapp, int defaultFontSize) {
		super.setupWebView(context, wv, siteUrl, webapp, defaultFontSize)

		val cookieManager = CookieManager.instance
		cookieManager.setAcceptThirdPartyCookies(wv, false)
	}
}