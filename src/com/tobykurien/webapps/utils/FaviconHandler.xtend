package com.tobykurien.webapps.utils

import android.content.Context
import android.graphics.Bitmap
import java.io.File
import java.io.FileOutputStream

import static extension org.xtendroid.utils.TimeUtils.*

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
    * Saves bitmap as favicon for specified webapp, if it hasn't been modified in the last 24 hours. 
    * NOTE: Runs on current thread!
    */   
   def void saveFavIcon(long webappId, Bitmap icon) {
      val f = getFile(webappId)      
      if (System.currentTimeMillis - f.lastModified < 24.hours) return;
            
      val os = new FileOutputStream(f)
      try {
         icon.compress(Bitmap.CompressFormat.PNG, 100, os);
      } finally  {
         os.close()
      }
   }
   
   def private File getFile(long webappId) {
      new File(context.cacheDir.path + "/favicon-" + webappId + ".png")
   }
}