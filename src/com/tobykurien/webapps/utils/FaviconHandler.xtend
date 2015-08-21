package com.tobykurien.webapps.utils

import android.content.Context
import android.graphics.Bitmap
import java.io.File
import java.io.FileOutputStream

class FaviconHandler {
   val Context context
   
   new (Context context) {
      this.context = context
   }
   
   /**
    * Retrieves a File handle to favicon for webapp. Ensure that you check File.exists before use
    */   
   def File getFavIcon(long webappId) {
      getFile(webappId)
   }

   /**
    * Saves bitmap as favicon for specified webapp. Runs on current thread!
    */   
   def saveFavIcon(long webappId, Bitmap icon) {
      val f = getFile(webappId)
      val os = new FileOutputStream(f)
      icon.compress(Bitmap.CompressFormat.PNG, 100, os);
   }
   
   def private File getFile(long webappId) {
      new File(context.cacheDir.path + "/favicon-" + webappId + ".png")
   }
}