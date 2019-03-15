WebApps Sandboxed browser Android app
=====================================

![screenshot 1](images/webapps1.png) ![screenshot 2](images/webapps2.png) ![screenshot 3](images/webapps3.png)

This Android app is a fork of the [GoogleApps Sandboxed browser][gapps]. The idea behind it is to provide a secure way to browse popular webapps by eliminating referrers, 3rd party requests, insecure HTTP requests, etc.

It accomplishes this by providing a sandbox for multiple webapps (like Google's apps, Facebook, Twitter, etc.). Each webapp will run in it's own sandbox, with 3rd party requests (images, scripts, iframes, etc.) blocked, and all external links opening in an external default web browser (which should have cookies, plug-ins, flash, etc. disabled). Homescreen (launcher) shortcuts can be created to any of the saved webapps.

By default, all HTTP requests are blocked (only HTTPS allowed). This improves security, especially on untrusted networks. In addition, WebApps will warn you if the SSL certificate of the site you're viewing has changed.

For a less security-focussed, but more media-friendly option, try [Web Media Share][webmediashare], which is a fork of WebApps with specific focus on extracting and sharing/casting media.

For using Google's suite of apps, try the [GApps Sandboxed Browser app][gapps], which works the same as this app but contains specific handling for Google's web apps.

<a href="https://play.google.com/store/apps/details?id=com.tobykurien.webapps" target="_blank">
  <img src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png" height="60"/>
</a>
<a href="https://f-droid.org/en/packages/com.tobykurien.webapps/" target="_blank">
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

Cookies are stored by Android's [CookieManager][], of which there is one instance per app. To avoid cookies from passing between sandboxes, the following has been implemented:

- All cookies in the CookieManager are deleted when opening a URL or web app.
- For saved web apps, the saved cookies are restored, and the app opened.
- Cookies are only saved for the root domain of the saved web app, and made available to all sub-domains.
- No 3rd party cookies are saved or sent. This may prevent some sites from working correctly.

In short, there is a strict cookie policy in place that ensures that cookies are correctly sandboxed, and that no 3rd party cookies are saved or sent.

Referer
=======

Referer information is not send on any request (as per default behaviour of Webview), which may lead to problems on some sites, but improves privacy.

Storage
=======

Plugins, and local file access are disabled, however DOM/local storage and app caching is allowed. There is only one cache for all sandboxes to share.

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

To build this project:

- Clone the git repository to your local machine (```git clone ...```)
- Run ```./build.sh``` to build an unsigned release APK

In order to develop in Eclipse:

- Install the [Xtend plugin for Eclipse][xtend_install]
- Clone the git repository to your local machine (```git clone ...```)
- Inside the checked-out folder, run: ```./gradlew eclipse```. This will download all the required 3rd party libraries and create the Eclipse classpath and project files
- Open Eclipse and import the project in the `app` folder
- The project should now compile in Eclipse

To develop using Android Studio:

- Install the [Xtend plugin for IntelliJ][xtend_install]
- Clone the git repository to your local machine (```git clone ...```)
- Import the project into Android Studio
- The project should now compile (very first build may fail, a rebuild should fix this).

   [webmediashare]: https://github.com/tobykurien/WebMediaShare
   [gapps]: https://github.com/tobykurien/GoogleNews
   [cookies]: https://developer.android.com/reference/android/webkit/WebSettings.html#setDatabasePath%28java.lang.String%29
   [sandbox_workaround]: https://github.com/tobykurien/WebApps/issues/3
   [xtend_install]: http://www.eclipse.org/xtend/download.html
   [CookieManager]: https://developer.android.com/reference/android/webkit/CookieManager.html
