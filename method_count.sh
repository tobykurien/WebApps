#!/bin/bash
unzip -p build/outputs/apk/WebApps-debug.apk classes.dex | head -c 92 | tail -c 4 | hexdump -e '1/4 "%d\n"'
