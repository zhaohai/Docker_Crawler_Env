#######################################################################
# Dockerfile to build an Ubuntu Android SDK container image
# Based on Ubuntu
#######################################################################

# Set the base image to Ubuntu
FROM oreomitch/ubuntu-jdk:14.04-JDK7
# File Author / Maintainer
MAINTAINER Zhao Hai

# Add Android SDK
RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive
RUN dpkg --add-architecture i386
RUN apt-get update &&  apt-get install vim curl wget unzip tmux libx11-6 libx11-6:i386 libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 build-essential software-properties-common python-software-properties -y

RUN wget --progress=dot:giga http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz
RUN mkdir /opt/android
RUN tar -C /opt/android -xzvf ./android-sdk_r23.0.2-linux.tgz
ENV ANDROID_HOME /opt/android/android-sdk-linux
ENV PATH $ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH
RUN chmod -R 744 $ANDROID_HOME
RUN echo "y" | /opt/android/android-sdk-linux/tools/android update sdk --no-ui -a -t platform-tools,android-19,sys-img-armeabi-v7a-android-19,sys-img-x86-android-19

VOLUME ["/opt/android/android-sdk-linux"]
VOLUME ["/home/downloads"]

# Add install_xposed.sh 
ADD install_xposed.sh /install_xposed.sh
RUN chmod +x /install_xposed.sh
# CMD /install_xposed.sh

