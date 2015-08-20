package com.tobykurien.webapps.fragment

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.support.v4.app.DialogFragment
import android.support.v7.app.AlertDialog
import com.tobykurien.webapps.R
import com.tobykurien.webapps.activity.WebAppActivity
import org.xtendroid.annotations.AndroidDialogFragment

/**
 * Dialog to open a URL.
 */
@AndroidDialogFragment(R.layout.dlg_open_url) class DlgOpenUrl extends DialogFragment {

   /**
    * Create a dialog using the AlertDialog Builder, but our custom layout
    */
   override onCreateDialog(Bundle instance) {
      new AlertDialog.Builder(activity)
         .setTitle(R.string.open_site)
         .setView(contentView)  // contentView is the layout specified in the annotation
         .setPositiveButton(android.R.string.ok, null) // to avoid it closing dialog
         .setNegativeButton(android.R.string.cancel, null)
         .create()
   }
   
   override onStart() {
      super.onStart()
      
      (dialog as AlertDialog).getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener [
         if (onOpenUrlClick()) {
            dialog.dismiss
         }
      ]      
   }
 
   def boolean onOpenUrlClick() {
      var url = txtOpenUrl.text.toString;
      if (url.trim.length == 0 || url.indexOf("://") >= 0) {
         txtOpenUrl.setError(getString(R.string.err_invalid_url), null)
         return false
      }

      val Uri uri = try {
         Uri.parse("https://" + url)
      } catch (Exception e) {
         txtOpenUrl.setError(getString(R.string.err_invalid_url), null)
         return false
      }

      var i = new Intent(activity, WebAppActivity)
      i.action = Intent.ACTION_VIEW
      i.data = uri
      startActivity(i)
      return true
   }  
}