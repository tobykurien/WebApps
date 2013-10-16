package com.tobykurien.webapps.utils;

import android.content.Context;
import com.tobykurien.webapps.db.DbService;
import com.tobykurien.webapps.utils.Settings;
import org.xtendroid.utils.BasePreferences;

@SuppressWarnings("all")
public class Dependencies {
  public static DbService getDb(final Context context) {
    return DbService.getInstance(context);
  }
  
  public static Settings getSettings(final Context context) {
    BasePreferences _preferences = Settings.getPreferences(context, Settings.class);
    return ((Settings) _preferences);
  }
}
