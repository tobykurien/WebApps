package com.tobykurien.webapps.activity

import android.annotation.TargetApi
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.support.v7.app.AppCompatActivity
import android.util.Log
import android.view.KeyEvent
import android.view.View
import android.webkit.ClientCertRequest
import android.webkit.CookieSyncManager
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebChromeClient.FileChooserParams
import android.webkit.WebView
import android.widget.ProgressBar
import com.tobykurien.webapps.R
import com.tobykurien.webapps.data.Webapp
import com.tobykurien.webapps.db.DbService
import com.tobykurien.webapps.utils.Settings
import com.tobykurien.webapps.webviewclient.WebClient
import com.tobykurien.webapps.webviewclient.WebViewUtils
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Date
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Map
import java.util.Set
import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate

import static extension com.tobykurien.webapps.utils.Dependencies.*
import static extension org.xtendroid.utils.AlertUtils.*
import org.xtendroid.annotations.BundleProperty

@TargetApi(21)
@AndroidActivity(R.layout.webapp) class BaseWebAppActivity extends AppCompatActivity {
	// Required intent arguments
	@BundleProperty package long webappId = -1

	public static boolean reload = false
	package WebView wv = null
	package Uri siteUrl = null
	package WebClient wc = null
	package Webapp webapp = null
	package Set<String> unblock = new HashSet<String>

	val static int FILECHOOSER_RESULTCODE = 101
	val static int REQUEST_SELECT_FILE = 102
	private ValueCallback<Uri> mUploadMessage;
	private ValueCallback<Uri[]> mUploadMessage2;
	private String mCameraPhotoPath;

	/**
	 * Called when the activity is first created.
	 */
	@OnCreate
	def void init(Bundle savedInstanceState) {
		wv = siteWebview
		if (wv === null) {
			finish()
			return;
		}

		siteUrl = intent?.data
		if (siteUrl == null) return;

		if (webappId >= 0) {
			webapp = db.findById(DbService.TABLE_WEBAPPS, webappId, Webapp)
			if (webapp == null) {
				toast(getString(R.string.err_webapp_not_found))
				finish()
				return;
			}
		} else {
			webapp = new Webapp()
			webapp.url = siteUrl.toString
			webapp.name = webapp.url
		}

		val pb = siteProgress
		if(pb !== null) pb.setVisibility(View.VISIBLE)

		setupWebView()
		wv.setWebViewClient(getWebViewClient(pb)) // save the favicon for later use if we get one
		wv.setWebChromeClient(
			new WebChromeClient() {
				override void onReceivedIcon(WebView view, Bitmap icon) {
					super.onReceivedIcon(view, icon)
					onReceivedFavicon(view, icon)
				}

				// openFileChooser for Android < 3.0
				def void openFileChooser(ValueCallback<Uri> uploadMsg) {
					openFileChooser(uploadMsg, "");
				}

				// openFileChooser for other Android versions
				def void openFileChooser(ValueCallback<Uri> uploadMsg, String acceptType, String capture) {
					openFileChooser(uploadMsg, acceptType);
				}

				override onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback,
					WebChromeClient.FileChooserParams fileChooserParams) {
					openFileChooserLollipop(filePathCallback, fileChooserParams)
				}
			})

		openSite(webapp.url)
	}

	def protected void setupWebView() {
		WebViewUtils.getInstance().setupWebView(this, wv, siteUrl, webapp,
			settings.getIntFontSize())
	}

	override protected void onResume() {
		super.onResume()
		CookieSyncManager.getInstance().startSync()
		if (reload) {
			reload = false
			setupWebView()
		}

	}

	override protected void onPause() {
		super.onPause()
		CookieSyncManager.getInstance().stopSync()
	}

	def void onReceivedFavicon(WebView view, Bitmap icon) {
	}

	def void onPageLoadStarted() {
	}

	def void onPageLoadDone() {
	}

	def void onClientCertificateRequest(ClientCertRequest request) {
	}

	/**
	 * Return the web view client for the web view
	 * @param pb
	 * @return
	 */
	def protected WebClient getWebViewClient(ProgressBar pb) {
		if (wc === null) {
			unblock = new HashSet<String>()
			unblock.add(siteUrl.getHost())
			if (webappId >= 0) {
				// load saved unblock list
				var domains = db.executeForMapList(R.string.dbGetDomainNames, #{
					"webappId" -> webappId
				})
				for (domain : domains) {
					unblock.add(domain.get("domain") as String)
				}
			}
			wc = new WebClient(this, webapp, wv, pb, unblock)
		}
		return wc
	}

	def void openSite(String url) {
		// TODO - use custom trust manager to stop the request if SSL cert changed
//		var SSLContext sslContext = SSLContext.getInstance("TLS");
//		sslContext.init(null, #[ new SslTrustManager(webapp) ], null);
// 		HttpsURLConnection.setDefaultSSLSocketFactory(sslContext.socketFactory);
		wv.loadUrl(url)
	}

	override boolean onKeyDown(int keyCode, KeyEvent event) {
		if ((keyCode === KeyEvent.KEYCODE_BACK) && wv.canGoBack()) {
			wv.goBack()
			return true
		}
		return super.onKeyDown(keyCode, event)
	}

	def openFileChooser(ValueCallback<Uri> uploadMsg, String acceptType) {
		Log.i("WebChromeClient", "openFileChooser() called.");
		
		if(mUploadMessage != null) mUploadMessage.onReceiveValue(null);
		mUploadMessage = uploadMsg;
		
		val intent = new Intent(Intent.ACTION_GET_CONTENT);
		intent.addCategory(Intent.CATEGORY_OPENABLE);
		intent.setType("*/*");
		startActivityForResult(Intent.createChooser(intent, "File Chooser"), FILECHOOSER_RESULTCODE);
		
		return true;
	}

	def openFileChooserLollipop(ValueCallback<Uri[]> filePathCallback, FileChooserParams fileChooserParams) {
		Log.i("WebChromeClient", "openFileChooserLollipop() called.");
		if (mUploadMessage2 != null) {
			mUploadMessage2.onReceiveValue(null);
		}
		mUploadMessage2 = filePathCallback;

		var takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
		if (takePictureIntent.resolveActivity(this.getPackageManager()) != null) {
			// Create the File where the photo should go
			var File photoFile = null;
			try {
				photoFile = createImageFile();
				takePictureIntent.putExtra("PhotoPath", photoFile.absolutePath);
			} catch (IOException ex) {
				// Error occurred while creating the File
				Log.e("base webapp activity", "Unable to create Image File", ex);
			}

			// Continue only if the File was successfully created
			if (photoFile != null) {
				mCameraPhotoPath = "file:" + photoFile.getAbsolutePath();
				takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(photoFile));
			} else {
				takePictureIntent = null;
			}
		}

		var contentSelectionIntent = new Intent(Intent.ACTION_GET_CONTENT);
		contentSelectionIntent.addCategory(Intent.CATEGORY_OPENABLE);
		contentSelectionIntent.setType("*/*");

		var Intent[] intentArray;
		if (takePictureIntent != null) {
			intentArray = newArrayList(takePictureIntent);
		} else {
			intentArray = newArrayList()
		}

		var chooserIntent = new Intent(Intent.ACTION_CHOOSER);
		chooserIntent.putExtra(Intent.EXTRA_INTENT, contentSelectionIntent);
		chooserIntent.putExtra(Intent.EXTRA_TITLE, "Image Chooser");
		chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, intentArray);
		startActivityForResult(chooserIntent, REQUEST_SELECT_FILE);

		return true
	}

	override protected onActivityResult(int requestCode, int resultCode, Intent intent) {
		try {
			if (requestCode == FILECHOOSER_RESULTCODE) {
				if(null == mUploadMessage) return;
				var result = if(intent == null || resultCode != RESULT_OK) null else intent.getData()
				mUploadMessage.onReceiveValue(result);
				mUploadMessage = null;
			} else if (requestCode == REQUEST_SELECT_FILE) {
				// Check that the response is a good one
				var Uri[] results = null;
				if (resultCode == RESULT_OK) {
					if (intent == null || intent.getDataString() == null) {
						// If there is not data, then we may have taken a photo
						if (mCameraPhotoPath != null) {
							results = #[Uri.parse(mCameraPhotoPath)];
						}
					} else {
						var String dataString = intent.getDataString();
						if (dataString != null) {
							val uri = Uri.parse(dataString);
							results = #[uri];

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
				}

				mUploadMessage2.onReceiveValue(results);
				mUploadMessage2 = null;
				mCameraPhotoPath = null
			} else {
				super.onActivityResult(requestCode, resultCode, intent)
			}
		} catch (Exception e) {
			toastLong("Unable to process: " + e.class.simpleName + " " + e.message)
		}
	}

	def static File createImageFile(Context context) throws IOException {
		// Create an image file name
		var String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
		var String imageFileName = "JPEG_" + timeStamp + '_';
		var File storageDir = context.cacheDir;
		return File.createTempFile(
			imageFileName, /* prefix */
			".jpg", /* suffix */
			storageDir /* directory */
		);
	}
}
