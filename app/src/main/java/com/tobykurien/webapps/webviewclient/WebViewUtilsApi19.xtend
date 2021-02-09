package com.tobykurien.webapps.webviewclient

import android.annotation.TargetApi
import android.content.Context
import android.net.Uri
import android.util.Log
import android.webkit.CookieManager
import android.webkit.WebView
import com.tobykurien.webapps.data.Webapp
import com.tobykurien.webapps.utils.Debug
import java.io.File

import static extension com.tobykurien.webapps.utils.Dependencies.*

/**
 * In API 19+, many things changed with the Webview, rendering previous sandboxing useless.
 * This class implements a new strategy for sandboxing.
 */
@TargetApi(19)
class WebViewUtilsApi19 extends WebViewUtilsApi16 {
	val static CACHE_DIR = "/org.chromium.android_webview"	// where webview stores cache data (inside cache dir)
	val static WEBAPP_DIR = "/app_webview"	// where webview stores cookies, etc. (inside app's root directory)

	override setupWebView(Context context, WebView wv, Uri siteUrl, Webapp webapp, int defaultFontSize) {
		// set up the webview
		super.setupWebView(context, wv, siteUrl, webapp, defaultFontSize)

		wv.settings.setMediaPlaybackRequiresUserGesture(false)

		if (false) {
			// save previously-viewed webapp's data
			saveWebappData(context)

			// clear all caches
			wv.clearCache(true)
			wv.clearFormData
			wv.clearHistory
			var cookieManager = CookieManager.getInstance();
			if (Debug.COOKIE) Log.d("cookie", "DELETING ALL COOKIES")
			cookieManager.removeAllCookie();
			trimCache(context)				
			 
			// restore data for the current webapp, if any
			restoreWebappData(context, webapp)
		}
	}
	
	// Restore the webapp cache and webview data for sandboxing
	def restoreWebappData(Context context, Webapp webapp) {
		if (webapp == null || webapp.id < 0) {
			context.settings.lastWebappId = -1
			return
		}
				
		var appDataDir = WEBAPP_DIR + "_" + webapp.id
		var f = new File(context.appDir + appDataDir)
		if (f.exists) {
			f.renameTo(new File(context.appDir + WEBAPP_DIR))
			var cache = new File(context.appDir + WEBAPP_DIR + CACHE_DIR)
			if (cache.exists) {
				cache.renameTo(new File(context.cacheDir.absolutePath + CACHE_DIR))
			}
		} 
		
		// write the webapp id into a file for saveWebappData to use
		context.settings.lastWebappId = webapp.id
	}
	
	// Save the webapp cache and webview data for sandboxing
	def saveWebappData(Context context) {
		// figure out the last webapp id
		var webappId = context.settings.lastWebappId
		if (webappId < 0) return
		
		// save the webview data
		var appDataDir = WEBAPP_DIR + "_" + webappId
		var f = new File(context.appDir + appDataDir)
		if (f.exists) deleteDir(f)	// how did that happen?
		var dataDir = new File(context.appDir + WEBAPP_DIR)
		if (dataDir.exists) {
			dataDir.renameTo(f)			
			
			// also save cache data
			var cacheDir = new File(context.cacheDir.absolutePath + CACHE_DIR)
			if (cacheDir.exists) {
				cacheDir.renameTo(new File(context.appDir + appDataDir + CACHE_DIR))
			}
		}
	}
	
	override deleteWebappData(Context context, long webappId) {
		var webapp = context.db.findById("webapps", webappId, Webapp)
		if (webapp !== null) {
			var hostname = WebClient.getRootDomain(webapp.url)
			CookieManager.instance.setCookie(hostname, "")
		}

		super.deleteWebappData(context, webappId)

		// delete the saved webview data
		var appDataDir = WEBAPP_DIR + "_" + webappId
		var f = new File(context.appDir + appDataDir)
		if (f.exists) {
			deleteDir(f)
		}
		
		if (context.settings.lastWebappId == webappId) {
			// delete the last viewed data
			f = new File(context.appDir + WEBAPP_DIR)
			if (f.exists) {
				deleteDir(f)
			}
			context.settings.lastWebappId == -1
		}
	}
	
	def getAppDir(Context context) {
		context.filesDir.parent
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
			var pathadmob = context.appDir + "/" + WEBAPP_DIR;
			var dir = new File(pathadmob);
			if (dir.isDirectory()) {
				deleteDir(dir);
			}

			pathadmob = context.cacheDir.absolutePath + "/" + CACHE_DIR;
			dir = new File(pathadmob);
			if (dir.isDirectory()) {
				deleteDir(dir);
			}
		} catch (Exception e) {
			Log.e("webviewutils", "Error deleting cache directories", e)
		}
	}
}
