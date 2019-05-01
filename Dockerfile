FROM registry.gitlab.com/fdroid/ci-images-base:20180615
MAINTAINER team@f-droid.org

# These packages are used by the SDK emulator to gather info about the
# system.

run echo "deb http://deb.debian.org/debian/ stretch-backports main" > /etc/apt/sources.list.d/backports.list \
	&& apt-get update \
	&& apt-get -qy dist-upgrade \
	&& apt-get -qy install --no-install-recommends \
		androguard/stretch-backports \
		fdroidserver/stretch-backports \
		file \
		libpulse0 \
		pciutils \
		mesa-utils \
		openssh-client \
		zip \
	&& apt-get -qy autoremove --purge \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# SDK components - the android tool is too dumb to with its license
# prompting so we have to install the packages one at a time to get
# reliability.
#
# Also, the emulator can't find its own libraries from the SDK with
# LD_LIBRARY_PATH.
ENV AVD_SDK="22" \
    AVD_TAG="default" \
    LD_LIBRARY_PATH=$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib:$LD_LIBRARY_PATH \
    PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH

ENV AVD_PACKAGE="system-images;android-${AVD_SDK};${AVD_TAG};armeabi-v7a"

COPY repositories.cfg /root/.android/

# TODO get specific version (28.0.23?) of emulator:
# https://dl.google.com/android/repository/repository2-1.xml
RUN	   echo y | sdkmanager "platforms;android-${AVD_SDK}" > /dev/null \
	&& echo y | sdkmanager "$AVD_PACKAGE" > /dev/null \
	&& echo y | sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" > /dev/null \
	&& echo y | sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2" > /dev/null \
	&& echo y | $ANDROID_HOME/tools/bin/sdkmanager --update > /dev/null \
	&& rm -rf $ANDROID_HOME/emulator \
	&& wget -q https://dl.google.com/android/repository/emulator-linux-5264690.zip \
	&& echo "48c1cda2bdf3095d9d9d5c010fbfb3d6d673e3ea  emulator-linux-5264690.zip" | sha1sum -c \
	&& unzip -qq -d $ANDROID_HOME emulator-linux-5264690.zip \
	&& echo no | avdmanager -v create avd --name avd$AVD_SDK --tag $AVD_TAG --package $AVD_PACKAGE \
	&& grep -v '^License'   $ANDROID_HOME/tools/source.properties \
				$ANDROID_HOME/emulator/source.properties \
				$ANDROID_HOME/system-images/android-*/*/*/source.properties

COPY wait-for-emulator /usr/bin/
COPY test /
