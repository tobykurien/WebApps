package com.tobykurien.webapps.webviewclient;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.util.Log;
import android.view.View;
import android.webkit.CookieSyncManager;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

public class WebClient extends WebViewClient {
   Activity activity;
   WebView wv;
   View pd;
   public String[] domainUrls;
   HashMap<String,Boolean> blockedHosts = new HashMap<String,Boolean>();

   public WebClient(Activity activity, WebView wv, View pd, String[] domainUrls) {
      this.activity = activity;
      this.wv = wv;
      this.pd = pd;
      this.domainUrls = domainUrls;
   }

   @Override
   public void onPageFinished(WebView view, String url) {
      if (pd != null) pd.setVisibility(View.GONE);

      // Google+ workaround to prevent opening of blank window
      wv.loadUrl("javascript:_window=function(url){ location.href=url; }");

      CookieSyncManager.getInstance().sync();
      super.onPageFinished(view, url);
   }

   @Override
   public void onPageStarted(WebView view, String url, Bitmap favicon) {
      Log.d("webclient", "loading " + url);

      if (pd != null) pd.setVisibility(View.VISIBLE);
      super.onPageStarted(view, url, favicon);
   }

   @Override
   public boolean shouldOverrideUrlLoading(WebView view, String url) {
      Uri uri = getLoadUri(Uri.parse(url));
      if (!uri.getScheme().equals("https") || !isInSandbox(uri)) {
         Intent i = new Intent(android.content.Intent.ACTION_VIEW);
         i.setData(uri);
         activity.startActivity(i);
         return true;
      } else if (uri.getScheme().equals("mailto")) {
         Intent i = new Intent(android.content.Intent.ACTION_SEND);
         i.putExtra(android.content.Intent.EXTRA_EMAIL, url);
         i.setType("text/html");
         activity.startActivity(i);
         return true;
      } else if (uri.getScheme().equals("market")) {
         Intent i = new Intent(android.content.Intent.ACTION_VIEW);
         i.setData(uri);
         i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
         activity.startActivity(i);
         return true;
      }

      return super.shouldOverrideUrlLoading(view, url);
   }

   @Override
   public WebResourceResponse shouldInterceptRequest(WebView view, String url) {
      // Block 3rd party requests (i.e. scripts/iframes/etc. outside Google's domains)
      // and also any unencrypted connections
      if (url.startsWith("http://") || !isInSandbox(Uri.parse(url))) {
         Log.d("webclient", "Blocking " + url);
         blockedHosts.put(getRootDomain(url), true);
         return new WebResourceResponse("text/plain", "utf-8", 
                  new ByteArrayInputStream("[blocked]".getBytes()));
      }
      
      return super.shouldInterceptRequest(view, url);
   }
   
   /**
    * Most blocked 3rd party domains are CDNs, so rather use root domain
    * @param url
    * @return
    */
   private String getRootDomain(String url) {
      String host = Uri.parse(url).getHost();
      String[] parts = host.split("\\.");
      if (parts.length > 1) {
         return parts[parts.length - 2] + "." + parts[parts.length - 1];
      } else {
         return host;
      }
   }

   @Override
   public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
      super.onReceivedError(view, errorCode, description, failingUrl);
      Toast.makeText(activity, description, Toast.LENGTH_LONG).show();
   }
   
   /**
    * Parse the Uri and return an actual Uri to load. This will handle
    * exceptions, like loading a URL
    * that is passed in the "url" parameter, to bypass click-throughs, etc.
    * 
    * @param uri
    * @return
    */
   protected Uri getLoadUri(Uri uri) {
      if (uri == null) return uri;

      // handle google news links to external sites directly
      if (uri.getQueryParameter("url") != null) { 
         return Uri.parse(uri.getQueryParameter("url")); 
      }

      return uri;
   }
   
   /**
    * Returns true if the site is within the Google domains
    * @param uri
    * @return
    */
   protected boolean isInSandbox(Uri uri) {
   // String url = uri.toString();
      if ("data".equals(uri.getScheme())) return true;
      
      String host = uri.getHost();
      for (String sites : domainUrls) {
         for (String site : sites.split(" ")) {
            if (host.toLowerCase().endsWith(site.toLowerCase())) { return true; }
         }
      }
      
      return false;
   }

   public String[] getBlockedHosts() {
      List<String> ret = new ArrayList<String>();
      for (String key : blockedHosts.keySet()) {
         ret.add(key);
      }
      return (String[]) ret.toArray(new String[]{});
   }

   /**
    * Add domains to be unblocked
    * @param unblock
    */
   public void unblockDomains(Set<String> unblock) {
      for (String s : domainUrls) {
         unblock.add(s);
      }
      domainUrls = unblock.toArray(new String[]{ });
   } 
   
}
