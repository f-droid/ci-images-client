#
# Android image for GitLab CI

FROM fdroid/ci:base-20161223

# These packages are used by the SDK emulator to gather info about the
# system.
run apt-get update && apt-get install -y --no-install-recommends \
		file pciutils mesa-utils \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean

# the emulator sometimes can't fine these libraries from the SDK
env LD_LIBRARY_PATH $ANDROID_HOME/tools/lib64/qt/lib:$LD_LIBRARY_PATH


# SDK components - the android tool is too dumb to with its license prompting
# so we have to install the packages one at a time to get reliability
ENV TARGET_SDK="24"
RUN (while true; do sleep 5; echo y; done) | android --silent update sdk --no-ui --all --filter \
    "android-10,android-${TARGET_SDK},sys-img-x86-android-${TARGET_SDK},extra-android-m2repository"

# android-10 by default has ramSize=256 and heapSize=24
run echo no | android --verbose create avd --name fcl-test-10 --target android-10

# newer emulators default to having too much RAM
run sed -i \
	-e 's,^hw.ramSize=.*,hw.ramSize=512,' \
	-e 's,^vm.heapSize=.*,vm.heapSize=48,' \
	$ANDROID_HOME/platforms/android-${TARGET_SDK}/skins/QVGA/hardware.ini \
    && echo no | android --verbose create avd --name fcl-test-${TARGET_SDK} --skin QVGA --target android-${TARGET_SDK}

MAINTAINER team@f-droid.org
