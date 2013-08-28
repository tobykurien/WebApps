package com.tobykurien.webapps.utils

import android.content.Context
import android.content.SharedPreferences
import com.tobykurien.xtendroid.annotations.Preference
import com.tobykurien.xtendroid.utils.BasePreferences

class Settings extends BasePreferences {
   @Preference boolean block3rdParty = true
   @Preference int fontSize = 2
   @Preference String userAgent = ""
   
   protected new(SharedPreferences preferences) {
      super(preferences);
   }
   
   // for backward compatability
   def static getSettings(Context context) {
      return getPreferences(context) as Settings
   }
}