package com.tobykurien.webapps;

import android.annotation.TargetApi;
import android.app.ActionBar;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.DialogInterface.OnMultiChoiceClickListener;
import android.os.Build;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewConfiguration;
import android.view.WindowManager;

/**
 * Extensions to the main activity for Android 3.0+, or at least it used to be. Now the core
 * functionality is in the base class and the UI-related stuff is here.
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
      
      autohideActionbar();
   }

   @Override
   public boolean onOptionsItemSelected(MenuItem item) {
      if (item.getItemId() == android.R.id.home) {
         finish();
         return true;
      }
      
      if (item.getItemId() == R.id.menu_3rd_party) {
         // show blocked 3rd party domains and allow user to allow them
         new AlertDialog.Builder(this)
            .setTitle("Blocked root domains")
            .setMultiChoiceItems(wc.getBlockedHosts(), null, new OnMultiChoiceClickListener() {
               @Override
               public void onClick(DialogInterface d, int pos, boolean checked) {
               }
            })
            .setPositiveButton("Unblock", new OnClickListener() {
               @Override
               public void onClick(DialogInterface d, int pos) {
                  wv.reload();
                  d.dismiss();
               }
            })
            .create()
            .show();
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
