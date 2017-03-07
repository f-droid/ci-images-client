FROM registry.gitlab.com/fdroid/ci-images-base:20170314

run apt-get update && apt-get install -y --no-install-recommends \
		rsync gcc python3-dev python3-pip python3-venv \
		pyflakes pylint pep8 dash bash ruby texinfo \
		libjpeg-dev zlib1g-dev libffi-dev libssl-dev \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

MAINTAINER team@f-droid.org

COPY test /
