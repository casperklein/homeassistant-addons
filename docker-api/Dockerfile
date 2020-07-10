FROM	alpine:3 as build

ENV	USER="casperklein"
ENV	NAME="homeassistant-docker-api"

ENV	PACKAGES="bash socat"

# Install packages
RUN	apk update \
&&	apk upgrade \
&&	apk add $PACKAGES

# Copy root filesystem
COPY	rootfs /

# Build final image
FROM	scratch
COPY	--from=build / /

EXPOSE	2375

CMD	["/run.sh"]

ARG	BUILD_ARCH
ENV	VERSION="0.0.4"
LABEL	io.hass.name="docker-api"
LABEL	io.hass.description="Expose Home Assistant OS Docker API via network"
LABEL	io.hass.arch="${BUILD_ARCH}"
LABEL	io.hass.type="addon"
LABEL	io.hass.version="${VERSION}"
LABEL	image="casperklein/homeassistant-docker-api:${VERSION}"
LABEL	maintainer="Casper Klein"
LABEL	url="https://github.com/casperklein/homeassistant-addons/tree/master/docker-api"
