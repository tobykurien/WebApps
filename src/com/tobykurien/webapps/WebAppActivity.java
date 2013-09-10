package com.tobykurien.webapps;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import android.annotation.TargetApi;
import android.app.ActionBar;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.DialogInterface.OnMultiChoiceClickListener;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewConfiguration;
import android.view.WindowManager;
import android.widget.TextView;

import com.tobykurien.webapps.db.DbService;
import com.tobykurien.webapps.utils.Dependencies;

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
         final List<String> unblock = new ArrayList<String>();
         new AlertDialog.Builder(this)
            .setTitle(R.string.blocked_root_domains)
            .setMultiChoiceItems(wc.getBlockedHosts(), null, new OnMultiChoiceClickListener() {
               @Override
               public void onClick(DialogInterface d, int pos, boolean checked) {
                  if (checked) {
                     unblock.add(wc.getBlockedHosts()[pos].intern());
                  } else {
                     unblock.remove(wc.getBlockedHosts()[pos].intern());
                  }
               }
            })
            .setPositiveButton(R.string.unblock, new OnClickListener() {
               @Override
               public void onClick(DialogInterface d, int pos) {
                  wc.unblockDomains(unblock); 
                  wv.reload();
                  d.dismiss();
               }
            })
            .create()
            .show();
      }
      
      if (item.getItemId() == R.id.menu_save) {
         final View dlgView = LayoutInflater.from(this).inflate(R.layout.dlg_save, null);
         final TextView name = (TextView) dlgView.findViewById(R.id.txtName);
         name.setText(wv.getTitle());
         
         new AlertDialog.Builder(this)
            .setTitle(R.string.title_save_webapp)
            .setView(dlgView)
            .setPositiveButton(R.string.btn_save, new OnClickListener() {
               @Override
               public void onClick(DialogInterface d, int pos) {
                  DbService db = Dependencies.getDb(WebAppActivity.this);
                  HashMap<String, Object> values = new HashMap<String, Object>();
                  values.put("name", name.getText());
                  values.put("url", wv.getUrl());
                  values.put("iconUrl", "");
                  db.insert(DbService.TABLE_WEBAPPS, values);
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
