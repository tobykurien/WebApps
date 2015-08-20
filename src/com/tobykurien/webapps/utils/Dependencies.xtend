package com.tobykurien.webapps.utils

import android.content.Context
import com.tobykurien.webapps.db.DbService

/**
 * Singleton factory for commonly used dependencies like database and shared preferences.
 */
class Dependencies {
   def static DbService getDb(Context context) {
      return DbService.getInstance(context)
   }
   
   def static Settings getSettings(Context context) {
      return Settings.getPreferences(context, Settings) as Settings
   }
}