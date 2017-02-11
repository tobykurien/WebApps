package com.tobykurien.webapps.utils

import org.xtendroid.annotations.AndroidPreference

/**
 * Class to get and set shared preferences, which are also editable from the Preference activity.
 * Uses Xtendroid's @AndroidPreference to manage the preferences, making the class appear as a POJO.
 * NOTE: Default values here must also match up with the default values in settings.xml
 */
@AndroidPreference class Settings {
    boolean block3rdParty = true
    //boolean blockHttp = true  // deprecated
    String fontSize = "2"
    String userAgent = ""
    boolean fullscreen = false
    boolean hideActionbar = true
    boolean loadImages = true
    int firstLoaded = 0

    long lastWebappId = -1

    def getIntFontSize() {
        try {
            Integer.parseInt(getFontSize())
        } catch(Exception e) {
            2
        }
    }

    def isBlockHttp() {
        // Deprecate old option to allow HTTP 3rd party requests
        return true
    }
}