package com.tobykurien.webapps.data

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString

/**
 * Webapp POJO to store details of a webapp
 */
@Accessors @ToString class Webapp {
   long id
   String name
   String url
   String iconUrl
}