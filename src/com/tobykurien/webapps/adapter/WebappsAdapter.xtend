package com.tobykurien.webapps.adapter

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import com.bumptech.glide.Glide
import com.tobykurien.webapps.R
import com.tobykurien.webapps.data.Webapp
import com.tobykurien.webapps.utils.FaviconHandler
import java.io.File
import java.util.List
import org.xtendroid.adapter.AndroidAdapter
import org.xtendroid.adapter.AndroidViewHolder
import android.widget.BaseAdapter
import com.bumptech.glide.load.engine.DiskCacheStrategy
import java.net.URL
import com.bumptech.glide.signature.StringSignature

/**
 * Android adapter to display webapps using the row_webapp layout
 */
class WebappsAdapter extends BaseAdapter {
   Context context
   List<Webapp> webapps
   FaviconHandler favicoHandler

   /**
    * ViewHolder class to save references to UI widgets in each row
    */
   @AndroidViewHolder(R.layout.row_webapp) static class ViewHolder {      
   }

   new(Context context, List<Webapp> data) {
      this.context = context
      webapps = data
   }

   override getCount() {
      webapps.size
   }
   
   override Webapp getItem(int row) {
      webapps.get(row)
   }
   
   override long getItemId(int row) {
      getItem(row).id
   }
   
   override getView(int row, View cv, ViewGroup parent) {
      var vh = ViewHolder.getOrCreate(context, cv, parent)
      var app = getItem(row)
      
      vh.name.text = app.name
      vh.url.text = new URL(app.url).host
      
      if (favicoHandler == null) favicoHandler = new FaviconHandler(context)
      var favico = favicoHandler.getFavIcon(app.id)
      loadFavicon(context, favico, vh.favicon)
      
      return vh.view
   }
   
   /**
    * Load a favicon into an imageview
    */
   def static loadFavicon(Context context, File favico, ImageView view) {
      if (favico.exists) {
         Glide.with(context)
           .load(favico)
           .diskCacheStrategy(DiskCacheStrategy.NONE)
           .centerCrop()
           .placeholder(R.drawable.ic_action_site)
           .crossFade()
           .into(view);
      } else {
         view.imageResource = R.drawable.ic_action_site
      }
   }
}