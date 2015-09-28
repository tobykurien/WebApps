package com.tobykurien.webapps.webviewclient

import android.content.Context
import android.net.Uri
import android.os.Build
import android.webkit.WebSettings.TextSize
import android.webkit.WebView
import com.tobykurien.webapps.data.Webapp

abstract class WebViewUtils {
	def static WebViewUtils getInstance() {
		if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP) {
			return new WebViewUtilsApi21();
		} else {
			return new WebViewUtilsApi11();
		}		
	}
	
	def void setTextSize(WebView wv, int size) {
		var textSize = TextSize.NORMAL;

		switch (size) {
		case 0: textSize = TextSize.SMALLEST
		case 1: textSize = TextSize.SMALLER
		case 2: textSize = TextSize.NORMAL
		case 3: textSize = TextSize.LARGER
		case 4: textSize = TextSize.LARGEST
		}

		wv.getSettings().setTextSize(textSize);
	}
	
	def abstract void setupWebView(Context context, WebView wv, 
		Uri siteUrl, Webapp webapp, int defaultFontSize);
}