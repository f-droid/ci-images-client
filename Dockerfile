FROM registry.gitlab.com/fdroid/ci-images-base:20180111
MAINTAINER team@f-droid.org

# These packages are used by the SDK emulator to gather info about the
# system.

run echo "deb http://deb.debian.org/debian/ stretch-backports main" > /etc/apt/sources.list.d/backports.list \
	&& apt-get update \
	&& apt-get dist-upgrade \
	&& apt-get install -y --no-install-recommends \
		fdroidserver/stretch-backports \
		file \
		pciutils \
		python3-qrcode \
		mesa-utils \
		openssh-client \
		zip \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean

# SDK components - the android tool is too dumb to with its license prompting
# so we have to install the packages one at a time to get reliability.
# Also, the emulator can't find its own libraries from the SDK with LD_LIBRARY_PATH.
ENV TARGET_SDK="24" LD_LIBRARY_PATH=$ANDROID_HOME/tools/lib64:$ANDROID_HOME/tools/lib64/qt/lib:$LD_LIBRARY_PATH

RUN    echo y | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-10" \
    && echo y | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-${TARGET_SDK}" \
    && echo y | $ANDROID_HOME/tools/bin/sdkmanager "system-images;android-${TARGET_SDK};default;armeabi-v7a" \
    && echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    && echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"

# android-10 by default has ramSize=256 and heapSize=24
# newer emulators default to requiring too much RAM
RUN echo no | android --verbose create avd --name fcl-test-10 --target android-10 \
    && sed -i \
	-e 's,^hw.ramSize=.*,hw.ramSize=512,' \
	-e 's,^vm.heapSize=.*,vm.heapSize=48,' \
	$ANDROID_HOME/platforms/android-${TARGET_SDK}/skins/QVGA/hardware.ini \
    && echo no | android --verbose create avd --name fcl-test-${TARGET_SDK} --skin QVGA --target android-${TARGET_SDK} \
    && df -h

COPY test /
