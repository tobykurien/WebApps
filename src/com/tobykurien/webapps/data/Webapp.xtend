package com.tobykurien.webapps.data

import org.eclipse.xtend.lib.annotations.Accessors

/**
 * Webapp POJO to store details of a webapp
 */
@Accessors class Webapp {
   long id
   String name
   String url
   String iconUrl
   
   override toString() {
      name
   }
}