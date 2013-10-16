package com.tobykurien.webapps.db

import android.content.Context
import com.tobykurien.webapps.R
import com.tobykurien.webapps.data.Webapp
import java.util.List
import org.xtendroid.db.BaseDbService

class DbService extends BaseDbService {
   public static val TABLE_WEBAPPS = "webapps"
   public static val TABLE_DOMAINS = "domain_names"
   
   protected new(Context context) {
      super(context, "webapps4", 1)
   }

   def static getInstance(Context context) {
      return new DbService(context)
   }   
   
   def List<Webapp> getWebapps() {
      executeForBeanList(R.string.dbGetWebapps, null, typeof(Webapp))      
   }
}