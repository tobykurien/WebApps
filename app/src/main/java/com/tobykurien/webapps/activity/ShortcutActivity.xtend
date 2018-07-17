package com.tobykurien.webapps.activity

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.support.v4.content.pm.ShortcutInfoCompat
import android.support.v4.content.pm.ShortcutManagerCompat
import android.support.v4.graphics.drawable.IconCompat
import android.view.Menu
import com.tobykurien.webapps.R
import com.tobykurien.webapps.utils.FaviconHandler
import android.content.Context
import com.tobykurien.webapps.data.Webapp

/**
 * Activity to allow the user to pick a webapp when creating a new shortcut
 */
class ShortcutActivity extends MainActivity {

    override protected onStart() {
        super.onStart()

        mainList.setOnItemClickListener([ av, v, pos, id |
            var shortcut = getShortcut(this, webapps.get(pos))
            var ret = ShortcutManagerCompat.createShortcutResultIntent(this, shortcut.build())
            setResult(RESULT_OK, ret);

            finish()
        ])

        mainList.onItemLongClickListener = [true]
    }

    def static getShortcut(Context context, Webapp webapp) {
        // Adding shortcut on Home screen
        var launchIntent = new Intent(context, WebAppActivity);
        launchIntent.action = Intent.ACTION_VIEW
        launchIntent.data = Uri.parse(webapp.url)
        BaseWebAppActivity.putWebappId(launchIntent, webapp.id)

        var shortcut = new ShortcutInfoCompat.Builder(context, webapp.name)
                        .setIntent(launchIntent)
                        .setShortLabel(webapp.name)

        var size = context.getResources().getDimension(android.R.dimen.app_icon_size) as int;
        var favicon = new FaviconHandler(context).getFavIcon(webapp.id);

        if (ShortcutManagerCompat.isRequestPinShortcutSupported(context)) {
            if(favicon.exists) {
                var icon = IconCompat.createWithBitmap(
                        Bitmap.createScaledBitmap(BitmapFactory.decodeFile(favicon.path), size, size, false))
                shortcut.setIcon(icon);
            } else {
                var icon = IconCompat.createWithResource(context, R.drawable.ic_action_site)
                shortcut.setIcon(icon);
            }
        }

        return shortcut
    }

    override onCreateOptionsMenu(Menu menu) {
        return false
    }
}
