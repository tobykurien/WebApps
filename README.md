WebApps Sandboxed browser Android app
=====================================

This Android app is a fork of the GoogleApps Sandboxed browser 
(see https://github.com/tobykurien/GoogleNews). The idea behind 
it is to provide a secure way to browse popular webapps by eliminating 
referrers, 3rd party requests, cookies, cross-site scripting, etc.

It accomplishes this by providing a sandbox for multiple webapps (like Google's apps,
Facebook, Twitter, etc.). Each webapp will run in it's own sandbox, 
with 3rd party requests (cookies, images, scripts, etc.) blocked, 
and all external links opening in an external default web browser 
(which should have cookies, plug-ins, flash, etc. disabled).

By default, all HTTP requests are blocked (only HTTPS allowed). This 
improves security, especially on untrusted networks. The app can also handle 
HTTPS links and open them in their own sandbox.

You can download the latest release here: 
https://github.com/tobykurien/WebApps/tree/master/apk

This app is available from the Google Play Store:
https://play.google.com/store/apps/details?id=com.tobykurien.webapps

Libraries
=========

This project makes use of the following libraries/tools:

- Xtend compiler: http://xtend-lang.org
- Xtendroid library: http://github.com/tobykurien/xtendroid

In order to compile with the command line you should install maven, make an
apklib from Xtendroid by cloning from the above location, changing into it 
and running:  
`zip -r Xtendroid.apklib *` then ` mvn install:install-file 
-Dfile=Xtendroid.apklib -DgroupId=com.tobykurien -DartifactId=xtendroid 
-Dversion=1.0 -Dpackaging=apklib` and finally, `mvn package`.

