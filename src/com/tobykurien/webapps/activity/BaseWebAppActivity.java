package com.tobykurien.webapps.activity;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnLongClickListener;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.WebIconDatabase;
import android.webkit.WebSettings;
import android.webkit.WebSettings.PluginState;
import android.webkit.WebSettings.TextSize;
import android.webkit.WebView;
import android.widget.ProgressBar;

import com.tobykurien.webapps.R;
import com.tobykurien.webapps.db.DbService;
import com.tobykurien.webapps.utils.Dependencies;
import com.tobykurien.webapps.utils.Settings;
import com.tobykurien.webapps.webviewclient.WebClient;

public class BaseWebAppActivity extends AppCompatActivity {
	public static boolean reload = false;
	public static String EXTRA_WEBAPP_ID = "webapp_id";

	WebView wv = null;
	Uri siteUrl = null;
	WebClient wc = null;
	long webappId = -1;
	Set<String> unblock = new HashSet<String>();

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		WebIconDatabase.getInstance().open(
				getDir("icons", MODE_PRIVATE).getPath());
		setContentView(R.layout.webapp);

		wv = getWebView();
		if (wv == null) {
			finish();
			return;
		}

		if (getIntent() != null && getIntent().getData() != null
				&& Intent.ACTION_VIEW.equals(getIntent().getAction())) {
			siteUrl = getIntent().getData();
			webappId = getIntent().getLongExtra(EXTRA_WEBAPP_ID, -1);
		} else {
			// didn't get any intent data
			finish();
			return;
		}

		CookieSyncManager.createInstance(this);
		// CookieManager.setAcceptFileSchemeCookies(false); // needs API min
		// level = 12
		CookieManager.getInstance().setAcceptCookie(true);
		setupWebView();
	}

	@Override
	protected void onResume() {
		super.onResume();

		CookieSyncManager.getInstance().startSync();

		if (reload) {
			reload = false;
			setupWebView();
		}
	}

	@Override
	protected void onPause() {
		super.onPause();
		CookieSyncManager.getInstance().stopSync();
	}

	protected void setupWebView() {
		final ProgressBar pb = getProgressBar();
		if (pb != null)
			pb.setVisibility(View.VISIBLE);

		// WebView.enablePlatformNotifications();
		WebSettings settings = wv.getSettings();
		settings.setJavaScriptEnabled(true);
		settings.setJavaScriptCanOpenWindowsAutomatically(false);

		// Enable local database per site
		settings.setDatabaseEnabled(true);
		String databasePath = this.getApplicationContext().getCacheDir()
				+ "db-" + siteUrl.getHost();
		settings.setDatabasePath(databasePath);

		// Enable caching each site individually
		String cachePath = this.getApplicationContext().getCacheDir()
				+ "/cache-" + siteUrl.getHost();
		settings.setAppCachePath(cachePath);
		settings.setAppCacheEnabled(true);
		settings.setAppCacheMaxSize(1024 * 1024 * 8);
		settings.setCacheMode(WebSettings.LOAD_DEFAULT);
		settings.setAllowFileAccess(false);
		settings.setPluginState(PluginState.OFF);
		settings.setAllowContentAccess(false);
		settings.setDomStorageEnabled(true);
		settings.setBuiltInZoomControls(false);
		settings.setGeolocationEnabled(false);
		settings.setJavaScriptCanOpenWindowsAutomatically(false);
		settings.setSaveFormData(false);
		settings.setSavePassword(false);
		settings.setLoadsImagesAutomatically(Settings.getSettings(this)
				.isLoadImages());

		// set preferred text size
		setTextSize();

		String userAgent = Settings.getSettings(this).getUserAgent();
		if (!userAgent.equals("")) {
			wv.getSettings().setUserAgentString(userAgent);
		}

		wv.setWebViewClient(getWebViewClient(pb));

		// save the favicon for later use if we get one
		wv.setWebChromeClient(new WebChromeClient() {
			@Override
			public void onReceivedIcon(WebView view, Bitmap icon) {
				super.onReceivedIcon(view, icon);
				onReceivedFavicon(view, icon);
			}
		});

		wv.addJavascriptInterface(new Object() {
			@JavascriptInterface
			// attempt to override the _window function used by Google+ mobile
			// app
			public void open(String url, String stuff, String otherstuff,
					String morestuff, String yetmorestuff, String yetevenmore) {
				throw new IllegalStateException(url); // to indicate success
			}
		}, "window");

		wv.setOnLongClickListener(new OnLongClickListener() {
			@Override
			public boolean onLongClick(View arg0) {
				String url = wv.getHitTestResult().getExtra();
				if (url != null) {
					Intent i = new Intent(android.content.Intent.ACTION_VIEW);
					i.setData(Uri.parse(url));
					i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
					startActivity(i);
					return true;
				}

				return false;
			}
		});

		openSite(siteUrl.toString());
	}

	public void onReceivedFavicon(WebView view, Bitmap icon) {
	}

	public void onPageLoadStarted() {

	}

	public void onPageLoadDone() {

	}

	/**
	 * Return the title bar progress bar to indicate progress
	 * 
	 * @return
	 */
	public ProgressBar getProgressBar() {
		return (ProgressBar) findViewById(R.id.site_progress);
	}

	/**
	 * Return the web view in which to display the site
	 * 
	 * @return
	 */
	public WebView getWebView() {
		return (WebView) findViewById(R.id.site_webview);
	}

	/**
	 * Return the web view client for the web view
	 * 
	 * @param pb
	 * @return
	 */
	protected WebClient getWebViewClient(ProgressBar pb) {
		if (wc == null) {
			unblock = new HashSet<String>();
			unblock.add(siteUrl.getHost());

			if (webappId >= 0) {
				// load saved unblock list
				DbService db = Dependencies.getDb(this);
				HashMap<String, Object> params = new HashMap<String, Object>();
				params.put("webappId", webappId);
				List<Map<String, Object>> domains = db.executeForMapList(
						R.string.dbGetDomainNames, params);
				for (Map<String, Object> domain : domains) {
					unblock.add((String) domain.get("domain"));
				}
			}

			wc = new WebClient(this, wv, pb, unblock.toArray(new String[0]));
		}
		return wc;
	}

	public void openSite(String url) {
		wv.loadUrl(url);
	}

	public void setTextSize() {
		TextSize textSize = TextSize.NORMAL;

		int size = Settings.getSettings(this).getIntFontSize();
		switch (size) {
		case 0:
			textSize = TextSize.SMALLEST;
			break;
		case 1:
			textSize = TextSize.SMALLER;
			break;
		case 2:
			textSize = TextSize.NORMAL;
			break;
		case 3:
			textSize = TextSize.LARGER;
			break;
		case 4:
			textSize = TextSize.LARGEST;
			break;
		}

		wv.getSettings().setTextSize(textSize);
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if ((keyCode == KeyEvent.KEYCODE_BACK) && wv.canGoBack()) {
			wv.goBack();
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}
}
