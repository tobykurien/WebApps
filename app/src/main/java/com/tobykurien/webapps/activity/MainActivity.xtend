package com.tobykurien.webapps.activity

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.support.v4.content.FileProvider
import android.support.v7.app.AlertDialog
import android.support.v7.app.AppCompatActivity
import android.text.Html
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.view.WindowManager
import android.webkit.CookieManager
import android.webkit.ValueCallback
import com.tobykurien.webapps.R
import com.tobykurien.webapps.adapter.WebappsAdapter
import com.tobykurien.webapps.data.Webapp
import com.tobykurien.webapps.db.DbService
import com.tobykurien.webapps.fragment.DlgOpenUrl
import com.tobykurien.webapps.utils.FaviconHandler
import com.tobykurien.webapps.webviewclient.WebViewUtils
import java.util.List
import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate
import org.xtendroid.utils.AsyncBuilder

import static extension com.tobykurien.webapps.utils.Dependencies.*
import static extension org.xtendroid.utils.AlertUtils.*
import com.tobykurien.webapps.utils.Debug

@AndroidActivity(R.layout.main) class MainActivity extends AppCompatActivity {
	var protected List<Webapp> webapps

	val static FILECHOOSER_RESULTCODE = 10;
	val static FILESAVE_RESULTCODE = 20;
	val static int REQUEST_SELECT_FILE = 102

	ValueCallback<Uri> mUploadMessage = [uri|
		// test and import the database
		db.importDatabase(this, uri)
		
		// restart
		this.recreate();
	];

	@OnCreate
	def init(Bundle savedInstanceState) {
		if (settings.isFullscreen()) {
			getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		}


		if (settings.secureWindows) {
		    val window = getWindow();
		    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE);
		}

		if (intent !== null && intent.getDataString() !== null) {
			DlgOpenUrl.openUrl(this, intent.getDataString(), false, false)
		} else if (intent !== null && intent.getStringExtra(Intent.EXTRA_TEXT) !== null) {
			DlgOpenUrl.openUrl(this, intent.getStringExtra(Intent.EXTRA_TEXT), false, false)
		}
	}

	override protected onStart() {
		super.onStart()

		val activity = this
		loadWebapps()

		mainList.setOnItemClickListener([ av, v, pos, id |
			WebAppActivity.allowRedirects = false				
			val item = av.getItemAtPosition(pos) as Webapp
			var intent = new Intent(activity, typeof(WebAppActivity))
			intent.action = Intent.ACTION_VIEW
			intent.data = Uri.parse(webapps.get(pos).url)
			BaseWebAppActivity.putWebappId(intent, item.id)
			BaseWebAppActivity.putFromShortcut(intent, false)
			startActivity(intent)
		])

		mainList.setOnItemLongClickListener([ av, v, pos, id |
			val item = av.getItemAtPosition(pos) as Webapp
			confirm(getString(R.string.delete_webapp) + " " + item.name + "?", [
				AsyncBuilder.async [ p1, p2 |
					db.execute(R.string.dbDeleteDomains, #{'webappId' -> item.id})
					db.delete(DbService.TABLE_WEBAPPS, String.valueOf(item.id))
					new FaviconHandler(this).deleteFavIcon(item.id)
					WebViewUtils.instance.deleteWebappData(this, item.id)
					null
				].then [
					loadWebapps
				].start
			])
			true
		])

		// show tips on first load
		if (settings.firstLoaded < 1) {
			settings.firstLoaded = 1
			showTips()
		}
	}

	override onResume() {
		super.onResume()
		handleFullscreenOptions(this)
	}

	override onCreateOptionsMenu(Menu menu) {
		menuInflater.inflate(R.menu.main_menu, menu)
		true
	}

	override onOptionsItemSelected(MenuItem item) {
		switch (item.itemId) {
			case R.id.menu_open: {
				var dlg = new DlgOpenUrl()
				dlg.show(supportFragmentManager, "open_url")
			}
			case R.id.menu_tips: {
				showTips()
			}
			case R.id.menu_settings: {
				var i = new Intent(this, Preferences)
				startActivity(i)
			}
			case R.id.menu_export: {
				confirm(getString(R.string.export_confirm)) [
					val outFile = db.exportDatabase(this)

					val uri = FileProvider.getUriForFile(getApplicationContext(), 
						if (Debug.ON) "com.tobykurien.webapps.debug.fileprovider" 
						else "com.tobykurien.webapps.fileprovider",
						outFile);
					grantUriPermission(getPackageName(), uri, Intent.FLAG_GRANT_READ_URI_PERMISSION);

					var exportIntent = new Intent(Intent.ACTION_SEND);
					exportIntent.setDataAndType(uri, "application/vnd.sqlite3");
					exportIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK;
					exportIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
					exportIntent.putExtra(Intent.EXTRA_STREAM, uri);
					startActivityForResult(Intent.createChooser(exportIntent, getString(R.string.export_chooser)),
						FILESAVE_RESULTCODE);
				]
			}
			case R.id.menu_import: {
				confirm(getString(R.string.import_confirm)) [
					val intent = new Intent(Intent.ACTION_GET_CONTENT);
					intent.addCategory(Intent.CATEGORY_OPENABLE);
					intent.setType("*/*");
					startActivityForResult(Intent.createChooser(intent, "File Chooser"), FILECHOOSER_RESULTCODE);
				]
			}
			case R.id.menu_exit:
				finish()
		}
		super.onOptionsItemSelected(item)
	}

	override protected onActivityResult(int requestCode, int resultCode, Intent intent) {
		try {
			if (requestCode === FILECHOOSER_RESULTCODE) {
				if(null === mUploadMessage) return;
				var result = if(intent === null || resultCode !== RESULT_OK) null else intent.getData()
				mUploadMessage.onReceiveValue(result);
				mUploadMessage = null;
			} else if (requestCode === REQUEST_SELECT_FILE) {
				// Check that the response is a good one
				var Uri result = null;
				if (resultCode === RESULT_OK) {
					var String dataString = intent.getDataString();
					if (dataString !== null) {
						val uri = Uri.parse(dataString);
						result = uri;
	
						try {
							// as per https://developer.android.com/guide/topics/providers/document-provider.html#permissions
							val int takeFlags = intent.getFlags().bitwiseAnd(Intent.FLAG_GRANT_READ_URI_PERMISSION)
							// Check for the freshest data.
							getContentResolver().takePersistableUriPermission(uri, takeFlags);
						} catch (Exception e) {
							// couldn't get persistable permissions, aaah well.
							Log.e("upload", "error taking persistable permission", e)
						}
					}
				}

				mUploadMessage.onReceiveValue(result);
			} else {
				super.onActivityResult(requestCode, resultCode, intent)
			}
		} catch (Exception e) {
			toastLong("Unable to process: " + e.class.simpleName + " " + e.message)
		}
	}

	def showTips() {
		new AlertDialog.Builder(this).setTitle(R.string.action_tips).setMessage(
			Html.fromHtml(getString(R.string.tips))).setPositiveButton(android.R.string.ok, null).setNeutralButton(
			R.string.btn_website, [
				DlgOpenUrl.openUrl(this, "https://github.com/tobykurien/webapps", false, false)
			]).create().show()
	}

	def loadWebapps() {
		webapps = db.getWebapps()
		var adapter = new WebappsAdapter(this, webapps)
		mainList.setAdapter(adapter)

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
			try {
				if (!settings.cookiesImported && webapps !== null) {
					// import old cookies from WebView into our new db storage
					for (webapp : webapps) {
						db.saveCookies(webapp)
					}

					settings.cookiesImported = true

					// now we can delete all cookies from WebView
					CookieManager.instance.removeAllCookie()
				}
			} catch (Exception e) {
				toast("Error importing old cookies " + e.class.name + " - " + e.message)
			}
		}
	}

	def static handleFullscreenOptions(Activity activity) {
		if (activity.settings.isFullscreen()) {
			val decorView = activity.getWindow().getDecorView();
			if (activity.settings.isFullscreenImmersive()) {
				decorView.setSystemUiVisibility(
					View.SYSTEM_UI_FLAG_IMMERSIVE.bitwiseOr(View.SYSTEM_UI_FLAG_FULLSCREEN).bitwiseOr(
						View.SYSTEM_UI_FLAG_HIDE_NAVIGATION)
				);
			} else {
				decorView.setSystemUiVisibility(
					View.SYSTEM_UI_FLAG_FULLSCREEN
				);
			}
		}
	}
}
