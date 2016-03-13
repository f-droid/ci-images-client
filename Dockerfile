from debian:8.3

env LANG C.UTF-8

# Misc tools
# Python 3 (fdroidserver, fdroidclient/tools)
# Deps for `fdroid lint` in fdroiddata
# PIL build deps
# OpenJDK 7
# Android SDK deps
run echo "path-exclude=/usr/share/locale/*\npath-exclude=/usr/share/man/*\npath-exclude=/usr/share/doc/*\npath-include=/usr/share/doc/*/copyright" >/etc/dpkg/dpkg.cfg.d/01_nodoc && \
	apt-get update && apt-get install -y --no-install-recommends \
		wget tar git unzip rsync \
		python3 python3-dev gcc python3-pip \
		python3-yaml \
		virtualenv dash bash ruby \
		libjpeg-dev zlib1g-dev \
		openjdk-7-jdk \
		lib32stdc++6 lib32z1 \
	&& rm -rf /var/lib/apt/lists/*

# Install SDK
run wget -O sdk.tgz https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && tar -xzf sdk.tgz && rm sdk.tgz && mv android-sdk-linux android-sdk
env ANDROID_HOME $PWD/android-sdk
env PATH $ANDROID_HOME/tools:$PATH

# SDK components - the sdk is too dumb to just use `yes`, it will read
# more than one line per question
# We only need the emulator images from android-10
run { while true; do echo y; sleep 1; done } | android -s update sdk --no-ui -a -t platform-tools,build-tools-23.0.2,android-23,extra-android-m2repository,android-10 && \
	rm -r $ANDROID_HOME/platforms/android-10/android.jar $ANDROID_HOME/platforms/android-10/data
env PATH $ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/23.0.2:$PATH
