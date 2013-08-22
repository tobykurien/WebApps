package com.tobykurien.webapps;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnLongClickListener;
import android.webkit.CookieSyncManager;
import android.webkit.WebSettings;
import android.webkit.WebSettings.TextSize;
import android.webkit.WebView;
import android.widget.ProgressBar;

import com.tobykurien.webapps.utils.Settings;
import com.tobykurien.webapps.webviewclient.WebClient;

public class BaseWebAppActivity extends Activity {
   public static boolean reload = false;

   WebView wv;
   Uri siteUrl;
   WebClient wc;
   
   /** Called when the activity is first created. */
   @Override
   public void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      setContentView(R.layout.webapp);
      CookieSyncManager.createInstance(this);

      wv = getWebView();
      if (wv == null) {
         finish();
         return;
      }
      
      if (getIntent() != null && getIntent().getData() != null && 
               Intent.ACTION_VIEW.equals(getIntent().getAction())) {
         siteUrl = getIntent().getData();
      }
      
      setupWebView();
   }
   
   @Override
   protected void onResume() {
      super.onResume();
      if (reload) {
         reload = false;
         setupWebView();
      }
   }
   
   protected void setupWebView() {      
      final ProgressBar pb = getProgressBar();
      if (pb != null) pb.setVisibility(View.VISIBLE);

      // WebView.enablePlatformNotifications();
      WebSettings settings = wv.getSettings();
      settings.setJavaScriptEnabled(true);
      settings.setJavaScriptCanOpenWindowsAutomatically(false);
      settings.setAllowFileAccess(false);
      settings.setPluginsEnabled(false);
      
      // Enable local database.
      settings.setDatabaseEnabled(true);
      String databasePath = this.getApplicationContext().getDir("database", Context.MODE_PRIVATE).getPath();
      settings.setDatabasePath(databasePath);

      // Enable manifest cache.
      String cachePath = this.getApplicationContext().getDir("cache", Context.MODE_PRIVATE).getPath();
      settings.setAppCachePath(cachePath);
      settings.setAllowFileAccess(true);
      settings.setAppCacheEnabled(true);
      settings.setDomStorageEnabled(true);
      settings.setAppCacheMaxSize(1024 * 1024 * 8);
      settings.setCacheMode(WebSettings.LOAD_DEFAULT);

      // set preferred text size
      setTextSize();

      String userAgent = Settings.getSettings(this).getUserAgent();
      if (!userAgent.equals("")) {
         wv.getSettings().setUserAgentString(userAgent);
      }
      
      wv.setWebViewClient(getWebViewClient(pb));

      wv.addJavascriptInterface(new Object() {
         // attempt to override the _window function used by Google+ mobile app
         public void open(String url, String stuff, String otherstuff, String morestuff, String yetmorestuff, String yetevenmore) {
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
    * @param pb
    * @return
    */
   protected WebClient getWebViewClient(ProgressBar pb) {
      if (wc == null) wc = new WebClient(this, wv, pb, new String[]{ siteUrl.getHost() });
      return wc;
   }

   public void openSite(String url) {
      wv.loadUrl(url);
   }

   public void setTextSize() {
      TextSize textSize = TextSize.NORMAL;

      int size = Settings.getSettings(this).getFontSize(); 
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

   @Override
   public boolean onCreateOptionsMenu(Menu menu) {
      super.onCreateOptionsMenu(menu);
      MenuInflater inflater = getMenuInflater();
      inflater.inflate(R.menu.webapps_menu, menu);
      return true;
   }

   @Override
   public boolean onOptionsItemSelected(MenuItem item) {
      switch (item.getItemId()) {
         case R.id.menu_stop:
            wv.stopLoading();
            return true;
         case R.id.menu_settings:
            Intent i = new Intent(this, Preferences.class);
            startActivity(i);
            return true;
         case R.id.menu_exit:
            finish();
            return true;
      }
      return false;
   }
}