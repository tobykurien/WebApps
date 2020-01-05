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
   int fontSize = -1
   String userAgent
   String certIssuedTo
   String certIssuedBy
   String certValidFrom
   String certValidTo
   String cookies
   Boolean allowLocation = null
   Boolean ignoreCertChanges = null
}