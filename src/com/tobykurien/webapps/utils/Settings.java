package com.tobykurien.webapps.utils;

import java.util.HashMap;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.widget.Toast;

public class Settings {
	private SharedPreferences pref;
	
	private Settings(SharedPreferences preferences) {
		pref = preferences;
	}
	
	/**
	 * Factory method to cache instances of settings class, since it's called a lot.
	 * @param preferences
	 * @return
	 */
	public static Settings getSettings(Context context) {
      SharedPreferences preferences =  PreferenceManager.getDefaultSharedPreferences(context.getApplicationContext());
      return new Settings(preferences);
	}

   public boolean isBlock3rdParty() {
      return pref.getBoolean("block_3rd_party", true);
   }
   
   public int getFontSize() {
      try {
         return Integer.parseInt(pref.getString("font_size", "2"));
      } catch (Exception e) {
         return 2;
      }
   }
   
   public String getUserAgent() {
      return pref.getString("user_agent", "");
   }   
   
}