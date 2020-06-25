FROM	debian:10-slim as build

ENV	USER="casperklein"
ENV	NAME="homeassistant-docker-tcp"
ENV	VERSION="0.0.2"

ENV	PACKAGES="socat"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN	apt-get update \
&&	apt-get -y install $PACKAGES

# Copy root filesystem
COPY	rootfs /

# Build final image
RUN	rm -rf /var/lib/apt/lists/*
FROM	scratch
COPY	--from=build / /

EXPOSE	2375

CMD	["/run.sh"]

ARG	BUILD_ARCH
LABEL	io.hass.name="docker-tcp"
LABEL	io.hass.description="Expose Home Assistant OS Docker API via TCP"
LABEL	io.hass.arch="${BUILD_ARCH}"
LABEL	io.hass.type="addon"
LABEL	io.hass.version="${VERSION}"
LABEL	image="casperklein/homeassistant-docker-tcp:${VERSION}"
LABEL	maintainer="Casper Klein"
LABEL	url="https://github.com/casperklein/homeassistant-addons/tree/master/docker-tcp"
