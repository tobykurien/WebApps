#!/bin/sh

# Make a release build. Using "gradle assembleRelease" fails the first time, so
# this script runs the "prepare dependencies" task first.
# See: https://github.com/tobykurien/WebApps/issues/20
# NOTE: The release is unsigned, so you will need to manually sign it,
# See: https://developer.android.com/tools/publishing/app-signing.html

# run "gradle assembleDebug" to make a debug build rather (run it again if it fails
# the first time).

./gradlew prepareReleaseDependencies
./gradlew assembleRelease

