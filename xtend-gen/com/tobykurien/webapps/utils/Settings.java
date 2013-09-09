package com.tobykurien.webapps.utils;

import android.content.Context;
import com.tobykurien.xtendroid.annotations.Preference;
import com.tobykurien.xtendroid.utils.BasePreferences;
import org.eclipse.xtext.xbase.lib.Exceptions;

@SuppressWarnings("all")
public class Settings extends BasePreferences {
  @Preference
  private boolean block3rdParty = true;
  
  @Preference
  private String fontSize = "2";
  
  @Preference
  private String userAgent = "";
  
  public static Settings getSettings(final Context context) {
    BasePreferences _preferences = BasePreferences.getPreferences(context, Settings.class);
    return ((Settings) _preferences);
  }
  
  public int getIntFontSize() {
    int _xtrycatchfinallyexpression = (int) 0;
    try {
      String _fontSize = this.getFontSize();
      int _parseInt = Integer.parseInt(_fontSize);
      _xtrycatchfinallyexpression = _parseInt;
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception e = (Exception)_t;
        _xtrycatchfinallyexpression = 2;
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    return _xtrycatchfinallyexpression;
  }
  
  public boolean getBlock3rdParty() {
    return pref.getBoolean("block3rd_party", block3rdParty);
  }
  
  public boolean setBlock3rdParty() {
    pref.edit().putBoolean("block3rd_party", block3rdParty).commit();
    return true;
  }
  
  public String getFontSize() {
    return pref.getString("font_size", fontSize);
  }
  
  public boolean setFontSize() {
    pref.edit().putString("font_size", fontSize).commit();
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
