package com.tobykurien.webapps.utils

import android.content.Context
import org.xtendroid.annotations.Preference
import org.xtendroid.utils.BasePreferences

class Settings extends BasePreferences {
   @Preference boolean block3rdParty = true
   @Preference boolean blockHttp = true
   @Preference String fontSize = "2"
   @Preference String userAgent = ""
   @Preference boolean fullscreen = false
   @Preference boolean hideActionbar = true
   
   // for backward compatibility
   def static Settings getSettings(Context context) {
      return getPreferences(context, typeof(Settings)) as Settings
   }
   
   def getIntFontSize() {
         2
      }
}
