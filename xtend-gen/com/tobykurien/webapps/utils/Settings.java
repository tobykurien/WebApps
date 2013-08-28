package com.tobykurien.webapps.utils;

import android.content.Context;
import android.content.SharedPreferences;
import com.tobykurien.xtendroid.annotations.Preference;
import com.tobykurien.xtendroid.utils.BasePreferences;

@SuppressWarnings("all")
public class Settings extends BasePreferences {
  @Preference
  private boolean block3rdParty = true;
  
  @Preference
  private int fontSize = 2;
  
  @Preference
  private String userAgent = "";
  
  protected Settings(final SharedPreferences preferences) {
    super(preferences);
  }
  
  public static Settings getSettings(final Context context) {
    BasePreferences _preferences = BasePreferences.getPreferences(context);
    return ((Settings) _preferences);
  }
  
  public boolean getBlock3rdParty() {
    return pref.getBoolean("block3rd_party", block3rdParty);
    
  }
  
  public boolean setBlock3rdParty() {
    pref.edit().putBoolean("block3rd_party", block3rdParty).commit();
    return true;
    
  }
  
  public int getFontSize() {
    return pref.getInt("font_size", fontSize);
    
  }
  
  public boolean setFontSize() {
    pref.edit().putInt("font_size", fontSize).commit();
    return true;
    
  }
  
  public String getUserAgent() {
    return pref.getString("user_agent", userAgent);
    
  }
  
  public boolean setUserAgent() {
    pref.edit().putString("user_agent", userAgent).commit();
    return true;
    
  }
}
