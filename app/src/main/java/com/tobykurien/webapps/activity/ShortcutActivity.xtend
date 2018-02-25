package com.tobykurien.webapps.activity

import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.view.Menu
import com.tobykurien.webapps.utils.FaviconHandler
import com.tobykurien.webapps.R
import android.graphics.BitmapFactory

/**
 * Activity to allow the user to pick a webapp when creating a new shortcut
 */
class ShortcutActivity extends MainActivity {

   override protected onStart() {
      super.onStart()

      mainList.setOnItemClickListener([ av, v, pos, id |
         // create shortcut if requested
         var size = getResources().getDimension(android.R.dimen.app_icon_size) as int;
         var favicon = new FaviconHandler(this).getFavIcon(webapps.get(pos).id)

         var launchIntent = new Intent(this, WebAppActivity);
         launchIntent.action = Intent.ACTION_VIEW
         launchIntent.data = Uri.parse(webapps.get(pos).url)
         BaseWebAppActivity.putWebappId(launchIntent, webapps.get(pos).id)

         var intent = new Intent();
         intent.putExtra(Intent.EXTRA_SHORTCUT_INTENT, launchIntent);
         intent.putExtra(Intent.EXTRA_SHORTCUT_NAME, webapps.get(pos).name);

         if (favicon.exists) {
            var icon = Bitmap.createScaledBitmap(BitmapFactory.decodeFile(favicon.path), size, size, false)
            intent.putExtra(Intent.EXTRA_SHORTCUT_ICON, icon);
         } else {
            var icon = Intent.ShortcutIconResource.fromContext(this, R.drawable.ic_action_site);
            intent.putExtra(Intent.EXTRA_SHORTCUT_ICON_RESOURCE, icon);
         }

         setResult(RESULT_OK, intent);

         finish
      ])

      mainList.onItemLongClickListener = [true]
   }

   override onCreateOptionsMenu(Menu menu) {
      return false
   }

}