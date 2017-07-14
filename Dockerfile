FROM registry.gitlab.com/fdroid/ci-images-base:20170703
MAINTAINER team@f-droid.org

# These packages are used by the SDK emulator to gather info about the
# system.
run apt-get update && apt-get install -y --no-install-recommends \
		file \
                pciutils \
                mesa-utils \
                zip \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean

# SDK components - the android tool is too dumb to with its license prompting
# so we have to install the packages one at a time to get reliability.
# Also, the emulator can't find its own libraries from the SDK with LD_LIBRARY_PATH.
ENV TARGET_SDK="24" LD_LIBRARY_PATH=$ANDROID_HOME/tools/lib64:$ANDROID_HOME/tools/lib64/qt/lib:$LD_LIBRARY_PATH

# The ConstraintLayout dependency works differently from other android-sdk components.
# The other components are installed below, and thus we can pipe "y" to them to accept
# licenses as they are installed. However the ConstraintLayout is installed at build-time
# by gradle and thus we don't really have the option of accepting the license. Here is
# a hack. See https://code.google.com/p/android/issues/detail?id=212128#c17 and
# https://hub.docker.com/r/iluretar/gitlab-ci-android/~/dockerfile/.
RUN mkdir -p $ANDROID_HOME/licenses/ \
    && echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license \
    && echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license \
    && echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" \
    && echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.1" \
    && echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    && echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2" \
    && (while true; do sleep 5; echo y; done) | android --silent update sdk --no-ui --all --filter \
    "android-10,android-${TARGET_SDK},sys-img-armeabi-v7a-android-${TARGET_SDK},extra-android-m2repository"

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
