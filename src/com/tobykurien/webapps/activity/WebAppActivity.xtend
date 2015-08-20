package com.tobykurien.webapps.activity;

import android.annotation.TargetApi
import android.app.AlertDialog
import android.content.DialogInterface
import android.content.Intent
import android.graphics.Bitmap
import android.os.Build
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.WindowManager
import android.webkit.WebView
import android.widget.ImageView
import com.tobykurien.webapps.R
import com.tobykurien.webapps.fragment.DlgSaveWebapp
import com.tobykurien.webapps.utils.Settings
import org.xtendroid.utils.AsyncBuilder
import com.tobykurien.webapps.utils.FaviconHandler
import com.tobykurien.webapps.adapter.WebappsAdapter

/**
 * Extensions to the main activity for Android 3.0+, or at least it used to be.
 * Now the core functionality is in the base class and the UI-related stuff is
 * here.
 * 
 * @author toby
 */
@TargetApi(Build.VERSION_CODES.HONEYCOMB)
public class WebAppActivity extends BaseWebAppActivity {
	// variables to track dragging for actionbar auto-hide
	var protected float startX;
	var protected float startY;
	var Settings settings;

	var private MenuItem stopMenu = null;
	var private MenuItem imageMenu = null;

	override onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		settings = Settings.getSettings(this);
		if (settings.isFullscreen()) {
			getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
					WindowManager.LayoutParams.FLAG_FULLSCREEN);
		}

		// setup actionbar
		var ab = getSupportActionBar();
		ab.setDisplayShowTitleEnabled(false);
		ab.setDisplayShowCustomEnabled(true);
		ab.setDisplayHomeAsUpEnabled(true);
		ab.setCustomView(R.layout.actionbar_favicon);
      
      // load a favico if it already exists
      var iconImg = supportActionBar.customView.findViewById(R.id.favicon) as ImageView;
      WebappsAdapter.loadFavicon(this, new FaviconHandler(this).getFavIcon(webappId), iconImg)     
		
		autohideActionbar();
	}

	override void onResume() {
		super.onResume();

		// may not be neccessary, but reload the settings
		settings = Settings.getSettings(this);
	}

	override onCreateOptionsMenu(Menu menu) {
		super.onCreateOptionsMenu(menu);
		var inflater = getMenuInflater();
		inflater.inflate(R.menu.webapps_menu, menu);
		
		stopMenu = menu.findItem(R.id.menu_stop);
		imageMenu = menu.findItem(R.id.menu_image);
		imageMenu.setChecked(Settings.getSettings(this).isLoadImages());
		updateImageMenu();
		
		return true;
	}

	override onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home: {
			finish();
			return true;
		}

		case R.id.menu_3rd_party: {
			dlg3rdParty();
			return true;
		}

		case R.id.menu_save: {
			dlgSave();
			return true;
		}

		case R.id.menu_stop: {
         if (stopMenu != null && !stopMenu.isChecked()) {
            wv.reload();
         } else {
            wv.stopLoading();
         }
         return true;
		}

		case R.id.menu_image: {
         if (imageMenu != null) {
            imageMenu.setChecked(!imageMenu.isChecked());
            updateImageMenu();
            setupWebView();
         }
         return true;
		}
			
		case R.id.menu_settings: {
			var i = new Intent(this, Preferences);
			startActivity(i);
			return true;
      }

		case R.id.menu_exit: {
			finish();
			return true;
		}
		}

		return super.onOptionsItemSelected(item);
	}
	
	def void updateImageMenu() {
		Settings.getSettings(this).setLoadImages(imageMenu.isChecked());
		imageMenu.setIcon(
		   if (imageMenu.isChecked()) 
		    R.drawable.ic_action_image
		   else 
			 R.drawable.ic_action_broken_image
	   );
	}

	override onPageLoadStarted() {
		super.onPageLoadStarted();
		if (stopMenu != null) {
			stopMenu.setTitle(R.string.menu_stop);
			stopMenu.setIcon(R.drawable.ic_action_stop);
			stopMenu.setChecked(true);
		}
	}
	
	override onPageLoadDone() {
		super.onPageLoadDone();
		
		if (stopMenu != null) {
			stopMenu.setTitle(R.string.menu_refresh);
			stopMenu.setIcon(R.drawable.ic_action_refresh);
			stopMenu.setChecked(false);
		}
	}
	
   override onReceivedFavicon(WebView view, Bitmap icon) {
      super.onReceivedFavicon(view, icon)
      var iconImg = supportActionBar.customView.findViewById(R.id.favicon) as ImageView;
      iconImg.setImageBitmap(icon);
      
      // also save favicon
      AsyncBuilder.async [builder, params|
         new FaviconHandler(this).saveFavIcon(webappId, icon)
      ].start()
   }

	def private void dlgSave() {
		var dlg = new DlgSaveWebapp(webappId, wv.getTitle(), wv.getUrl(), unblock);
		
		dlg.setOnSaveListener [id |
		   webappId = id
		   return null
      ]
      
		dlg.show(getSupportFragmentManager(), "save");
	}

	def private void dlg3rdParty() {
		// show blocked 3rd party domains and allow user to allow them
		new AlertDialog.Builder(this)
				.setTitle(R.string.blocked_root_domains)
				.setMultiChoiceItems(wc.getBlockedHosts(), null, [DialogInterface d, int pos, boolean checked|
					if (checked) {
						unblock.add(wc.getBlockedHosts().get(pos).intern());
					} else {
						unblock.remove(wc.getBlockedHosts().get(pos).intern());
					}
				])
				.setPositiveButton(R.string.unblock, [DialogInterface d, int pos|
					wc.unblockDomains(unblock);
					wv.reload();
					d.dismiss();
				])
				.create()
				.show();
	}

	/**
	 * Attempt to make the actionBar auto-hide and auto-reveal based on drag
	 * 
	 * @param activity
	 * @param wv
	 */
	def void autohideActionbar() {
		wv.setOnTouchListener [View arg0, MotionEvent event|
				if (settings.isHideActionbar()) {
					if (event.getAction() == MotionEvent.ACTION_DOWN) {
						startY = event.getY();
					}

					if (event.getAction() == MotionEvent.ACTION_MOVE) {
						// avoid juddering by waiting for large-ish drag
						if (Math.abs(startY - event.getY()) > 
						      new ViewConfiguration().getScaledTouchSlop() * 5) {
							if (startY < event.getY()) {
							   supportActionBar.show();
							} else {
								supportActionBar.hide();
							}
						}
					}
				}

				return false;
      ]
	}
}
