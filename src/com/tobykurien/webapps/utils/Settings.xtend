package com.tobykurien.webapps.utils

import android.content.Context
import android.content.SharedPreferences
import com.tobykurien.xtendroid.annotations.Preference
import com.tobykurien.xtendroid.utils.BasePreferences

class Settings extends BasePreferences {
   @Preference boolean block3rdParty = true
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