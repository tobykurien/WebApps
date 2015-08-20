package com.tobykurien.webapps.adapter

import android.view.View
import android.view.ViewGroup
import com.bumptech.glide.Glide
import com.tobykurien.webapps.R
import com.tobykurien.webapps.data.Webapp
import java.util.List
import org.xtendroid.adapter.AndroidAdapter
import org.xtendroid.adapter.AndroidViewHolder
import android.util.Log

/**
 * Android adapter to display webapps using the row_webapp layout
 */
@AndroidAdapter class WebappsAdapter {
   List<Webapp> webapps

   /**
    * ViewHolder class to save references to UI widgets in each row
    */
   @AndroidViewHolder(R.layout.row_webapp) static class ViewHolder {      
   }
   
   override getView(int row, View cv, ViewGroup parent) {
      var vh = ViewHolder.getOrCreate(context, cv, parent)
      var app = getItem(row)
      
      vh.name.text = app.name
      vh.url.text = app.url
      
      if (app.iconUrl != null && app.iconUrl.trim.length > 0) {
         var url = app.iconUrl.trim
         if (url.indexOf("://") < 0) {
            url = app.url + app.iconUrl
            if (url.indexOf("://") < 0) {
               url = "https://" + url
            }
         }
         Log.d("glide", "loading " + url)
         
         Glide.with(context)
           .load(url)
           .centerCrop()
           .placeholder(R.drawable.ic_action_site)
           .crossFade()
           .into(vh.favicon);
      } else {
         // find favicon using http://icons.better-idea.org
         // e.g. http://icons.better-idea.org/api/icons?pretty=yes&url=mobile.twitter.com
         Glide.with(context)
            .load("http://icons.better-idea.org/api/icons?pretty=yes&url=" + app.url)
      }
      
      return vh.view
   }
}