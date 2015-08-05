package com.tobykurien.webapps.fragment

import android.app.DialogFragment
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import com.tobykurien.webapps.R
import com.tobykurien.webapps.activity.WebAppActivity

import static extension org.xtendroid.utils.AlertUtils.*

class DlgOpenUrl extends DialogFragment {
   
   override onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
      var v = inflater.inflate(R.layout.dlg_open_url, container, false)
      
      var b = v.findViewById(R.id.btnOpenUrl) as Button
      b.setOnClickListener([btn| onOpenUrlClick(btn) ])
      
      v
   }

   override onStart() {
      super.onStart()      
      dialog.title = getString(R.string.open_site)
   }
 
   def onOpenUrlClick(View v) {
      var txtUrl = view.findViewById(R.id.txtOpenUrl) as EditText
      var i = new Intent(activity, typeof(WebAppActivity))
      i.action = Intent.ACTION_VIEW
      try {
         i.data = Uri.parse("https://" + txtUrl.text.toString)
         startActivity(i)
         dismiss
      } catch (Exception e) {
         activity.toast("Error parsing URL: " + e.message)
      }
   }  
}