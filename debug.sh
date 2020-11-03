#!/bin/sh
if [ -e $1 ]; then
  FILTER="com.tobykurien.webapps"
else
  FILTER="$1"
fi

./gradlew installDebug runApp |grep "ERROR"

adb logcat -c
adb logcat -v color -e "$FILTER" "*:D"
