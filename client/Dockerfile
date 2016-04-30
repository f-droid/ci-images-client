from mvdan/fdroid-ci:base-20160429

# These packages are used by the SDK emulator to gather info about the
# system.
run apt-get update && apt-get install -y --no-install-recommends \
		file pciutils mesa-utils \
	&& rm -rf /var/lib/apt/lists/*

env LD_LIBRARY_PATH $ANDROID_HOME/tools/lib64/qt/lib:$LD_LIBRARY_PATH

# SDK components - the sdk is too dumb to just use `yes`, it will read
# more than one line per question
run { while true; do echo y; sleep 1; done } | android -s update sdk --no-ui -a -t android-23,extra-android-m2repository
