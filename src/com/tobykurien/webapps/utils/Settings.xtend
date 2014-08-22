package com.tobykurien.webapps.utils

import org.xtendroid.annotations.AndroidPreference
import org.xtendroid.utils.BasePreferences

@AndroidPreference class Settings extends BasePreferences {
   boolean block3rdParty = true
   boolean blockHttp = true
   String fontSize = "2"
   String userAgent = ""
   boolean fullscreen = false
   boolean hideActionbar = true
   
   def getIntFontSize() {
      try {
         Integer.parseInt(getFontSize())
      } catch (Exception e) {
         2
      }
   }
}