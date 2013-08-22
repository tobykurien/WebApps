package com.tobykurien.webapps.webviewclient;

import java.io.ByteArrayInputStream;
import android.annotation.TargetApi;
import android.app.Activity;
import android.net.Uri;
import android.os.Build;
import android.util.Log;
import android.view.View;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;

/**
 * WebViewClient for Android 3.0+
 * 
 * @author toby
 */
@TargetApi(Build.VERSION_CODES.HONEYCOMB)
public class WebClientV11 extends WebClient {
   public WebClientV11(Activity activity, WebView wv, View pd) {
      super(activity, wv, pd);
   }
   
   @Override
   public WebResourceResponse shouldInterceptRequest(WebView view, String url) {
      // Block 3rd party requests (i.e. scripts/iframes/etc. outside Google's domains)
      // and also any unencrypted connections
      if (!url.startsWith("https://") || !isInSandbox(Uri.parse(url))) {
         //Log.d("wvc11", "Blocking " + url);
         return new WebResourceResponse("text/plain", "utf-8", 
                  new ByteArrayInputStream("[blocked]".getBytes()));
      }
      
      return super.shouldInterceptRequest(view, url);
   }
}
