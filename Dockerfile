FROM registry.gitlab.com/fdroid/fdroidserver:buildserver-bullseye
MAINTAINER team@f-droid.org

# This installs fdroidserver and all its requirements for things like
# fdroid nightly.  Also, since ci-images-base strips out the docs, we
# have to add in a fake fdroid-icon.png to make fdroid init happy.
# Some of these packages are used by the SDK emulator to gather info
# about the system.
RUN 	apt-get update \
	&& apt-get -qy dist-upgrade \
	&& apt-get -qy install --no-install-recommends \
		fdroidserver \
		file \
		libpulse0 \
		pciutils \
		mesa-utils \
		openssh-client \
		zip \
	&& apt-get -qy autoremove --purge \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Also, the emulator can't find its own libraries from the SDK with
# LD_LIBRARY_PATH.
ENV ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk
ENV LD_LIBRARY_PATH=$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib:$LD_LIBRARY_PATH \
    PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/7.0/bin:$ANDROID_HOME/platform-tools:$PATH

RUN ls -l ~/.cache/sdkmanager || true

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=android-emulator
# https://dl.google.com/android/repository/repository2-1.xml
RUN	. /etc/profile.d/bsenv.sh \
	&& rm -rf $ANDROID_HOME/emulator \
	&& rm -rf ~/.cache/sdkmanager \
	&& /usr/bin/sdkmanager 'cmdline-tools;7.0' 'emulator;30.3.5' \
	&& rm -rf ~/.cache/sdkmanager \
	&& grep -v '^License'   $ANDROID_HOME/tools/source.properties \
				$ANDROID_HOME/emulator/source.properties

# Long timeouts are helpful to make CI jobs fail less often.
#
# Disable gradle daemon, it is to speed up repeat builds, and gitlab
# runners can have limited memory.  That means a running daemon's
# memory cache will compete with the emulator.
ENV ADB_INSTALL_TIMEOUT=8 \
    GRADLE_USER_HOME=$HOME/.gradle \
    GRADLE_OPTS=-Dorg.gradle.daemon=false
RUN mkdir -p $GRADLE_USER_HOME && echo "org.gradle.daemon=false" >> $GRADLE_USER_HOME/gradle.properties

RUN mkdir -p /root/.android/ /home/vagrant/.android/
COPY repositories.cfg /root/.android/
COPY repositories.cfg /home/vagrant/.android/
COPY start-emulator /usr/bin/
COPY wait-for-emulator /usr/bin/
COPY test /
