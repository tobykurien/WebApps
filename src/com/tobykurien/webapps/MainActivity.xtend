package com.tobykurien.webapps

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.widget.ListView
import com.tobykurien.webapps.data.Webapp
import com.tobykurien.webapps.db.DbService
import com.tobykurien.webapps.fragment.DlgOpenUrl
import com.tobykurien.xtendroid.adapter.BeanAdapter
import com.tobykurien.xtendroid.annotations.AndroidView
import java.util.List

import static extension com.tobykurien.webapps.utils.Dependencies.*
import static extension com.tobykurien.xtendroid.utils.AlertUtils.*

class MainActivity extends Activity {
   @AndroidView ListView mainList
   var List<Webapp> webapps

   override protected onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState)
      setContentView(R.layout.main)
   }

   override protected onStart() {
      super.onStart()
    
      val activity = this
      loadWebapps
      
      getMainList.setOnItemClickListener([av, v, pos, id|
         var intent = new Intent(activity, typeof(WebAppActivity))
         intent.action = Intent.ACTION_VIEW
         intent.data = Uri.parse(webapps.get(pos).url)
         intent.putExtra(BaseWebAppActivity.EXTRA_WEBAPP_ID, id)
         startActivity(intent)
      ])
      
      getMainList.setOnItemLongClickListener([av, v, pos, id|
         confirm(getString(R.string.delete_webapp), [|
            db.execute(R.string.dbDeleteDomains, #{'webappId' -> id})
            db.delete(DbService.TABLE_WEBAPPS, String.valueOf(id))
            loadWebapps
            null
         ])
         true
      ])      
   }
   
   override onCreateOptionsMenu(Menu menu) {
      menuInflater.inflate(R.menu.main_menu, menu)
      true
   }
   
   override onOptionsItemSelected(MenuItem item) {
      switch (item.itemId) {
         case R.id.menu_open: {
            var dlg = new DlgOpenUrl()
            dlg.show(fragmentManager, "open_url")
         }
         case R.id.menu_settings: {
            var i = new Intent(this, typeof(Preferences))
            startActivity(i)
         }
         case R.id.menu_exit: finish()
      }
      super.onOptionsItemSelected(item)
   }
 
   def loadWebapps() {
      webapps = db.getWebapps
      var adapter = new BeanAdapter<Webapp>(this, R.layout.row_webapp, webapps) 
      getMainList.setAdapter(adapter)
   }  
}