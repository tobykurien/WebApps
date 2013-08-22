package com.tobykurien.webapps.db;

import android.content.Context;
import asia.sonix.android.orm.AbatisService;
import com.tobykurien.webapps.R.string;
import com.tobykurien.webapps.data.Webapp;
import java.util.List;

@SuppressWarnings("all")
public class DbService extends AbatisService {
  protected DbService(final Context context) {
    super(context, "webapps2", 1);
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
