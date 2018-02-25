package com.tobykurien.webapps.db

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.webkit.CookieSyncManager
import com.tobykurien.webapps.data.Webapp
import java.util.List
import org.xtendroid.db.BaseDbService
import android.util.Log
import android.webkit.CookieManager
import com.tobykurien.webapps.utils.Debug

/**
 * Class to manage database queries. Uses Xtendroid's BaseDbService
 */
class DbService extends BaseDbService {
	public static val TABLE_WEBAPPS = "webapps"
	public static val TABLE_DOMAINS = "domain_names"

	protected new(Context context) {
		super(context, "webapps4", 5)
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
	}

	def List<Webapp> getWebapps() {
		findAll(TABLE_WEBAPPS, "lower(name) asc", Webapp)
	}

	def void saveCookies(Webapp webapp) {
		if (Debug.COOKIE) Log.d("cookie", "Saving cookies for " + webapp.url)
		var cookiesStr = CookieManager.instance.getCookie(webapp.url)
		if (cookiesStr != null) {
			update("webapps", #{
				"cookies" -> cookiesStr
			}, webapp.id)
		}
	}
}