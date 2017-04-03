FROM registry.gitlab.com/fdroid/ci-images-base:20170314
MAINTAINER team@f-droid.org

run apt-get update && apt-get install -y --no-install-recommends \
		bash \
		dash \
		gcc \
		libjpeg-dev \
		libffi-dev \
		python3-clint \
		python3-dev \
		python3-git \
		python3-libcloud \
		python3-paramiko \
		python3-pil \
		python3-pip \
		python3-pyasn1 \
		python3-pyasn1-modules \
		python3-requests \
		python3-yaml \
		python3-venv \
		pyflakes \
		pylint \
		pep8 \
		rsync \
		ruby \
		zlib1g-dev \
        && apt-get install -y --no-install-recommends -t jessie-backports \
		libssl-dev \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY test /
