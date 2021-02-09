package com.tobykurien.webapps.activity;

import android.annotation.TargetApi
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.drawable.ColorDrawable
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.AsyncTask
import android.os.Message
import android.os.Handler
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
import com.tobykurien.webapps.fragment.PreferencesFragment
import com.tobykurien.webapps.utils.CertificateUtils
import com.tobykurien.webapps.utils.FaviconHandler
import com.tobykurien.webapps.utils.Settings
import com.tobykurien.webapps.utils.Debug
import com.tobykurien.webapps.webviewclient.WebClient
import com.tobykurien.webapps.webviewclient.WebViewUtils
import java.io.File
import java.util.ArrayList
import java.util.List
import java.util.Set
import org.xtendroid.utils.AsyncBuilder
import android.app.ActivityManager.TaskDescription;

import static extension com.tobykurien.webapps.utils.Dependencies.*
import static extension org.xtendroid.utils.AlertUtils.*
import org.xtendroid.annotations.BundleProperty

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
	var private Bitmap favIcon = null;
	val iconHandler = new FaviconHandler(this)

	// A globally accessible flag to check if redirects are temporarily allowed
	// This should only be enabled from DlgOpenUrl, and should be set to false
	// as soon as user switches away from webapps, hence not affecting other webapps.
	// Done this way to avoid having to pass this boolean around a lot of places!
	var public static boolean allowRedirects = false;

	override onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		if (settings.secureWindows) {
		    val window = getWindow();
		    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE);
		}

		// setup actionbar
		val ab = getSupportActionBar();
		ab.setDisplayShowTitleEnabled(false);
		ab.setDisplayShowCustomEnabled(true);
		ab.setDisplayHomeAsUpEnabled(true);
		ab.setCustomView(R.layout.actionbar_favicon);

		registerForContextMenu(wv)

		wv.onLongClickListener = [
			var url = wv.hitTestResult.extra

			if (wv.hitTestResult.type == WebView.HitTestResult.UNKNOWN_TYPE ||
				wv.hitTestResult.type == WebView.HitTestResult.SRC_ANCHOR_TYPE ||
				wv.hitTestResult.type == WebView.HitTestResult.IMAGE_TYPE ||
				wv.hitTestResult.type == WebView.HitTestResult.SRC_IMAGE_ANCHOR_TYPE) {
				val Message message = new Message();
			    message.setTarget(new Handler()[msg|
			        var String title = msg.getData().getString("title");
					if (title === null) title = msg.getData().getString("alt");
					if (title === null) title = webapp.name;

			        var String href = msg.getData().getString("url");
					if (href === null) href = msg.getData().getString("href");
					if (href === null) href = msg.getData().getString("src");

					if (href !== null) {
						shareURL(href, title);
						return true;
					}
				]);
    			wv.requestFocusNodeHref(message);
			} else if (url !== null) {
				shareURL(url, webapp.name);
				return true;
			}
			
			return false
		]

		// load a favico if it already exists
		val favIcon = iconHandler.getFavIcon(webapp.id)
		updateActionBar(favIcon)
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

		if (webapp.id < 0) {
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
		if (webapp.id < 0) {
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
				shareURL(wv.url, webapp.name);
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
			case R.id.menu_reset: {
				confirm(getString(R.string.reset_confirm)) [
					webapp.ignoreCertChanges = null
					webapp.allowLocation = null
					if (webapp.id > 0) db.execute(R.string.dbResetWebapp, #{"webappId" -> webapp.id})
				]
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
				if (webapp.id > 0) {
					db.update(DbService.TABLE_WEBAPPS, #{
						'fontSize' -> webapp.fontSize
					}, webapp.id)
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
						if (webapp.id > 0) {
							db.update(DbService.TABLE_WEBAPPS, #{
								'userAgent' -> webapp.userAgent
							}, webapp.id)
							wv.reload()
						}
		
						dlg.dismiss
					]
				} else {
					// save user agent
					if (webapp.id > 0) {
						db.update(DbService.TABLE_WEBAPPS, #{
							'userAgent' -> webapp.userAgent
						}, webapp.id)
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

		favIcon = null
	}

	override onPageLoadDone() {
		super.onPageLoadDone();

		val domain = WebClient.getRootDomain(webapp.url)
		val cookies = CookieManager.instance.getCookie("https://" + domain)
		if (webapp != null && cookies != null && webapp.id > 0 &&
				!cookies.equals(webapp.cookies)) {
			db.saveCookies(webapp)
		}

		// alert the user if SSL certificate has changed since last time
		// TODO - security issue: if this is MITM, cookies already sent!
		if (webapp != null && wv.certificate != null && webapp.ignoreCertChanges !== true) {
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
						], [
							// Allow user to permanently disable certificate checks
							confirm(getString(R.string.confirm_cert_disable)) [
								webapp.ignoreCertChanges = true
								if (webapp.id > 0) db.update(DbService.TABLE_WEBAPPS, #{
									'ignoreCertChanges' -> webapp.ignoreCertChanges
								}, webapp.id)
							]
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

	val saveFavIconTask = AsyncBuilder.async [ builder, params |
			Thread.sleep(1000) // wait till all icons are received, hopefully
			return true
		].then[
			if (webapp.id >= 0 && favIcon !== null) {
				iconHandler.saveFavIcon(webapp.id, favIcon)
			} else {
				unsavedFavicon = favIcon
			}
		].onError [ ex |
			Log.e("favicon", "error saving icon", ex)
		]

	override onReceivedFavicon(WebView view, Bitmap icon) {
		super.onReceivedFavicon(view, icon)
		var iconImg = supportActionBar.customView.findViewById(R.id.favicon) as ImageView;

		// This callback is called multiple times for each received icon, of which there may be none or many,
		// of varying resolutions, at some *arbitrary* time, **AFTER** page load!

		if (Debug.FAVICON) Log.d("favicon", "onReceivedFavicon " + icon.width)
		if (favIcon === null || favIcon.width < icon.width || 
			favIcon.height < icon.height) {
			favIcon = icon;
			iconImg.setImageBitmap(icon);
		}

		if (saveFavIconTask.status === AsyncTask.Status.PENDING) {
			saveFavIconTask.start();
		}
	}

	/**
	 * Show a dialog to the user to allow saving a webapp
	 */
	def private void dlgSave() {
		var dlg = new DlgSaveWebapp(
						webapp.id, wv.getTitle(), wv.getUrl(), 
						wv.certificate,
						unblock);

		val isNewWebapp = if(webapp.id < 0) true else false;

		dlg.setOnSaveListener [ wapp |
			putWebappId(wapp.id)
			webapp = wapp

			// save any unblocked domains and cookies
			if (isNewWebapp) {
				saveWebappUnblockList(webapp.id, unblock)
				db.saveCookies(webapp)
			}

			// if we have unsaved icon, save it
			if (unsavedFavicon != null) {
				iconHandler.saveFavIcon(webapp.id, unsavedFavicon)
				unsavedFavicon = null
			}

			shortcutMenu.enabled = true;
			shortcutMenu.visible = true;

			// this is temporary and is disabled as soon as user saves the webapp
			allowRedirects = false				

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
				"webappId" -> webapp.id
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
					if (Debug.ON) Log.d("unblock", unblock.toString)
				])
				.setPositiveButton(R.string.unblock, [ d, pos |
					saveWebappUnblockList(webapp.id, unblock)
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
	
	def updateActionBar(File favIcon) {
		val iconImg = supportActionBar.customView.findViewById(R.id.favicon) as ImageView;
		iconImg.imageResource = R.drawable.ic_action_site
		WebappsAdapter.loadFavicon(this, favIcon, iconImg)
		val colour = FaviconHandler.getDominantColor(favIcon)
		supportActionBar.backgroundDrawable = new ColorDrawable(colour)
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
		    val window = getWindow();
		    window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
		    window.setStatusBarColor(colour);
		}	

		val taskDesc = new TaskDescription(webapp.name, BitmapFactory.decodeFile(favIcon.absolutePath), colour);
		setTaskDescription(taskDesc);
	}

	def shareURL(String shareUrl, String shareTitle) {
		var share = new Intent(Intent.ACTION_SEND)
		share.setType("text/plain")		
		share.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET)
		share.putExtra(Intent.EXTRA_SUBJECT, shareTitle);
		share.putExtra(Intent.EXTRA_TEXT, shareUrl);
		startActivity(Intent.createChooser(share, getString(R.string.menu_share)));
	}	
}
