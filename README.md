WebApps Sandboxed browser Android app
=====================================

This Android app is a fork of the GoogleApps Sandboxed browser 
(see https://github.com/tobykurien/GoogleNews). The idea behind 
it is to provide a secure way to browse popular webapps by eliminating 
referrers, 3rd party requests, cookies, cross-site scripting, etc.

It accomplishes this by providing a sandbox for multiple webapps (like Google's apps,
Facebook, Twitter, etc.). Each webapp will run in it's own sandbox, 
with 3rd party requests (images, scripts, iframes, etc.) blocked, 
and all external links opening in an external default web browser 
(which should have cookies, plug-ins, flash, etc. disabled).

By default, all HTTP requests are blocked (only HTTPS allowed). This 
improves security, especially on untrusted networks. The app can also handle 
HTTPS links and open them in their own sandbox.

You can download the latest release here: 
https://github.com/tobykurien/WebApps/tree/master/apk

This app is available from the Google Play Store:
https://play.google.com/store/apps/details?id=com.tobykurien.webapps

Cookies
=======

Currently, as per [this issue](https://github.com/tobykurien/WebApps/issues/3), cookies are passed between sandboxes, because WebView uses a single cookie store for the app, and does not provide a way to specify different cookie storage locations within the app.

Referer
=======

Referer information is not send on any request (as per default behaviour of Webview), which may lead to problems on some sites, but improves privacy.

Storage
=======

Plugins, local file access, and DOM storage are all disabled, to prevent them storing super-cookies or tracking information. Also, password saving and form data asaving have been disabled.

Location
========

The WebView's location access has been disabled, to prevent sites requesting your location.

Libraries
=========

This project makes use of the following libraries/tools:

- Xtend compiler: http://xtend-lang.org
- Xtendroid library: http://github.com/tobykurien/xtendroid

