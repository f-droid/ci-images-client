FROM registry.gitlab.com/fdroid/ci-images-base
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
	&& mkdir -p /usr/share/doc/fdroidserver/examples \
	&& touch /usr/share/doc/fdroidserver/examples/fdroid-icon.png \
	&& touch /usr/share/doc/fdroidserver/examples/config.py \
	&& sed -Ei 's,^(\s+.+)("archive_icon),\1"archive_description = '"\'archived old builds\'\\\\n"'"\n\1\2,g' \
		/usr/lib/python3/dist-packages/fdroidserver/nightly.py \
	&& rm -rf /var/lib/apt/lists/*

# Also, the emulator can't find its own libraries from the SDK with
# LD_LIBRARY_PATH.
ENV LD_LIBRARY_PATH=$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib:$LD_LIBRARY_PATH \
    PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH

# TODO get specific version (28.0.23?) of emulator:
# https://dl.google.com/android/repository/repository2-1.xml
RUN	   echo y | sdkmanager --update > /dev/null \
	&& rm -rf $ANDROID_HOME/emulator \
	&& wget -q https://dl.google.com/android/repository/emulator-linux-5264690.zip \
	&& echo "48c1cda2bdf3095d9d9d5c010fbfb3d6d673e3ea  emulator-linux-5264690.zip" | sha1sum -c \
	&& unzip -qq -d $ANDROID_HOME emulator-linux-5264690.zip \
	&& rm -f emulator-linux-5264690.zip \
	&& grep -v '^License'   $ANDROID_HOME/tools/source.properties \
				$ANDROID_HOME/emulator/source.properties

COPY start-emulator /usr/bin/
COPY wait-for-emulator /usr/bin/
COPY test /
