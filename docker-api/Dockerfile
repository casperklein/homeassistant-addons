FROM	alpine:3 as build

ENV	PACKAGES="bash socat"

# Install packages
RUN	apk update \
&&	apk upgrade \
&&	apk add $PACKAGES

# Copy root filesystem
COPY	rootfs /

# Check if build args are not empty ################################################################
FROM	bash:latest

ARG	BUILD_ARCH
ARG	VERSION

RUN	[ -z "$BUILD_ARCH" ] && echo "Error: Build argument 'BUILD_ARCH' is missing" && exit 1 || true
RUN	[ -z "$VERSION" ] && echo "Error: Build argument 'VERSION' is missing" && exit 1 || true

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
