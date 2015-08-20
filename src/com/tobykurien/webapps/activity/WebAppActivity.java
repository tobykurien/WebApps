package com.tobykurien.webapps.activity;

import org.eclipse.xtext.xbase.lib.Functions.Function1;

import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.DialogInterface.OnMultiChoiceClickListener;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewConfiguration;
import android.view.WindowManager;

import com.tobykurien.webapps.R;
import com.tobykurien.webapps.fragment.DlgSaveWebapp;
import com.tobykurien.webapps.utils.Settings;

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
	protected float startX;
	protected float startY;
	Settings settings;

	private MenuItem stopMenu = null;
	private MenuItem imageMenu = null;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		settings = Settings.getSettings(this);
		if (settings.isFullscreen()) {
			getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
					WindowManager.LayoutParams.FLAG_FULLSCREEN);
		}

		// setup actionbar
		ActionBar ab = getSupportActionBar();
		ab.setDisplayShowTitleEnabled(false);
		ab.setDisplayHomeAsUpEnabled(true);

		autohideActionbar();
	}

	@Override
	protected void onResume() {
		super.onResume();

		// may not be neccessary, but reload the settings
		settings = Settings.getSettings(this);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		super.onCreateOptionsMenu(menu);
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.webapps_menu, menu);
		
		stopMenu = menu.findItem(R.id.menu_stop);
		imageMenu = menu.findItem(R.id.menu_image);
		imageMenu.setChecked(Settings.getSettings(this).isLoadImages());
		updateImageMenu();
		
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home:
			finish();
			return true;

		case R.id.menu_3rd_party:
			dlg3rdParty();
			return true;

		case R.id.menu_save:
			dlgSave();
			return true;

		case R.id.menu_stop:
			if (stopMenu != null && !stopMenu.isChecked()) {
				wv.reload();
			} else {
				wv.stopLoading();
			}
			return true;

		case R.id.menu_image:
			if (imageMenu != null) {
				imageMenu.setChecked(!imageMenu.isChecked());
				updateImageMenu();
				setupWebView();
			}
			return true;
			
		case R.id.menu_settings:
			Intent i = new Intent(this, Preferences.class);
			startActivity(i);
			return true;

		case R.id.menu_exit:
			finish();
			return true;
		}

		return super.onOptionsItemSelected(item);
	}

	private void updateImageMenu() {
		Settings.getSettings(this).setLoadImages(imageMenu.isChecked());
		imageMenu.setIcon((imageMenu.isChecked() ?
				R.drawable.ic_action_image: 
			    R.drawable.ic_action_broken_image));
	}

	@Override
	public void onPageLoadStarted() {
		super.onPageLoadStarted();
		if (stopMenu != null) {
			stopMenu.setTitle(R.string.menu_stop);
			stopMenu.setIcon(R.drawable.ic_action_stop);
			stopMenu.setChecked(true);
		}
	}
	
	@Override
	public void onPageLoadDone() {
		super.onPageLoadDone();
		if (stopMenu != null) {
			stopMenu.setTitle(R.string.menu_refresh);
			stopMenu.setIcon(R.drawable.ic_action_refresh);
			stopMenu.setChecked(false);
		}
	}
	
	private void dlgSave() {
		DlgSaveWebapp dlg = new DlgSaveWebapp(webappId, wv.getTitle(), wv.getUrl(), unblock);
		
		dlg.setOnSaveListener(new Function1<Long, Void>() {
			@Override
			public Void apply(Long p) {
				webappId = p;
				return null;
			}
		});

		dlg.show(getSupportFragmentManager(), "save");
	}

	private void dlg3rdParty() {
		// show blocked 3rd party domains and allow user to allow them
		new AlertDialog.Builder(this)
				.setTitle(R.string.blocked_root_domains)
				.setMultiChoiceItems(wc.getBlockedHosts(), null,
						new OnMultiChoiceClickListener() {
							@Override
							public void onClick(DialogInterface d, int pos,
									boolean checked) {
								if (checked) {
									unblock.add(wc.getBlockedHosts()[pos]
											.intern());
								} else {
									unblock.remove(wc.getBlockedHosts()[pos]
											.intern());
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
				}).create().show();
	}

	/**
	 * Attempt to make the actionBar auto-hide and auto-reveal based on drag
	 * 
	 * @param activity
	 * @param wv
	 */
	public void autohideActionbar() {
		wv.setOnTouchListener(new OnTouchListener() {
			@Override
			public boolean onTouch(View arg0, MotionEvent event) {
				if (settings.isHideActionbar()) {
					if (event.getAction() == MotionEvent.ACTION_DOWN) {
						startY = event.getY();
					}

					if (event.getAction() == MotionEvent.ACTION_MOVE) {
						// avoid juddering by waiting for large-ish drag
						if (Math.abs(startY - event.getY()) > new ViewConfiguration()
								.getScaledTouchSlop() * 5) {
							if (startY < event.getY())
								getSupportActionBar().show();
							else
								getSupportActionBar().hide();
						}
					}
				}

				return false;
			}
		});
	}
}
