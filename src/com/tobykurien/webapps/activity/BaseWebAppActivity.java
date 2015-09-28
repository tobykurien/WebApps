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
import android.view.KeyEvent;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.widget.ProgressBar;

import com.tobykurien.webapps.R;
import com.tobykurien.webapps.data.Webapp;
import com.tobykurien.webapps.db.DbService;
import com.tobykurien.webapps.utils.Dependencies;
import com.tobykurien.webapps.utils.Settings;
import com.tobykurien.webapps.webviewclient.WebClient;
import com.tobykurien.webapps.webviewclient.WebViewUtils;

public class BaseWebAppActivity extends AppCompatActivity {
	public static boolean reload = false;
	public static String EXTRA_WEBAPP_ID = "webapp_id";

	WebView wv = null;
	Uri siteUrl = null;
	WebClient wc = null;
	long webappId = -1;
	Webapp webapp = null;
	Set<String> unblock = new HashSet<String>();

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

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
			
			if (webappId >= 0) {
				webapp = Dependencies.getDb(this)
						.findById(DbService.TABLE_WEBAPPS, webappId, Webapp.class);
			} else {
				webapp = new Webapp();
			}
		} else {
			// didn't get any intent data
			finish();
			return;
		}

		final ProgressBar pb = getProgressBar();
		if (pb != null)
			pb.setVisibility(View.VISIBLE);

		setupWebView();
		wv.setWebViewClient(getWebViewClient(pb));

		// save the favicon for later use if we get one
		wv.setWebChromeClient(new WebChromeClient() {
			@Override
			public void onReceivedIcon(WebView view, Bitmap icon) {
				super.onReceivedIcon(view, icon);
				onReceivedFavicon(view, icon);
			}
		});
		
		openSite(siteUrl.toString());
	}

	protected void setupWebView() {
		WebViewUtils.getInstance().setupWebView(this, wv, siteUrl, webapp, 
				Settings.getSettings(this).getIntFontSize());
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

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if ((keyCode == KeyEvent.KEYCODE_BACK) && wv.canGoBack()) {
			wv.goBack();
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}
}
