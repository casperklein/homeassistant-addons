FROM	alpine:3.13 AS build

ENV	GIT_USER="milaq"
ENV	GIT_REPO="YCast"
ENV	GIT_COMMIT="f349a2686c336420b8e2dc4c9a2a9fc12dd4e358"
ENV	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"

ENV	PACKAGES="python3 py3-pip python3-dev jpeg-dev zlib-dev build-base jq"
ENV	PACKAGES_CLEAN="python3-dev zlib-dev build-base"

# Check if build args are not empty ################################################################
ARG	BUILD_ARCH
ARG	VERSION
RUN	[ -z "$BUILD_ARCH" ] && echo "Error: Build argument 'BUILD_ARCH' is missing" && exit 1 || true
RUN	[ -z "$VERSION" ] && echo "Error: Build argument 'VERSION' is missing" && exit 1 || true

# Get ycast
WORKDIR	/ycast
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz

# Install packages
RUN	apk upgrade --no-cache \
&&	apk add --no-cache $PACKAGES

# Install python packages
RUN	pip3 install --no-cache-dir requests flask PyYAML Pillow

# Copy root filesystem
COPY	rootfs /

# Cleanup
RUN	pip3 uninstall --no-cache-dir -y setuptools pip

RUN	apk del $PACKAGES_CLEAN

RUN	find /usr/ -name '*.pyc' -delete

# Build final image ################################################################################
FROM	scratch

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
