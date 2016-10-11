package com.tobykurien.webapps.activity

import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.view.KeyEvent
import android.view.View
import android.webkit.CookieSyncManager
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.widget.ProgressBar
import com.tobykurien.webapps.R
import com.tobykurien.webapps.data.Webapp
import com.tobykurien.webapps.db.DbService
import com.tobykurien.webapps.utils.Dependencies
import com.tobykurien.webapps.utils.Settings
import com.tobykurien.webapps.webviewclient.WebClient
import com.tobykurien.webapps.webviewclient.WebViewUtils
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Map
import java.util.Set

import static extension org.xtendroid.utils.AlertUtils.*
import static extension com.tobykurien.webapps.utils.Dependencies.*

class BaseWebAppActivity extends AppCompatActivity {
    public static boolean reload = false
    public static String EXTRA_WEBAPP_ID = "webapp_id"
    package WebView wv = null
    package Uri siteUrl = null
    package WebClient wc = null
    package long webappId = -1
    package Webapp webapp = null
    package Set<String> unblock = new HashSet<String>()

    /**
     * Called when the activity is first created.
     */
    override void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout::webapp)

        wv = getWebView()
        if(wv === null) {
            finish()
            return;
        }

        if(getIntent() !== null && getIntent().getData() !== null &&
                Intent::ACTION_VIEW.equals(getIntent().getAction())) {
            siteUrl = getIntent().getData()
            webappId = getIntent().getLongExtra(EXTRA_WEBAPP_ID, -1)
            if(webappId >= 0) {
                webapp = db.findById(DbService::TABLE_WEBAPPS, webappId, typeof(Webapp))
                if (webapp == null) {
                    toast(getString(R.string.err_webapp_not_found))
                    finish()
                    return;
                }
            } else {
                webapp = new Webapp()
                webapp.url = siteUrl.toString
                webapp.name = webapp.url
            }
        } else {
            // didn't get any intent data
            finish()
            return;
        }

        val ProgressBar pb = getProgressBar()
        if(pb !== null) pb.setVisibility(View::VISIBLE)

        setupWebView()
        wv.setWebViewClient(getWebViewClient(pb)) // save the favicon for later use if we get one
        wv.setWebChromeClient(new WebChromeClient() {
            override void onReceivedIcon(WebView view, Bitmap icon) {
                super.onReceivedIcon(view, icon)
                onReceivedFavicon(view, icon)
            }
        })
        
        openSite(webapp.url)
    }

    def protected void setupWebView() {
        WebViewUtils::getInstance().setupWebView(this, wv, siteUrl, webapp,
        Settings::getSettings(this).getIntFontSize())
    }

    override protected void onResume() {
        super.onResume()
        CookieSyncManager.getInstance().startSync()
        if(reload) {
            reload = false
            setupWebView()
        }

    }

    override protected void onPause() {
        super.onPause()
        CookieSyncManager.getInstance().stopSync()
    }

    def void onReceivedFavicon(WebView view, Bitmap icon) {
    }

    def void onPageLoadStarted() {
    }

    def void onPageLoadDone() {
    }

    /**
     * Return the title bar progress bar to indicate progress
     * @return
     */
    def ProgressBar getProgressBar() {
        return findViewById(R.id::site_progress) as ProgressBar
    }

    /**
     * Return the web view in which to display the site
     * @return
     */
    def WebView getWebView() {
        return findViewById(R.id::site_webview) as WebView
    }

    /**
     * Return the web view client for the web view
     * @param pb
     * @return
     */
    def protected WebClient getWebViewClient(ProgressBar pb) {
        if(wc === null) {
            unblock = new HashSet<String>()
            unblock.add(siteUrl.getHost())
            if(webappId >= 0) {
                // load saved unblock list
                var DbService db = Dependencies::getDb(this)
                var HashMap<String, Object> params = new HashMap<String, Object>()
                params.put("webappId", webappId)
                var List<Map<String, Object>> domains = db.executeForMapList(R.string::dbGetDomainNames, params)
                for(Map<String, Object> domain : domains) {
                    unblock.add(domain.get("domain") as String)
                }

            }
            wc = new WebClient(this, wv, pb, unblock)
        }
        return wc
    }

    def void openSite(String url) {
        wv.loadUrl(url)
    }

    override boolean onKeyDown(int keyCode, KeyEvent event) {
        if((keyCode === KeyEvent::KEYCODE_BACK) && wv.canGoBack()) {
            wv.goBack()
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

}
