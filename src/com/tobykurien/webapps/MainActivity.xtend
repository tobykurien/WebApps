package com.tobykurien.webapps

import android.app.Activity
import android.content.Intent
import android.view.Menu
import android.view.MenuItem
import android.os.Bundle

class MainActivity extends Activity {
   
   override protected onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState)
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