package com.tobykurien.webapps.utils

import android.content.Context
import org.xtendroid.utils.BasePreferences
import org.xtendroid.annotations.Preference

class Settings extends BasePreferences {
   @Preference boolean block3rdParty = true
   @Preference boolean blockHttp = true
   @Preference String fontSize = "2"
   @Preference String userAgent = ""
   
   // for backward compatibility
   def static Settings getSettings(Context context) {
      return getPreferences(context, typeof(Settings)) as Settings
   }
   
   def getIntFontSize() {
      try {
         Integer.parseInt(getFontSize())
      } catch (Exception e) {
         2
      }
   }
}