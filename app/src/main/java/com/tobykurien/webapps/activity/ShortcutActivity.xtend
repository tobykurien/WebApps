package com.tobykurien.webapps.activity

import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.view.Menu
import com.tobykurien.webapps.utils.FaviconHandler
import com.tobykurien.webapps.R
import android.graphics.BitmapFactory
import android.support.v4.content.pm.ShortcutInfoCompat
import android.support.v4.content.pm.ShortcutManagerCompat
import android.support.v4.graphics.drawable.IconCompat


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
            var shortcut = new ShortcutInfoCompat.Builder(this, webapps.get(pos).name)
            .setIntent(launchIntent)
            .setShortLabel(webapps.get(pos).name)
            if (ShortcutManagerCompat.isRequestPinShortcutSupported(this)) {
                if(favicon.exists) {
                    var icon = IconCompat.createWithBitmap(
                            Bitmap.createScaledBitmap(BitmapFactory.decodeFile(favicon.path), size, size, false))
                    shortcut.setIcon(icon);
                } else {
                    var icon = IconCompat.createWithResource(this, R.drawable.ic_action_site)
                    shortcut.setIcon(icon);
                }
            }

            var ret = ShortcutManagerCompat.createShortcutResultIntent(this, shortcut.build())
            setResult(RESULT_OK, ret);
            finish
        ])
        mainList.onItemLongClickListener = [true]
    }

    override onCreateOptionsMenu(Menu menu) {
        return false
    }
}
