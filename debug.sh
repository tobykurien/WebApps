#!/bin/sh
./gradlew installDebug && adb shell monkey -p com.tobykurien.webapps.debug -c android.intent.category.LAUNCHER 1
