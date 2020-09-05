#FROM	debian:10-slim as build
FROM	alpine:3.12 as build

ENV	USER="casperklein"
ENV	NAME="homeassistant-ycast"

#ENV	PACKAGES="python3 python3-pip python3-setuptools zlib1g-dev libjpeg-dev"
#ENV	PACKAGES_CLEAN="python3-pip python3-setuptools zlib1g-dev"
ENV	PACKAGES="python3 py3-pip python3-dev jpeg-dev zlib-dev build-base jq"
ENV	PACKAGES_CLEAN="python3-dev zlib-dev build-base"

#SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
#RUN	apt-get update \
#&&	apt-get -y install $PACKAGES
RUN	apk update --no-cache \
&&	apk add    --no-cache $PACKAGES

# Install python packages
RUN	pip3 install --no-cache requests flask PyYAML Pillow

# Copy root filesystem
COPY	rootfs /

# Cleanup
RUN	pip3 uninstall --no-cache-dir -y setuptools pip

#RUN     apt-get -y purge $PACKAGES_CLEAN \
#&&	apt -y autoremove
RUN	apk del --no-cache $PACKAGES_CLEAN

#RUN	find /usr/local/lib -name \*.pyc -delete
RUN	find /usr/ -name '*.pyc' -delete

# Build final image
#RUN	apt-get -y install dumb-init \
#&&	rm -rf /var/lib/apt/lists/*
FROM	scratch
COPY	--from=build / /
#ENTRYPOINT ["/usr/bin/dumb-init", "--"]

EXPOSE	80

WORKDIR	/ycast
CMD	["/run.sh"]

ARG	BUILD_ARCH
ENV	VERSION="1.0.10"
LABEL	io.hass.name="YCast"
LABEL	io.hass.description="Self hosted vTuner internet radio service emulation"
LABEL	io.hass.arch="${BUILD_ARCH}"
LABEL	io.hass.type="addon"
LABEL	io.hass.version="${VERSION}"
LABEL	image="casperklein/homeassistant-ycast:${VERSION}"
LABEL	maintainer="Casper Klein"
LABEL	url="https://github.com/casperklein/homeassistant-addons/tree/master/ycast"
