from fdroid/ci:base-20161223

run apt-get update && apt-get install -y --no-install-recommends \
		rsync gcc python3-dev python3-pip python3-venv \
		pyflakes pylint pep8 dash bash ruby texinfo \
		libjpeg-dev zlib1g-dev libffi-dev libssl-dev \
	&& apt clean \
	&& rm -rf /var/lib/apt/lists/*
