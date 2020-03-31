#!/bin/sh
./gradlew installDebug |grep "ERROR" && adb shell monkey -p com.tobykurien.webapps.debug -c android.intent.category.LAUNCHER 1
