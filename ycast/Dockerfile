FROM	debian:10-slim as build

ENV	USER="casperklein"
ENV	NAME="hassio-ycast"
ENV	VERSION="1.0.0"

ENV	PACKAGES="python3 python3-pip python3-setuptools zlib1g-dev libjpeg-dev"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN	apt-get update \
&&	apt-get -y install $PACKAGES

# Install python packages
RUN	pip3 install --no-cache requests flask PyYAML Pillow

# Copy root filesystem
COPY	rootfs /

# Cleanup
RUN     apt-get -y purge python3-pip python3-setuptools zlib1g-dev \
&&	apt -y autoremove

# Build final image
RUN	apt-get -y install dumb-init \
&&	rm -rf /var/lib/apt/lists/*
FROM	scratch
COPY	--from=build / /
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

EXPOSE  80

WORKDIR	/ycast
CMD	python3 -m ycast -d
