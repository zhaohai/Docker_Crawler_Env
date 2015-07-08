# Create AVD
android create avd -t android-19 -n test -d "Nexus 5" -b x86

set -x
 
# Start emulator
emulator -avd test -no-window -no-audio -no-skin -verbose > emulator_log &
adb wait-for-device
 
# Download and install Xposed
wget http://dl-xda.xposed.info/modules/de.robv.android.xposed.installer_v33_36570c.apk -O xposed.apk
adb install xposed.apk
 
 
# Open Xposed app
adb shell am start -n de.robv.android.xposed.installer/.WelcomeActivity
 
 
# Unpack Xposed apk
unzip xposed.apk -d xposed
 
# Replace /system/bin/app_process
adb push xposed/assets/x86/app_process_xposed_sdk16 /data/local/tmp
 
adb remount
 
adb shell cp /system/bin/app_process /system/bin/app_process.orig
adb shell rm /system/bin/app_process
adb shell cp /data/local/tmp/app_process_xposed_sdk16 /system/bin/app_process
 
adb shell chmod 755 /system/bin/app_process
adb shell chown root:shell /system/bin/app_process
 
sync
 
# Install XposedBridge.jar & modules.list
adb push xposed/assets/XposedBridge.jar /data/data/de.robv.android.xposed.installer/bin
adb shell touch /data/data/de.robv.android.xposed.installer/conf/modules.list
 
XPOSED_UID=`adb shell dumpsys package de.robv.android.xposed.installer | grep userId | sed -E "s/.*userId\=([0-9]+).*/\1/"`
adb shell chown $XPOSED_UID:$XPOSED_UID /data/data/de.robv.android.xposed.installer/bin/XposedBridge.jar /data/data/de.robv.android.xposed.installer/conf/modules.list
 
 
# Save system image
SYSTEM_IMAGE=`grep "Mapping 'system'" emulator_log | awk '{print $NF}'`
cp $SYSTEM_IMAGE system.img
 
 
# TODO: install xposed module
 
 
# Stop emulator
adb emu kill
