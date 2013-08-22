package com.tobykurien.webapps;

import android.annotation.TargetApi;
import android.app.ActionBar;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewConfiguration;
import android.view.WindowManager;
import android.widget.ProgressBar;

import com.tobykurien.webapps.webviewclient.WebClient;

/**
 * Extensions to the main activity for Android 3.0+
 * @author toby
 */
@TargetApi(Build.VERSION_CODES.HONEYCOMB)
public class WebAppActivity extends BaseWebAppActivity {
   // variables to track dragging for actionbar auto-hide
   protected float startX;
   protected float startY;

   @Override
   public void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);

      getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
                              WindowManager.LayoutParams.FLAG_FULLSCREEN);
      
      // setup actionbar
      ActionBar ab = getActionBar();
      ab.setDisplayShowTitleEnabled(false);
      ab.setDisplayHomeAsUpEnabled(true);
      
//      ab.setNavigationMode(ActionBar.NAVIGATION_MODE_LIST);
//      ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
//               android.R.layout.simple_list_item_1,
//               android.R.id.text1,
//               getResources().getStringArray(R.array.sites));
//      ab.setListNavigationCallbacks(adapter, new OnNavigationListener() {
//         @Override
//         public boolean onNavigationItemSelected(int arg0, long arg1) {
//            String url = getResources().getStringArray(R.array.sites_url)[arg0];
//            openSite(url);
//            return true;
//         }
//      });
      
      autohideActionbar();
      
      if (getIntent() != null && getIntent().getData() != null && 
               Intent.ACTION_VIEW.equals(getIntent().getAction())) {
         Log.d("wa", "loading " + getIntent().getDataString());
         openSite(getIntent().getDataString());
      }
   }
   
   @Override
   protected WebClient getWebViewClient(ProgressBar pb) {
      return new WebClient(this, wv, pb);
   }

   @Override
   public boolean onOptionsItemSelected(MenuItem item) {
      if (item.getItemId() == android.R.id.home) {
         finish();
         return true;
      }
      if (item.getItemId() == R.id.menu_exit) {
         Runtime.getRuntime().exit(0);
         return true;
      }
      return super.onOptionsItemSelected(item);
   }
   
   /**
    * Attempt to make the actionBar auto-hide and auto-reveal based on drag,
    * but unfortunately makes the bit under the actionbar mostly inaccessible,
    * so leaving this out for now.
    * @param activity
    * @param wv
    */
   public void autohideActionbar() {
      wv.setOnTouchListener(new OnTouchListener() {
         @Override
         public boolean onTouch(View arg0, MotionEvent event) {
            if (event.getAction() == MotionEvent.ACTION_DOWN) {
               startY = event.getY();
            }

            if (event.getAction() == MotionEvent.ACTION_MOVE) {
               // avoid juddering by waiting for large-ish drag
               if (Math.abs(startY - event.getY()) > 
                  new ViewConfiguration().getScaledTouchSlop() * 5) {
                  if (startY < event.getY()) 
                     getActionBar().show();
                  else
                     getActionBar().hide();
               }
            }

            return false;
         }
      });
   }
}
