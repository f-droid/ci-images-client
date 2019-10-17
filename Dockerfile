FROM registry.gitlab.com/fdroid/ci-images-base:20180615
MAINTAINER team@f-droid.org

# This installs fdroidserver and all its requirements for things like
# fdroid nightly.  Also, since ci-images-base strips out the docs, we
# have to add in a fake fdroid-icon.png to make fdroid init happy.
# Some of these packages are used by the SDK emulator to gather info
# about the system.
RUN \
	printf "Package: androguard fdroidserver python3-asn1crypto\nPin: release a=stretch-backports\nPin-Priority: 500\n" \
		> /etc/apt/preferences.d/debian-stretch-backports.pref \
	&& echo "deb http://deb.debian.org/debian/ stretch-backports main" \
		> /etc/apt/sources.list.d/backports.list \
	&& apt-get update \
	&& apt-get -qy dist-upgrade \
	&& apt-get -qy install --no-install-recommends \
		androguard/stretch-backports \
		fdroidserver/stretch-backports \
		python3-asn1crypto/stretch-backports \
		file \
		libpulse0 \
		pciutils \
		mesa-utils \
		openssh-client \
		zip \
	&& apt-get -qy autoremove --purge \
	&& apt-get clean \
	&& mkdir -p /usr/share/doc/fdroidserver/examples \
	&& touch /usr/share/doc/fdroidserver/examples/fdroid-icon.png \
	&& touch /usr/share/doc/fdroidserver/examples/config.py \
	&& rm -rf /var/lib/apt/lists/*

# SDK components - the android tool is too dumb to with its license
# prompting so we have to install the packages one at a time to get
# reliability.
#
# Also, the emulator can't find its own libraries from the SDK with
# LD_LIBRARY_PATH.
ENV AVD_SDK="22" \
    AVD_TAG="default" \
    AVD_ARCH="armeabi-v7a" \
    LD_LIBRARY_PATH=$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib:$LD_LIBRARY_PATH \
    PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH

ENV AVD_PACKAGE="system-images;android-${AVD_SDK};${AVD_TAG};${AVD_ARCH}"

COPY repositories.cfg /root/.android/

# TODO get specific version (28.0.23?) of emulator:
# https://dl.google.com/android/repository/repository2-1.xml
RUN	   echo y | sdkmanager "platforms;android-${AVD_SDK}" > /dev/null \
	&& echo y | sdkmanager "$AVD_PACKAGE" > /dev/null \
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
