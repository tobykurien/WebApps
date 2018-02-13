package com.tobykurien.webapps.webviewclient

import android.content.ActivityNotFoundException
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.net.http.SslError
import android.util.Log
import android.view.View
import android.webkit.CookieSyncManager
import android.webkit.SslErrorHandler
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Toast
import com.tobykurien.webapps.R
import com.tobykurien.webapps.activity.BaseWebAppActivity
import com.tobykurien.webapps.data.Webapp
import com.tobykurien.webapps.fragment.DlgCertificate
import java.io.ByteArrayInputStream
import java.util.HashMap
import java.util.Set

import static extension com.tobykurien.webapps.utils.Dependencies.*
import static extension org.xtendroid.utils.AlertUtils.*
import android.webkit.ClientCertRequest
import java.net.URI
import android.webkit.CookieManager
import com.tobykurien.webapps.utils.Debug

class WebClient extends WebViewClient {
	package BaseWebAppActivity activity
	package Webapp webapp
	package WebView wv
	package View pd
	public  Set<String> domainUrls
	package var blockedHosts = new HashMap<String, Boolean>()

	new(BaseWebAppActivity activity, Webapp webapp, WebView wv, View pd, Set<String> domainUrls) {
		this.activity = activity
		this.webapp = webapp
		this.wv = wv
		this.pd = pd
		this.domainUrls = domainUrls
	}
	
	override onReceivedClientCertRequest(WebView view, ClientCertRequest request) {
		super.onReceivedClientCertRequest(view, request)
		activity.onClientCertificateRequest(request)
	}

	override void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
		if (webapp == null || webapp.certIssuedBy == null) {
			// no SSL cert was saved for this webapp, so show SSL error to user
			var dlg = new DlgCertificate(error.certificate, 
						activity.getString(R.string.title_cert_untrusted),
						activity.getString(R.string.cert_accept), [
							handler.proceed()
							true
						], [
							handler.cancel()
							true
						])
			dlg.show(activity.supportFragmentManager, "certificate")
		} else {
			// in onPageLoaded, WebAppActivity will check that the cert matches saved one
			handler.proceed()
		}
	}

	override void onPageFinished(WebView view, String url) {
		if(pd !== null) pd.setVisibility(View.GONE)
		activity.onPageLoadDone() 
		CookieSyncManager.getInstance().sync()
		super.onPageFinished(view, url)
	}

	override void onPageStarted(WebView view, String url, Bitmap favicon) {
		//Log.d("webclient", '''loading «url»''')
		if(pd !== null) pd.setVisibility(View.VISIBLE)
		activity.onPageLoadStarted()
		super.onPageStarted(view, url, favicon)
	}

	override boolean shouldOverrideUrlLoading(WebView view, String url) {
		var Uri uri = getLoadUri(Uri.parse(url))

		try {
			if (uri.getScheme().equals("https")) {
				if (isInSandbox(uri)) {
					return false
				} else {
					handleExternalLink(uri)
					return true
				}
			} else if (uri.getScheme().equals("mailto")) {
				var Intent i = new Intent(Intent.ACTION_SEND)
				i.putExtra(Intent.EXTRA_EMAIL, url)
				i.setType("text/html")
				activity.startActivity(i)
				return true
			} else if (uri.getScheme().equals("market")) {
				var Intent i = new Intent(Intent.ACTION_VIEW)
				i.setData(uri)
				i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
				activity.startActivity(i)
				return true
			} else if (uri.getScheme().equals("http")) {
				if (isInSandbox(uri)) {
					// Common case where site redirects to "http", let's force it to "https"
					var uriBuilder = uri.buildUpon()
					uriBuilder.scheme("https")
					uri = uriBuilder.build()
					view.loadUrl(uri.toString())
				} else {
					handleExternalLink(uri)
				}
				return true
			}
		} catch (ActivityNotFoundException e) {
			Log.e("webclient", "Error starting activity", e)
			// activity.toast("No activity found to handle URL " + url)
			return true
		} catch (Exception e2) {
			Log.e("webclient", "Error starting activity", e2)
			// activity.toast("Error opening URL " + url)
			return true
		}

		return super.shouldOverrideUrlLoading(view, url)
	}

	def handleExternalLink(Uri uri) {
		Log.d("url_loading", "Sending to default app " + uri.toString)
		var Intent i = new Intent(Intent.ACTION_VIEW)
		i.setData(uri)
		activity.startActivity(i)		
	}

	override WebResourceResponse shouldInterceptRequest(WebView view, String url) {
		// Block 3rd party requests (i.e. scripts/iframes/etc. outside Google's domains)
		// and also any unencrypted connections
		var Uri uri = Uri.parse(url)
		val siteUrl = uri.getHost()

		var boolean isBlocked = false
		if (activity.settings.isBlock3rdParty() && !isInSandbox(uri)) {
			isBlocked = true
		}

		if (activity.settings.isBlockHttp() && !uri.getScheme().equals("https") && !isInSandbox(uri)) {
			isBlocked = true
		}

		if (isBlocked) {
			Log.d("webclient", "Blocking " + url);
			blockedHosts.put(getRootDomain(url), true)
			return new WebResourceResponse("text/plain", "utf-8", new ByteArrayInputStream("[blocked]".getBytes()))
		}

		val cookieManager = CookieManager.instance
		if (Debug.COOKIE) Log.d("cookie", "Cookies for " + siteUrl + ": " + cookieManager.getCookie(siteUrl.toString()))

		return super.shouldInterceptRequest(view, url)
	}

	/** 
	 * Most blocked 3rd party domains are CDNs, so rather use root domain
	 * @param url
	 * @return
	 */
	def public static String getRootDomain(String url) {
		var String host = Uri.parse(url).getHost()
		try {
			var String[] parts = host.split("\\.").reverse
			if (parts.length > 2) {
				// handle things like mobile.site.co.za vs www1.api.site.com
				if (parts.get(0).length == 2 && parts.get(1).length <= 3) {
					return '''«{parts.get(2)}».«{parts.get(1)}».«{parts.get(0)}»'''
				} else {
					return '''«{parts.get(1)}».«{parts.get(0)}»'''
				}
			} else if (parts.length > 1) {
				return '''«{parts.get(1)}».«{parts.get(0)}»'''
			} else {
				return host
			}
		} catch (Exception e) {
			// sometimes things don't quite work out
			return host
		}
	}

	override void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
		super.onReceivedError(view, errorCode, description, failingUrl)
		Toast.makeText(activity, description, Toast.LENGTH_LONG).show()
	}

	/** 
	 * Parse the Uri and return an actual Uri to load. This will handle
	 * exceptions, like loading a URL
	 * that is passed in the "url" parameter, to bypass click-throughs, etc.
	 * @param uri
	 * @return
	 */
	def protected Uri getLoadUri(Uri uri) {
		if(uri === null) return uri // handle google news links to external sites directly
		if (uri.getQueryParameter("url") !== null) {
			return Uri.parse(uri.getQueryParameter("url"))
		}
		return uri
	}

	/** 
	 * Returns true if the  linked site is within the Webapp's domain
	 * @param uri
	 * @return
	 */
	def protected boolean isInSandbox(Uri uri) {
		// String url = uri.toString();
		// Log.e("uri", uri.toString)
		if("data".equals(uri.getScheme()) || "blob".equals(uri.getScheme())) return true
		var String host = uri.getHost()
		if(host == null) return true;

		for (String sites : domainUrls) {
			for (String site : sites.split(" ")) {
				if (site != null && host.toLowerCase().endsWith(site.toLowerCase())) {
					return true
				}

			}

		}
		return false
	}

	def Set<String> getBlockedHosts() {
		blockedHosts.keySet()
	}

	/** 
	 * Add domains to be unblocked
	 * @param unblock
	 */
	def void unblockDomains(Set<String> unblock) {
		for (String s : domainUrls) {
			unblock.add(s)
		}
		domainUrls = unblock
	}
}
