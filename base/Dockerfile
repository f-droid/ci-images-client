from debian:jessie-backports

env LANG C.UTF-8
env DEBIAN_FRONTEND noninteractive

# Misc tools
# Python 3 (fdroidserver, fdroidclient/tools)
# Deps for `fdroid lint` in fdroiddata
# OpenJDK 8
# Android SDK with common components
run echo "path-exclude=/usr/share/locale/*\npath-exclude=/usr/share/man/*\npath-exclude=/usr/share/doc/*\npath-include=/usr/share/doc/*/copyright" >/etc/dpkg/dpkg.cfg.d/01_nodoc && \
	apt-get update && apt-get install -y --no-install-recommends \
		wget curl tar git unzip \
		python3 python3-yaml \
		openjdk-8-jdk-headless \
		lib32stdc++6 lib32z1 \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install SDK
run wget -O tools.zip https://dl.google.com/android/repository/tools_r25.2.4-linux.zip && unzip tools.zip && rm tools.zip && mkdir android-sdk && mv tools android-sdk/
env ANDROID_HOME $PWD/android-sdk
env PATH $ANDROID_HOME/tools:$PATH

# SDK components - the sdk is too dumb to just use `yes`, it will read
# more than one line per question
run { while true; do echo y; sleep 1; done } | android -s update sdk --no-ui -a -t platform-tools,build-tools-25.0.2
env PATH $ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/25.0.2:$PATH
