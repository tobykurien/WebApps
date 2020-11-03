#!/bin/sh
if [ -e $1 ]; then
  FILTER="com.tobykurien.webapps"
else
  FILTER="$1"
fi

./gradlew installDebug runApp |grep "ERROR" || exit 1
adb logcat -c
adb logcat -v color -e "$FILTER" "*:D"
