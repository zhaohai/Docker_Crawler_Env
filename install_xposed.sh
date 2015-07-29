# Create AVD
android create avd -t android-19 -n test -d "Nexus 5" -b x86 -c 200M -s WXGA720
 
set -x
 
# Start emulator
emulator -avd test -no-window -no-audio -no-skin -verbose > emulator_log &
adb wait-for-device
sleep 10

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
 
adb shell sync
adb shell mount -o remount,ro /system

# Install XposedBridge.jar & modules.list
adb push xposed/assets/XposedBridge.jar /data/data/de.robv.android.xposed.installer/bin
adb shell touch /data/data/de.robv.android.xposed.installer/conf/modules.list

# Install xposed module
adb install ActivityInNewTask.apk
echo "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>" > enabled_modules.xml
echo '<map> <int name="com.germainz.activityforcenewtask" value="1" /> </map>' >> enabled_modules.xml
adb push enabled_modules.xml /data/data/de.robv.android.xposed.installer/shared_prefs
adb shell chown $XPOSED_UID:$XPOSED_UID /data/data/de.robv.android.xposed.installer/shared_prefs/enabled_modules.xml
adb shell "echo /data/app/com.germainz.activityforcenewtask-1.apk > /data/data/de.robv.android.xposed.installer/conf/modules.list"
 
XPOSED_UID=`adb shell dumpsys package de.robv.android.xposed.installer | grep userId | sed -E "s/.*userId\=([0-9]+).*/\1/"`
adb shell chown $XPOSED_UID:$XPOSED_UID /data/data/de.robv.android.xposed.installer/bin/XposedBridge.jar /data/data/de.robv.android.xposed.installer/conf/modules.list
 
# Disable screen lock
adb shell sqlite3 /data/system/locksettings.db "UPDATE locksettings SET value = '1' WHERE name = 'lockscreen.disabled'"
 
# Sync filesystem
adb shell sync
 
# Save system image
SYSTEM_IMAGE=`grep "[Mm]apping 'system'" emulator_log | awk '{print $NF}'`
cp $SYSTEM_IMAGE system.img
 
# Stop emulator
adb emu kill
