WebApps Sandboxed browser Android app
=====================================

![screenshot 1](images/webapps1.png) ![screenshot 2](images/webapps2.png) ![screenshot 3](images/webapps3.png)

This Android app is a fork of the [GoogleApps Sandboxed browser][gapps]. The idea behind it is to provide a secure way to browse popular webapps by eliminating referrers, 3rd party requests, insecure HTTP requests, etc.

It accomplishes this by providing a sandbox for multiple webapps (like Google's apps, Facebook, Twitter, etc.). Each webapp will run in it's own sandbox, with 3rd party requests (images, scripts, iframes, etc.) blocked, and all external links opening in an external default web browser (which should have cookies, plug-ins, flash, etc. disabled). Homescreen (launcher) shortcuts can be created to any of the saved webapps.

By default, all HTTP requests are blocked (only HTTPS allowed). This improves security, especially on untrusted networks. In addition, WebApps will warn you if the SSL certificate of the site you're viewing has changed.

For using Google's suite of apps, try the [GApps Sandboxed Browser app][gapps], which works the same as this app but contains specific handling for Google's web apps.

<a href="https://play.google.com/store/apps/details?id=com.tobykurien.webapps" target="_blank">
  <img src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png" height="60"/>
</a>
<a href="https://f-droid.org/repository/browse/?fdfilter=webapps&fdid=com.tobykurien.webapps" target="_blank">
  <img src="https://f-droid.org/badge/get-it-on.png" height="60"/>
</a>

Features
========

- Works like Mozilla Prism on the desktop. This is a mostly chrome-less browser that gets out of your way.
- Completely full-screen browsing (auto-hiding actionbar)
- Securely browse mobile sites (uses HTTPS only)
- Blocks 3rd party requests (images/scripts/iframes) like the NoScript and NotScripts plugins on the desktop
- Allows self-signed SSL certificates to be saved
- Warns if server SSL certificate changes (e.g. during man-in-the-middle-attack)
- User agent and text size setting (per site) allows more rich mobile experience (depending on site)
- External links (outside the domain of the site visited) open in your default browser
- Long-press links to choose how to open them
- Create shortcuts to your webapps on the homescreen
- Uses much less bandwidth than native apps (like Google+ app). No background sync'ing.
- Features local data storage and caching for reduced bandwidth usage and better speed.
- Fully open source software.


Cookies
=======

[Since Android KitKat][cookies], cookies are passed between sandboxes, because WebView uses a single cookie store for the app. [Work-arounds][sandbox_workaround] are in progress.

Referer
=======

Referer information is not send on any request (as per default behaviour of Webview), which may lead to problems on some sites, but improves privacy.

Storage
=======

Plugins, and local file access are disabled, however DOM storage and app caching is allowed.

Location
========

The WebView's location access has been disabled, to prevent sites requesting your location.

Libraries
=========

This project makes use of the following libraries/tools:

- Xtend compiler: http://xtend-lang.org
- Xtendroid library: http://github.com/tobykurien/xtendroid

Development
===========

In order to develop in Eclipse:

- Clone the git repository to your local machine (```git clone ...```)
- Inside the checked-out folder, run: ```gradle generateEclipseDependencies```. This will download all the required 3rd party libraries and create Eclipse projects for them (if they are AAR dependencies).
- Open Eclipse and import all projects *and sub-projects* within the checked-out folder
- The project should now compile in Eclipse

The app can be built either using Eclipse or using ```gradle assembleDebug```.

   [gapps]: https://github.com/tobykurien/GoogleNews
   [cookies]: https://developer.android.com/reference/android/webkit/WebSettings.html#setDatabasePath%28java.lang.String%29
   [sandbox_workaround]: https://github.com/tobykurien/WebApps/issues/3
