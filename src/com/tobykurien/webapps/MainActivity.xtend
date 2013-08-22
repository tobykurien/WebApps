package com.tobykurien.webapps

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.widget.ArrayAdapter
import android.widget.ListView
import com.tobykurien.webapps.data.Webapp
import com.tobykurien.webapps.utils.AndroidView
import java.util.List

import static extension com.tobykurien.webapps.utils.Dependencies.*
import java.net.URI
import android.net.Uri

class MainActivity extends Activity {
   @AndroidView ListView main_list
   var List<Webapp> webapps
   
   override protected onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState)
      setContentView(R.layout.main)
      
      webapps = db.getWebapps
      var adapter = new ArrayAdapter<Webapp>(this, 
         android.R.layout.simple_list_item_1,
         android.R.id.text1,
         webapps)
      
      val activity = this
      get_main_list.setAdapter(adapter)
      get_main_list.setOnItemClickListener([av, v, pos, id|
         var intent = new Intent(activity, typeof(WebAppActivity))
         intent.data = Uri.parse(webapps.get(pos).url)
         startActivity(intent)
      ])
   }
   
   override onCreateOptionsMenu(Menu menu) {
      menuInflater.inflate(R.menu.main_menu, menu)
      true
   }
   
   override onOptionsItemSelected(MenuItem item) {
      switch (item.itemId) {
         case R.id.menu_settings: {
            var i = new Intent(this, typeof(Preferences))
            startActivity(i)
         }
         case R.id.menu_exit: finish()
      }
      super.onOptionsItemSelected(item)
   }
   
}