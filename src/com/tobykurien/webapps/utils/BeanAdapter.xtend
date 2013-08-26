package com.tobykurien.webapps.utils

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import java.lang.reflect.Method
import java.util.HashMap
import java.util.List

/**
 * Generic adapter to take data in the form of Java beans and use the getters
 * to get the data and apply to appropriately named views in the row layout, e.g.
 * getFirstName -> R.id.first_name
 * isToast -> R.id.toast
 */
class BeanAdapter<T> extends BaseAdapter {
   val List<T> data
   val Context context
   val int layoutId
   val HashMap<Integer,Method> mapping = newHashMap()
   
   new(Context context, int layoutId, List<T> data) {
      this.data = data
      this.layoutId = layoutId
      this.context = context
   }

   new(Context context, int layoutId, T[] data) {
      this.data = data.map[i| i]
      this.layoutId = layoutId
      this.context = context
   }
   
   override getCount() {
      data.length
   }
   
   override T getItem(int row) {
      data.get(row)
   }
   
   override getItemId(int row) {
      try {
         var item = getItem(row)
         var m = item.class.getMethod("getId")
         Long.valueOf(String.valueOf(m.invoke(item)))
      } catch (Exception e) {
         row as long
      }
   }
   
   override getView(int row, View cv, ViewGroup root) {
      val i = getItem(row)
      var v = cv
      if (v == null) {
         v = LayoutInflater.from(context).inflate(layoutId, root, false)
         if (mapping.empty) setupMapping(v, i)
      }
      
      val view = v
      mapping.forEach [resId,method|
         var res = view.findViewById(resId)
         if (res != null) {
            switch (res.class) {
               case TextView: (res as TextView).setText(String.valueOf(method.invoke(i)))
               case EditText: (res as EditText).setText(String.valueOf(method.invoke(i)))
               case ImageView: (res as ImageView).setImageBitmap(method.invoke(i) as Bitmap)
               default: Log.e("base_adapter", "View type not yet supported: " + res.class)
            }
         }
      ]
      
      v
   }
   
   /**
    * Set up the bean-to-view for use in subsequent rows
    */
   def setupMapping(View v, T i) {
      i.class.methods.forEach [m|
         if (m.name.startsWith("get") || m.name.startsWith("is")) {
            // might be a getter, let's see if there is a corresponding view
            var resName = m.toResourceName
            var resId = context.resources.getIdentifier(resName, "id", context.packageName)
            if (resId > 0) {
               mapping.put(resId, m)
            } 
         }
      ]
   }

   /**
    * Convert Java bean getter name into resource name format, i.e.
    * getFirstName -> first_name
    * isToast -> toast
    */   
   def toResourceName(Method m) {
      var name = m.name
      if (m.name.startsWith("get")) {
         name = m.name.substring(3)
      } else if (m.name.startsWith("is")) {
         name = m.name.substring(2)
      }
      
      // convert camelcase to lowercase with underscores
      name.replaceAll("(?=[\\p{Lu}])","_").toLowerCase().replaceAll("^_","");
   }
   
}