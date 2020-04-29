#!/bin/sh
./gradlew installDebug runApp |grep "ERROR"
adb logcat -c
