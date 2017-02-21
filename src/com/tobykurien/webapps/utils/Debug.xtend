package com.tobykurien.webapps.utils

import com.tobykurien.webapps.BuildConfig

/**
 * Global debug switches for testing and debugging
 */
class Debug {
    public val static boolean ON = BuildConfig.DEBUG // global on/off switch. Turn off for production

    public val static boolean FAVICON = ON && true // spit out debug info for favicon handling
}