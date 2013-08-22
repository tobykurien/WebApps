package com.tobykurien.webapps.utils

import android.app.ProgressDialog
import android.os.AsyncTask
import org.eclipse.xtext.xbase.lib.Functions.Function1
import org.eclipse.xtext.xbase.lib.Functions.Function0

/**
 * Convenience class to run tasks in the background using AsyncTask.
 * The generic paramater is the type of the result from the background task to 
 * be passed into the UI task
 */
class BgTask<R> extends AsyncTask<Void, Void, R> {
   var Function0<R> bgFunction
   var Function1<R, Void> uiFunction
   var ProgressDialog pd

   def runInBgWithProgress(ProgressDialog pdialog, Function0<R> bg, Function1<R, Void> ui) {
      pd = pdialog
      runInBg(bg, ui)
   }

   def runInBg(Function0<R> bg, Function1<R, Void> ui) {
      bgFunction = bg
      uiFunction = ui
      if(pd != null && !pd.showing) pd.show()
      try {
         execute()
      } finally {
         dismissProgress
      }
   }

   override protected doInBackground(Void... arg0) {
      return bgFunction.apply()
   }

   override protected onPostExecute(R result) {
      try {
         if (uiFunction != null) uiFunction.apply(result)
      } finally {
         dismissProgress
      }
   }

   def dismissProgress() {
      if(pd != null) pd.dismiss()
   }
}
