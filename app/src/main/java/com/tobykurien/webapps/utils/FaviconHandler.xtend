package com.tobykurien.webapps.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.util.Log
import java.io.BufferedOutputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

import static extension org.xtendroid.utils.TimeUtils.*

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

	def deleteFavIcon(long webappId) {
		try {
			val f = getFile(webappId)
			if (f.exists) f.delete()
		} catch (Exception e) {
			Log.e("favicon", "Error deleting icon", e)
		}
	}

	def private File getFile(long webappId) {
		new File(context.cacheDir.path + "/favicon-" + webappId + ".png")
	}
	
	// from: https://stackoverflow.com/questions/8471236/finding-the-dominant-color-of-an-image-in-an-android-drawable
	def static int getDominantColor(File image) {
		val defaultColor = Color.rgb(0xFF, 0xA0, 0x00);

	    if (image === null || !image.exists) {
	        return defaultColor
	    }

	    val bitmap = BitmapFactory.decodeFile(image.absolutePath)
	    val int width = bitmap.getWidth();
	    val int height = bitmap.getHeight();
	    val int size = width * height;
	    val int[] pixels = newIntArrayOfSize(size);
	    //Bitmap bitmap2 = bitmap.copy(Bitmap.Config.ARGB_4444, false);
	    bitmap.getPixels(pixels, 0, width, 0, 0, width, height);
	    var int color = 0;
	    var int r = 0;
	    var int g = 0;
	    var int b = 0;
	    var int a = 0;
	    var int count = 0;
	    for (var i = 0; i < pixels.length; i++) {
	        color = pixels.get(i);
	        a = Color.alpha(color);
	        if (a > 0 && notTooBright(color)) {
	            r += Color.red(color);
	            g += Color.green(color);
	            b += Color.blue(color);
	            count++;
	        }
	    }

		if (count == 0){
			// didn't find suitable colours
			return defaultColor;
		}

	    r /= count;
	    g /= count;
	    b /= count;
	    r = (r << 16).bitwiseAnd(0x00FF0000);
	    g = (g << 8).bitwiseAnd(0x0000FF00);
	    b = b.bitwiseAnd(0x000000FF);
	    color = 0xFF000000.bitwiseOr(r).bitwiseOr(g).bitwiseOr(b);
	    
	    if (notTooBright(color)) {
		    return color;
	    } else {
			return defaultColor;
	    }    
	}
	
	def static notTooBright(int color) {
		var r = Color.red(color)
		var g = Color.green(color)
		var b = Color.blue(color)
		val threshold = 127
		
		if (r > threshold && g > threshold && b > threshold) return false; // too bright

		return true
	}
	
}
