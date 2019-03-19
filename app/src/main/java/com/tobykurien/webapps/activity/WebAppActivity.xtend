package com.tobykurien.webapps.activity;

import android.annotation.TargetApi
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.support.v4.content.pm.ShortcutManagerCompat
import android.support.v7.app.AlertDialog
import android.util.Log
import android.view.ContextMenu
import android.view.ContextMenu.ContextMenuInfo
import android.view.Menu
import android.view.MenuItem
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.WindowManager
import android.webkit.CookieManager
import android.webkit.WebView
import android.widget.ImageView
import com.tobykurien.webapps.R
import com.tobykurien.webapps.adapter.WebappsAdapter
import com.tobykurien.webapps.data.ThirdPartyDomain
import com.tobykurien.webapps.db.DbService
import com.tobykurien.webapps.fragment.DlgCertificate
import com.tobykurien.webapps.fragment.DlgCertificateChanged
import com.tobykurien.webapps.fragment.DlgSaveWebapp
import com.tobykurien.webapps.utils.CertificateUtils
import com.tobykurien.webapps.utils.FaviconHandler
import com.tobykurien.webapps.utils.Settings
import com.tobykurien.webapps.webviewclient.WebClient
import com.tobykurien.webapps.webviewclient.WebViewUtils
import java.util.ArrayList
import java.util.List
import java.util.Set
import org.xtendroid.utils.AsyncBuilder

import static extension com.tobykurien.webapps.utils.Dependencies.*
import static extension org.xtendroid.utils.AlertUtils.*
import com.tobykurien.webapps.fragment.PreferencesFragment

/**
 * Extensions to the main activity for Android 3.0+, or at least it used to be.
 * Now the core functionality is in the base class and the UI-related stuff is
 * here.
 * 
 * @author toby
 */
@TargetApi(Build.VERSION_CODES.HONEYCOMB)
public class WebAppActivity extends BaseWebAppActivity {
	val static DEFAULT_FONT_SIZE = 2 // "normal" font size value from arrays.xml
	// variables to track dragging for actionbar auto-hide
	var protected float startX;
	var protected float startY;

	var private MenuItem stopMenu = null;
	var private MenuItem imageMenu = null;
	var private MenuItem shortcutMenu = null;
	var private Bitmap unsavedFavicon = null;

	override onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// setup actionbar
		val ab = getSupportActionBar();
		ab.setDisplayShowTitleEnabled(false);
		ab.setDisplayShowCustomEnabled(true);
		ab.setDisplayHomeAsUpEnabled(true);
		ab.setCustomView(R.layout.actionbar_favicon);

		registerForContextMenu(wv)

		wv.onLongClickListener = [
			var url = wv.hitTestResult.extra
			if (url !== null) {
				var i = new Intent(Intent.ACTION_VIEW);
				i.setData(Uri.parse(url));
				i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				i.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
				var chooser = Intent.createChooser(i, getString(R.string.title_open_with))
				if (i.resolveActivity(getPackageManager()) != null) {
				    context.startActivity(chooser);
				}
				return true;
			}
			
			return false
		]

		// load a favico if it already exists
		val iconImg = supportActionBar.customView.findViewById(R.id.favicon) as ImageView;
		iconImg.imageResource = R.drawable.ic_action_site
		val iconHandler = new FaviconHandler(this)
		WebappsAdapter.loadFavicon(this, iconHandler.getFavIcon(webappId), iconImg)
		iconHandler.deleteFavIcon(webappId)
	}

	override protected onResume() {
		super.onResume()

		MainActivity.handleFullscreenOptions(this)

		if (settings.shouldHideActionBar(fromShortcut)) {
			supportActionBar.hide();
			wv.setOnTouchListener = null
		} else {
			autohideActionbar();
		}
	}

	override protected onPause() {
		super.onPause()

		if (webappId < 0) {
			// clean up data left behind by this webapp
			clearWebviewCache(wv)
		}
	}

	override onCreateContextMenu(ContextMenu menu, View v, ContextMenuInfo menuInfo) {
		super.onCreateContextMenu(menu, v, menuInfo)

		// signifies a long-press on whitespace or text
		if (settings.shouldHideActionBar(fromShortcut)) {
			var ab = supportActionBar
			if (ab.isShowing) ab.hide else ab.show
		}
	}

	override onCreateOptionsMenu(Menu menu) {
		// super.onCreateOptionsMenu(menu);
		var inflater = getMenuInflater();
		inflater.inflate(R.menu.webapps_menu, menu);

		stopMenu = menu.findItem(R.id.menu_stop);
		imageMenu = menu.findItem(R.id.menu_image);
		imageMenu.setChecked(Settings.getSettings(this).isLoadImages());
		updateImageMenu();

		shortcutMenu = menu.findItem(R.id.menu_shortcut);
		if (webappId < 0) {
			shortcutMenu.enabled = false;
		}

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
					if (imageMenu.isChecked()) {
						toast(getString(R.string.toast_images_enabled))
					} else {
						toast(getString(R.string.toast_images_disabled))
					}
					updateImageMenu();
					setupWebView();
				}
				return true;
			}
			case R.id.menu_font_size: {
				showFontSizeDialog()
				return true;
			}
			case R.id.menu_user_agent: {
				showUserAgentDialog()
				return true;
			}
			case R.id.menu_certificate: {
				showCertificateDetails()
				return true;
			}
			case R.id.menu_share: {
				var share = new Intent(Intent.ACTION_SEND)
				share.setType("text/plain")
				share.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET)
				share.putExtra(Intent.EXTRA_SUBJECT, webapp.name);
				share.putExtra(Intent.EXTRA_TEXT, wv.url);

				startActivity(Intent.createChooser(share, getString(R.string.menu_share)));
				return true;
			}
			case R.id.menu_shortcut: {
				addShortcut();
				return true;
			}
			case R.id.menu_settings: {
				var i = new Intent(this, Preferences);
				startActivity(i);
				return true;
			}
			case R.id.menu_exit: {
				Runtime.getRuntime().exit(0); // hard exit
				return true;
			}
		}

		return super.onOptionsItemSelected(item);
	}

	override onFullscreenChanged(boolean isFullscreen) {
		super.onFullscreenChanged(isFullscreen)

		if (isFullscreen && supportActionBar.isShowing) {
			// always hide the action bar in fullscreen (video) mode
			supportActionBar.hide()
		}

		if (!isFullscreen && !settings.isHideActionbar && !settings.isFullHideActionbar) {
			// un-hide the action bar when coming out of fullscreen
			supportActionBar.show()
		}
	}

	def showFontSizeDialog() {
		val int fontSize = if(webapp.fontSize >= 0) webapp.fontSize else DEFAULT_FONT_SIZE
		new AlertDialog.Builder(this)
			.setTitle(R.string.menu_text_size)
			.setSingleChoiceItems(R.array.text_sizes, fontSize, [ dlg, value |
				WebViewUtils.instance.setTextSize(wv, value)
				webapp.fontSize = value
			])
			.setPositiveButton(android.R.string.ok, [ dlg, i |
				// save font size
				if (webappId > 0) {
					db.update(DbService.TABLE_WEBAPPS, #{
						'fontSize' -> webapp.fontSize
					}, webappId)
				}
	
				dlg.dismiss
			])
			.create()
			.show()
	}

	def showUserAgentDialog() {
		val String userAgent = if(webapp.userAgent != null) webapp.userAgent else settings.userAgent
		val iUserAgent = resources.getStringArray(R.array.user_agent_strings).indexOf(userAgent)
		new AlertDialog.Builder(this)
			.setTitle(R.string.menu_user_agent)
			.setSingleChoiceItems(R.array.user_agents, iUserAgent, [ dlg, value |
				webapp.userAgent = resources.getStringArray(R.array.user_agent_strings).get(value)
				wv.settings.userAgentString = webapp.userAgent
			])
			.setPositiveButton(android.R.string.ok, [ dlg, i |
				if (webapp.userAgent.equals("Custom")) {
					PreferencesFragment.promptUA(WebAppActivity.this) [ newUA |
						webapp.userAgent = newUA
						wv.settings.userAgentString = webapp.userAgent

						// save user agent
						if (webappId > 0) {
							db.update(DbService.TABLE_WEBAPPS, #{
								'userAgent' -> webapp.userAgent
							}, webappId)
							wv.reload()
						}
		
						dlg.dismiss
					]
				} else {
					// save user agent
					if (webappId > 0) {
						db.update(DbService.TABLE_WEBAPPS, #{
							'userAgent' -> webapp.userAgent
						}, webappId)
						wv.reload()
					}
	
					dlg.dismiss
				}
			])
			.create()
			.show()
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

		val domain = WebClient.getRootDomain(webapp.url)
		val cookies = CookieManager.instance.getCookie(webapp.url)
		if (webapp != null && cookies != null && webapp.id > 0 &&
				!cookies.equals(webapp.cookies)) {
			db.saveCookies(webapp)
		}

		// alert the user if SSL certificate has changed since last time
		// TODO - security issue: if this is MITM, cookies already sent!
		if (webapp != null && wv.certificate != null) {
			if (webapp.certIssuedBy != null) {
				if (CertificateUtils.compare(webapp, wv.certificate) != 0) {
					// SSL certificate changed!
					var dlg = new DlgCertificateChanged(webapp, wv.certificate,
						getString(R.string.title_cert_changed),
						getString(R.string.cert_accept), [
							CertificateUtils.updateCertificate(webapp, wv.certificate, db)
							true
						], [
							finish
							true
						])
					dlg.show(supportFragmentManager, "certificate")
				}
			} else {
				CertificateUtils.updateCertificate(webapp, wv.certificate, db)
			}
		}

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
		if (webappId >= 0) {
			AsyncBuilder.async [ builder, params |
				new FaviconHandler(this).saveFavIcon(webappId, icon)
				return true
			].onError [ ex |
				Log.e("favicon", "error saving icon", ex)
			].start()
		} else {
			unsavedFavicon = icon
		}
	}

	/**
	 * Show a dialog to the user to allow saving a webapp
	 */
	def private void dlgSave() {
		var dlg = new DlgSaveWebapp(
						webappId, wv.getTitle(), wv.getUrl(), 
						wv.certificate,
						unblock);

		val isNewWebapp = if(webappId < 0) true else false;

		dlg.setOnSaveListener [ wapp |
			putWebappId(wapp.id)
			webapp = wapp

			// save any unblocked domains and cookies
			if (isNewWebapp) {
				saveWebappUnblockList(webappId, unblock)
				db.saveCookies(webapp)
			}

			// if we have unsaved icon, save it
			if (unsavedFavicon != null) {
				onReceivedFavicon(wv, unsavedFavicon)
				unsavedFavicon = null
			}

			shortcutMenu.enabled = true;
			shortcutMenu.visible = true;

			return null
		]

		dlg.show(getSupportFragmentManager(), "save");
	}

	/**
	 * Show a dialog to allow user to unblock or re-block third party domains
	 */
	def private void dlg3rdParty() {
		AsyncBuilder.async [ builder, params |
			// get the saved list of whitelisted domains
			db.findByFields(DbService.TABLE_DOMAINS, #{
				"webappId" -> webappId
			}, null, ThirdPartyDomain)
		].then [ List<ThirdPartyDomain> whitelisted |
			// add all whitelisted domains
			val domains = new ArrayList(whitelisted.map[domain])
			val whitelist = new ArrayList(domains.map[true])

			// add all blocked domains
			for (blockedDomain : wc.getBlockedHosts()) {
				val d = WebClient.getRootDomain(blockedDomain)
				if(d !== null && !domains.contains(d)) {
					domains.add(d)
					whitelist.add(false)
				}
			}

			// show blocked 3rd party domains and allow user to allow them
			new AlertDialog.Builder(this)
				.setTitle(R.string.blocked_root_domains)
				.setMultiChoiceItems(domains, whitelist, [ d, pos, checked |
					if (checked) {
						unblock.add(domains.get(pos).intern());
					} else {
						unblock.remove(domains.get(pos).intern());
					}
					Log.d("unblock", unblock.toString)
				])
				.setPositiveButton(R.string.unblock, [ d, pos |
					saveWebappUnblockList(webappId, unblock)
					wc.unblockDomains(unblock);
					clearWebviewCache(wv)
					wv.reload();
					d.dismiss();
				])
				.create()
				.show();
		].onError [ Exception e |
			toast(e.class.name + " " + e.message)
		].start()
	}
	
	def showCertificateDetails() {
		var dlg = new DlgCertificate(wv.certificate)
		dlg.show(supportFragmentManager, "certificate")
	}

	def clearWebviewCache(WebView wv) {
		// this is disabled as it will clear all existing cache when opening a new webapp
//		wv.clearCache(true);
//		deleteDatabase("webview.db");
//		deleteDatabase("webviewCache.db");
	}

	def void saveWebappUnblockList(long webappId, Set<String> unblock) {
		if (webappId >= 0) {
			AsyncBuilder.async [ builder, params |
				// save the unblock list
				// clear current list
				db.execute(R.string.dbDeleteDomains, #{"webappId" -> webappId});

				if (unblock != null && unblock.size() > 0) {
					// add new items
					for (domain : unblock) {
						if (!WebClient.getHost(webapp.url).equals(domain)) {
							db.insert(DbService.TABLE_DOMAINS, #{
								"webappId" -> webappId,
								"domain" -> domain
							});
						}
					}
				}

				return null
			].start()
		}
	}

	/**
	 * Attempt to make the actionBar auto-hide and auto-reveal based on drag
	 * 
	 * @param activity
	 * @param wv
	 */
	def void autohideActionbar() {
		wv.setOnTouchListener [ view, event |
			if (settings.isHideActionbar()) {
				if (event.getAction() == MotionEvent.ACTION_DOWN) {
					startY = event.getY();
				}

				if (event.getAction() == MotionEvent.ACTION_MOVE) {
					// avoid juddering by waiting for large-ish drag
					if (Math.abs(startY - event.getY()) > new ViewConfiguration().getScaledTouchSlop() * 5) {
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

	def addShortcut() {
		val shortcut = ShortcutActivity.getShortcut(this, webapp)
		ShortcutManagerCompat.requestPinShortcut(this, shortcut.build(), null)
		toast(getString(R.string.msg_shortcut_added))
	}
}
