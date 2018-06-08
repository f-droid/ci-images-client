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
#
# Google dropped the ;default; emulator flavor in android-25, so we
# have to use google_apis :-|
ENV AVD_SDK="25" \
    AVD_TAG="fdroid_privext" \
    LD_LIBRARY_PATH=$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib:$LD_LIBRARY_PATH \
    PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH

ENV AVD_PACKAGE="system-images;android-${AVD_SDK};${AVD_TAG};armeabi-v7a"

COPY repositories.cfg /root/.android/

RUN	   echo y | sdkmanager "platforms;android-${AVD_SDK}" > /dev/null \
	&& echo y | sdkmanager "emulator" > /dev/null \
	&& echo y | sdkmanager "$AVD_PACKAGE" > /dev/null \
	&& echo y | sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" > /dev/null \
	&& echo y | sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2" > /dev/null \
	&& echo y | $ANDROID_HOME/tools/bin/sdkmanager --update > /dev/null

COPY wait-for-emulator /usr/bin/

# android-10 by default has ramSize=256 and heapSize=24
# newer emulators default to requiring too much RAM
RUN sed -i \
		-e 's,^hw.ramSize=.*,hw.ramSize=512,' \
		-e 's,^vm.heapSize=.*,vm.heapSize=48,' \
		$ANDROID_HOME/platforms/android-*/skins/QVGA/hardware.ini \
	&& echo no | avdmanager -v create avd --name avd$AVD_SDK --tag $AVD_TAG --package $AVD_PACKAGE

COPY test /
