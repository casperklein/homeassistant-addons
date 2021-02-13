#FROM	debian:10-slim as build
FROM	alpine:3.13 as build

ENV	GIT_USER="milaq"
ENV	GIT_REPO="YCast"
ENV	GIT_COMMIT="f349a2686c336420b8e2dc4c9a2a9fc12dd4e358"
ENV	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"

#ENV	PACKAGES="python3 python3-pip python3-setuptools zlib1g-dev libjpeg-dev"
#ENV	PACKAGES_CLEAN="python3-pip python3-setuptools zlib1g-dev"
ENV	PACKAGES="python3 py3-pip python3-dev jpeg-dev zlib-dev build-base jq"
ENV	PACKAGES_CLEAN="python3-dev zlib-dev build-base"

#SHELL	["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR	/ycast
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz

# Install packages
#RUN	apt-get update \
#&&	apt-get -y install $PACKAGES
RUN	apk upgrade --no-cache \
&&	apk add --no-cache $PACKAGES

# Install python packages
RUN	pip3 install --no-cache-dir requests flask PyYAML Pillow

# Copy root filesystem
COPY	rootfs /

# Cleanup
RUN	pip3 uninstall --no-cache-dir -y setuptools pip

#RUN     apt-get -y purge $PACKAGES_CLEAN \
#&&	apt -y autoremove
RUN	apk del $PACKAGES_CLEAN

#RUN	find /usr/local/lib -name \*.pyc -delete
RUN	find /usr/ -name '*.pyc' -delete

#RUN	apt-get -y install dumb-init \
#&&	rm -rf /var/lib/apt/lists/*

# Check if build args are not empty ################################################################
FROM	bash:latest

ARG	BUILD_ARCH
ARG	VERSION

RUN	[ -z "$BUILD_ARCH" ] && echo "Error: Build argument 'BUILD_ARCH' is missing" && exit 1 || true
RUN	[ -z "$VERSION" ] && echo "Error: Build argument 'VERSION' is missing" && exit 1 || true

# Build final image ################################################################################
FROM	scratch
#ENTRYPOINT ["/usr/bin/dumb-init", "--"]

ARG	BUILD_ARCH
ARG	VERSION
LABEL	io.hass.name="YCast"
LABEL	io.hass.description="Self hosted vTuner internet radio service emulation"
LABEL	io.hass.arch="${BUILD_ARCH}"
LABEL	io.hass.type="addon"
LABEL	io.hass.version="${VERSION}"
LABEL	image="casperklein/homeassistant-ycast:${VERSION}"
LABEL	maintainer="Casper Klein"
LABEL	url="https://github.com/casperklein/homeassistant-addons/tree/master/ycast"

WORKDIR	/ycast
CMD	["/run.sh"]

EXPOSE	80

COPY	--from=build / /
