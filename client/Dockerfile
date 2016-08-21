from mvdan/fdroid-ci:base-20160820

# These packages are used by the SDK emulator to gather info about the
# system.
run apt-get update && apt-get install -y --no-install-recommends \
		file pciutils mesa-utils \
	&& rm -rf /var/lib/apt/lists/*

env LD_LIBRARY_PATH $ANDROID_HOME/tools/lib64/qt/lib:$LD_LIBRARY_PATH

# SDK components - the sdk is too dumb to just use `yes`, it will read
# more than one line per question
run { while true; do echo y; sleep 1; done } | android -s update sdk --no-ui -a -t android-24,extra-android-m2repository

run { while true; do echo y; sleep 1; done } | android -s update sdk --no-ui -a -t android-10
# android-10 by default has ramSize=256 and heapSize=24
run echo no | android --verbose create avd --name fcl-test-10 --target android-10

run { while true; do echo y; sleep 1; done } | android -s update sdk --no-ui -a -t sys-img-x86-android-24
# newer emulators default to having too much RAM
run sed -i \
	-e 's,^hw.ramSize=.*,hw.ramSize=512,' \
	-e 's,^vm.heapSize=.*,vm.heapSize=48,' \
	$ANDROID_HOME/platforms/android-24/skins/QVGA/hardware.ini
run echo no | android --verbose create avd --name fcl-test-24 --skin QVGA --target android-24
