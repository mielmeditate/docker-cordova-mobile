FROM node:12.13

# From: https://github.com/GoogleChrome/puppeteer/issues/1345#issuecomment-343554457
# Install necessary apt packages for puppeteer bundled chromium work
RUN apt-get update && apt-get install --no-install-recommends -y \
  ca-certificates \
  fontconfig \
  fonts-liberation \
  gconf-service \
  libappindicator1 \
  libasound2 \
  libatk1.0-0 \
  libc6 \
  libcairo2 \
  libcups2 \
  libdbus-1-3 \
  libexpat1 \
  libfontconfig1 \
  libgcc1 \
  libgconf-2-4 \
  libgdk-pixbuf2.0-0 \
  libglib2.0-0 \
  libgtk-3-0 \
  libnspr4 \
  libnss3 \
  libpango-1.0-0 \
  libpangocairo-1.0-0 \
  libstdc++6 \
  lib\x11-6 \
  libx11-xcb1 \
  libxcb1 \
  libxcomposite1 \
  libxcursor1 \
  libxdamage1 \
  libxext6 \
  libxfixes3 \
  libxi6 \
  libxrandr2 \
  libxrender1 \
  libxss1 \
  libxtst6 \
  locales \
  lsb-release \
  unzip \
  wget \
  xdg-utils \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /src/*.deb

# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# Android Installation
ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-darwin-4333796.zip" \
    ANDROID_BUILD_TOOLS_VERSION=28.0.3 \
    ANDROID_APIS="android-10,android-15,android-16,android-17,android-18,android-19,android-20,android-21,android-22,android-23,android-24,android-25,android-26,android-27,android-28" \
    GRADLE_VERSION="4.10.3" \
    GRADLE_URL="https://services.gradle.org/distributions/gradle-4.10.3-bin.zip" \
    ANT_HOME="/usr/share/ant" \
    MAVEN_HOME="/usr/share/maven" \
    GRADLE_HOME="/opt/gradle/gradle-4.10.3" \
    ANDROID_HOME="/opt/android"

ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin

WORKDIR /opt

# Install Android SDK
RUN mkdir android && cd android && \
    wget -O tools.zip ${ANDROID_SDK_URL} && \
    unzip tools.zip && rm tools.zip && \
    yes | android update sdk -a -u -t platform-tools,${ANDROID_APIS},build-tools-${ANDROID_BUILD_TOOLS_VERSION} && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME && \
    yes | tools/bin/sdkmanager --licenses && tools/bin/sdkmanager --update && \

    # Clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    # apt-get autoremove -y && \
    # apt-get clean

# Install Gradle
RUN mkdir gradle && cd gradle && \
    wget -O gradle.zip ${GRADLE_URL} && \
    unzip -d . gradle.zip && rm gradle.zip

# Install Cocoapods
# RUN gem install cocoapods

# Install Cordova
ENV CORDOVA_VERSION 9.0.0

RUN npm i -g --unsafe-perm cordova@${CORDOVA_VERSION}