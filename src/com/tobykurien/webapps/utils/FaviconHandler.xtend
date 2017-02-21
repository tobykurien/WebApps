package com.tobykurien.webapps.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

import static extension org.xtendroid.utils.TimeUtils.*
import java.io.BufferedOutputStream

class FaviconHandler {
	val Context context

	new(Context context) {
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

		if (f.exists) {
			// make sure new icon is of higher or same resolution
			var bmpOpt = new BitmapFactory.Options()
			bmpOpt.inJustDecodeBounds = true
			BitmapFactory.decodeStream(new FileInputStream(f), null, bmpOpt)
			if (Debug.FAVICON) Log.d("favicon", "Icon IN=" + icon.width + "x" + icon.height + ", CACHED=" + bmpOpt.outWidth + "x" + bmpOpt.outHeight)

			if (bmpOpt.outHeight > icon.height && bmpOpt.outWidth > icon.width) {
				// new icon is lower res
				if (Debug.FAVICON) Log.d("favicon", "Skipping because lower res")
				return
			}
			
			if (bmpOpt.outHeight == icon.height && bmpOpt.outWidth == icon.width && 
				System.currentTimeMillis - f.lastModified < 24.hours) {
				// new icon matches saved icon, and it was saved recently, so no need to overwrite
				if (Debug.FAVICON) Log.d("favicon", "Skipping because we cached this recently")
				return
			}
			
			f.delete()
		}

	    if (Debug.FAVICON) Log.d("favicon", "Saving new icon for " + webappId)
		val os = new BufferedOutputStream(new FileOutputStream(f))
		try {
			icon.compress(Bitmap.CompressFormat.PNG, 100, os);
			os.flush()
		} finally {
			os.close()
		}
	}

	def private File getFile(long webappId) {
		new File(context.cacheDir.path + "/favicon-" + webappId + ".png")
	}
}
