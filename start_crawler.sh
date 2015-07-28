# set utf-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
# new a emulator using system.img
emulator -avd test -system system.img -no-window -no-audio -verbose > emulator_log &

mkdir /root/Downloads

# start 
java -jar /publish/inapp-crawler-1.0.jar /opt/android/android-sdk-linux

