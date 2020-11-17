#!/bin/sh
if [ -e $1 ]; then
  FILTER="com.tobykurien.webapps"
else
  FILTER="$1"
fi

echo Compiling app...
# always clean because incremental compile sometimes fails and results in non-sensical compile errors
./gradlew --no-daemon installDebug runApp | grep "ERROR"

adb logcat -c
adb logcat -v color -e "$FILTER" "*:D"
