package com.tobykurien.webapps.db

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.net.Uri
import android.util.Log
import android.webkit.CookieManager
import com.tobykurien.webapps.data.Webapp
import com.tobykurien.webapps.utils.Debug
import java.io.File
import java.io.FileReader
import java.io.FileWriter
import java.util.List
import org.xtendroid.db.BaseDbService
import java.io.BufferedWriter
import java.io.ByteArrayOutputStream
import java.io.FileOutputStream
import java.io.FileInputStream
import com.tobykurien.webapps.webviewclient.WebClient

/**
 * Class to manage database queries. Uses Xtendroid's BaseDbService
 */
class DbService extends BaseDbService {
	public static val TABLE_WEBAPPS = "webapps"
	public static val TABLE_DOMAINS = "domain_names"

	protected new(Context context) {
		super(context, "webapps4", 6)
	}

	def static getInstance(Context context) {
		return new DbService(context)
	}

	override onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		super.onUpgrade(db, oldVersion, newVersion)

		if (oldVersion == 1 && newVersion == 2) {
			db.execSQL('''alter table «TABLE_WEBAPPS» add column fontSize integer default -1''')
		}

		if (oldVersion == 2 && newVersion == 3) {
			db.execSQL('''alter table «TABLE_WEBAPPS» add column userAgent text''')
		}

		if (oldVersion == 3 && newVersion == 4) {
			db.execSQL('''alter table «TABLE_WEBAPPS» add column certIssuedBy text''')
			db.execSQL('''alter table «TABLE_WEBAPPS» add column certIssuedTo text''')
			db.execSQL('''alter table «TABLE_WEBAPPS» add column certValidFrom text''')
			db.execSQL('''alter table «TABLE_WEBAPPS» add column certValidTo text''')
		}

		if (oldVersion == 4 && newVersion == 5) {
			db.execSQL('''alter table «TABLE_WEBAPPS» add column cookies text''')
		}

		if (oldVersion == 5 && newVersion == 6) {
			db.execSQL('''alter table «TABLE_WEBAPPS» add column allowLocation boolean''')
			db.execSQL('''alter table «TABLE_WEBAPPS» add column ignoreCertChanges boolean''')
		}
	}

	def List<Webapp> getWebapps() {
		findAll(TABLE_WEBAPPS, "lower(name) asc", Webapp)
	}

	def void saveCookies(Webapp webapp) {
		val domain = WebClient.getRootDomain(webapp.url)
		if(Debug.COOKIE) Log.d("cookie", "Saving cookies for " + domain)
		var cookiesStr = CookieManager.instance.getCookie("https://" + domain)

		if (cookiesStr != null) {
			if(Debug.COOKIE) Log.d("cookie", "Save -> " + cookiesStr)

			// Obfuscate Expires and Max-Age
			cookiesStr = cookiesStr.replaceAll("(?i)expires", "NoExp")
			cookiesStr = cookiesStr.replaceAll("(?i)max-age", "NoAge")

			update("webapps", #{
				"cookies" -> cookiesStr
			}, webapp.id)
		}
	}

	def exportDatabase(Context context) {
		val dbFile = context.getDatabasePath(databaseName)
		val outPath = new File(context.cacheDir.absolutePath + "/exports")
		outPath.mkdirs()
		val outFile = File.createTempFile("webapps", "backup.db", outPath)

		val byte[] buf = newByteArrayOfSize(1024);
		val fr = new FileInputStream(dbFile);
		val fw = new FileOutputStream(outFile)
		try {
			while (fr.read(buf) > 0) {
				fw.write(buf)
			}
		} finally {
			fr.close()
			fw.close()
		}

		outFile.deleteOnExit();
		return outFile;
	}

	def importDatabase(Context context, Uri uri) {
		close()
		
		// save Uri data to cacheDir
		val importDb = new File(context.dataDir.absolutePath + "/databases/" + databaseName)
		if (!importDb.exists) {
			throw new Exception("Cannot find existing database to overwrite at " + importDb.absolutePath)
		}

		val is = context.contentResolver.openInputStream(uri);
		if (is.available <= 0) {
			throw new Exception("Cannot read import database (or it's empty) at " + uri)			
		}

		val buf = newByteArrayOfSize(1024);
		val fw = new FileOutputStream(importDb);
		while (is.read(buf) > 0) {
			fw.write(buf)
		}
		is.close()
		fw.close()
		
		getWritableDatabase().close();
	}
}
