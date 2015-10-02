package com.tobykurien.webapps.webviewclient

import android.annotation.TargetApi
import android.content.Context
import android.net.Uri
import android.webkit.WebView
import com.tobykurien.webapps.data.Webapp
import java.io.File

/**
 * In API 19+, many things changed with the Webview, rendering previous sandboxing useless.
 * This class implements a new strategy for sandboxing.
 */
@TargetApi(19)
class WebViewUtilsApi19 extends WebViewUtilsApi16 {
	val static CACHE_DIR = "org.chromium.android_webview"
	val static WEBAPP_DIR = "app_webview"

	override setupWebView(Context context, WebView wv, Uri siteUrl, Webapp webapp, int defaultFontSize) {
		super.setupWebView(context, wv, siteUrl, webapp, defaultFontSize)

		saveWebappData(context)

		//wv.clearCache(true);
		//trimCache(context);

		if (webapp != null && webapp.id > 0) {
			restoreWebappData(webapp)
		}
	}
	
	// Restore the webapp cache and webview data for sandboxing
	def restoreWebappData(Webapp webapp) {
	}
	
	// Save the webapp cache and webview data for sandboxing
	def saveWebappData(Context context) {
	}

	def private static boolean deleteDir(File dir) {
		if (dir != null && dir.isDirectory()) {
			var children = dir.list();
			for (String aChildren : children) {
				var success = deleteDir(new File(dir, aChildren));
				if (!success) {
					return false;
				}
			}
		}
		// The directory is now empty so delete it
		return dir != null && dir.delete();

	}

	def void trimCache(Context context) {
		try {
			var pathadmob = context.getFilesDir().getParent() + "/" + WEBAPP_DIR;
			var dir = new File(pathadmob);
			if (dir.isDirectory()) {
				deleteDir(dir);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}