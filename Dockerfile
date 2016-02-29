from debian:8.3

env SDKVER 24.4.1
env LANG C.UTF-8

# Misc tools
# Python 2 (fdroidserver) + deps + linters
# Python 3 (fdroidclient tools)
# OpenJDK 7
# Android SDK deps
run apt-get update && apt-get install -y --no-install-recommends \
		wget tar git unzip rsync \
		python \
		python-git python-imaging python-libcloud python-logilab-astng \
		python-paramiko python-pip python-pyasn1 python-pyasn1-modules \
		python-requests python-virtualenv python-yaml \
		virtualenv pyflakes pylint pep8 dash bash ruby \
		python3 \
		openjdk-7-jdk \
		lib32stdc++6 lib32z1
	&& rm -rf /var/lib/apt/lists/*

# Install SDK
run wget -O sdk.tgz https://dl.google.com/android/android-sdk_r$SDKVER-linux.tgz && tar -xzf sdk.tgz && rm sdk.tgz
env ANDROID_HOME $PWD/android-sdk-linux
env PATH $ANDROID_HOME/tools:$PATH

# SDK components
run echo y | android -s update sdk --no-ui -a -t platform-tools,tools,build-tools-23.0.2,android-23,extra-android-m2repository,android-10
env PATH $ANDROID_HOME/platform-tools:$PATH
env PATH $ANDROID_HOME/build-tools/23.0.2:$PATH
