package com.tobykurien.webapps.utils

import android.content.Context
import com.tobykurien.webapps.db.DbService

class Dependencies {
   def static DbService getDb(Context context) {
      return DbService.getInstance(context)
   }
   
   def static Settings getSettings(Context context) {
      return Settings.getPreferences(context) as Settings
   }
}