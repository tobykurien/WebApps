package com.tobykurien.webapps.activity

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.support.v7.app.AlertDialog
import android.support.v7.app.AppCompatActivity
import android.text.Html
import android.view.Menu
import android.view.MenuItem
import android.view.WindowManager
import com.tobykurien.webapps.R
import com.tobykurien.webapps.adapter.WebappsAdapter
import com.tobykurien.webapps.data.Webapp
import com.tobykurien.webapps.db.DbService
import com.tobykurien.webapps.fragment.DlgOpenUrl
import com.tobykurien.webapps.webviewclient.WebViewUtils
import java.util.List
import org.xtendroid.app.AndroidActivity
import org.xtendroid.app.OnCreate
import org.xtendroid.utils.AsyncBuilder

import static extension com.tobykurien.webapps.utils.Dependencies.*
import static extension org.xtendroid.utils.AlertUtils.*

@AndroidActivity(R.layout.main) class MainActivity extends AppCompatActivity {
    var protected List<Webapp> webapps

    @OnCreate
    def init(Bundle savedInstanceState) {
        if(settings.isFullscreen()) {
            getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN);
        }
    }

    override protected onStart() {
        super.onStart()

        val activity = this
        loadWebapps()

        mainList.setOnItemClickListener([av, v, pos, id|
        	val item = av.getItemAtPosition(pos) as Webapp
            var intent = new Intent(activity, typeof(WebAppActivity))
            intent.action = Intent.ACTION_VIEW
            intent.data = Uri.parse(webapps.get(pos).url)
            BaseWebAppActivity.putWebappId(intent, item.id)
            startActivity(intent)
        ])

        mainList.setOnItemLongClickListener([av, v, pos, id|
        	val item = av.getItemAtPosition(pos) as Webapp
            confirm(getString(R.string.delete_webapp), [
                AsyncBuilder.async[p1, p2|
                    db.execute(R.string.dbDeleteDomains, # {'webappId' -> item.id})
                    db.delete(DbService.TABLE_WEBAPPS, String.valueOf(item.id))
                    WebViewUtils.instance.deleteWebappData(this, item.id)
                    null
                ].then [
                    loadWebapps
                ].start
            ])
            true
        ])

        // show tips on first load
        if(settings.firstLoaded < 1) {
            settings.firstLoaded = 1
            showTips()
        }
    }

    override onCreateOptionsMenu(Menu menu) {
        menuInflater.inflate(R.menu.main_menu, menu)
        true
    }

    override onOptionsItemSelected(MenuItem item) {
        switch (item.itemId) {
            case R.id.menu_open: {
                var dlg = new DlgOpenUrl()
                dlg.show(supportFragmentManager, "open_url")
            }

            case R.id.menu_tips: {
                showTips()
            }

            case R.id.menu_settings: {
                var i = new Intent(this, Preferences)
                startActivity(i)
            }

            case R.id.menu_exit: finish()
        }
        super.onOptionsItemSelected(item)
    }

    def showTips() {
        new AlertDialog.Builder(this)
	        .setTitle(R.string.action_tips)
	        .setMessage(Html.fromHtml(getString(R.string.tips)))
	        .setPositiveButton(android.R.string.ok, null)
	        .create()
	        .show()
    }

    def loadWebapps() {
        webapps = db.getWebapps()
        var adapter = new WebappsAdapter(this, webapps)
        mainList.setAdapter(adapter)
    }
}