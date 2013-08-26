package com.tobykurien.webapps.db

import android.content.Context
import asia.sonix.android.orm.AbatisService
import com.tobykurien.webapps.R
import com.tobykurien.webapps.data.Webapp
import java.util.List

class DbService extends AbatisService {
   
   protected new(Context context) {
      super(context, "webapps3", 1)
   }

   def static getInstance(Context context) {
      return new DbService(context)
   }   
   
   def List<Webapp> getWebapps() {
      executeForBeanList(R.string.dbGetWebapps, null, typeof(Webapp))      
   }
}