FROM	alpine:3 AS build

ENV	PACKAGES="bash socat"

# Check if build args are not empty ################################################################
ARG	BUILD_ARCH
ARG	VERSION
RUN	[ -z "$BUILD_ARCH" ] && echo "Error: Build argument 'BUILD_ARCH' is missing" && exit 1 || true
RUN	[ -z "$VERSION" ] && echo "Error: Build argument 'VERSION' is missing" && exit 1 || true

# Install packages
RUN	apk upgrade --no-cache \
&&	apk add --no-cache $PACKAGES

# Copy root filesystem
COPY	rootfs /

# Build final image ################################################################################
FROM	scratch
COPY	--from=build / /

EXPOSE	2375

CMD	["/run.sh"]

ARG	BUILD_ARCH
ARG	VERSION
LABEL	io.hass.name="docker-api"
LABEL	io.hass.description="Expose Home Assistant OS Docker API via network"
LABEL	io.hass.arch="${BUILD_ARCH}"
LABEL	io.hass.type="addon"
LABEL	io.hass.version="${VERSION}"
LABEL	image="casperklein/homeassistant-docker-api:${VERSION}"
LABEL	maintainer="Casper Klein"
LABEL	url="https://github.com/casperklein/homeassistant-addons/tree/master/docker-api"
