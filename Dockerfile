from debian:8.3

env SDKVER 24.4.1
env SDKDIR android-sdk-$SDKVER-1
env LANG C.UTF-8

run apt-get update -y

# Misc
run apt-get install -y wget tar git unzip rsync

# Python 2 (fdroidserver)
run apt-get install -y python \
	python-git python-imaging python-libcloud python-logilab-astng \
	python-paramiko python-pip python-pyasn1 python-pyasn1-modules \
	python-requests python-virtualenv python-yaml

# Python 3 (fdroidclient tools)
run apt-get install -y python3

# CI tools
run apt-get install -y pyflakes pylint pep8 dash bash ruby

# To build pillow for fdroidserver
run apt-get install -y python-dev libjpeg-dev zlib1g-dev

# JDK
run apt-get install -y openjdk-7-jdk

# Android SDK deps
run apt-get install -y lib32stdc++6 lib32z1

# Install SDK
run wget -O android-sdk.tgz https://dl.google.com/android/android-sdk_r$SDKVER-linux.tgz
run tar -xzf android-sdk.tgz
run mv android-sdk-linux $SDKDIR
run rm android-sdk.tgz
env ANDROID_HOME $PWD/$SDKDIR
env PATH $ANDROID_HOME/tools:$PATH

# SDK components
run echo y | android -s update sdk --no-ui -a -t platform-tools,tools,build-tools-23.0.2,android-22,extra-android-m2repository,android-10
env PATH $ANDROID_HOME/platform-tools:$PATH
env PATH $ANDROID_HOME/build-tools/23.0.2:$PATH
