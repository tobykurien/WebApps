package com.tobykurien.webapps.db;

import android.content.Context;
import com.tobykurien.webapps.R.string;
import com.tobykurien.webapps.data.Webapp;
import com.tobykurien.xtendroid.db.BaseDbService;
import java.util.List;

@SuppressWarnings("all")
public class DbService extends BaseDbService {
  public final static String TABLE_WEBAPPS = "webapps";
  
  public final static String TABLE_DOMAINS = "domain_names";
  
  protected DbService(final Context context) {
    super(context, "webapps4", 1);
  }
  
  public static DbService getInstance(final Context context) {
    DbService _dbService = new DbService(context);
    return _dbService;
  }
  
  public List<Webapp> getWebapps() {
    List<Webapp> _executeForBeanList = this.<Webapp>executeForBeanList(string.dbGetWebapps, null, Webapp.class);
    return _executeForBeanList;
  }
}
