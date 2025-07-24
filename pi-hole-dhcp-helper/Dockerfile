FROM	alpine:latest AS build

RUN	apk upgrade --no-cache && apk --no-cache add bash docker-cli dumb-init dhcp-helper jq

# Copy root filesystem
COPY	rootfs /

# Build final image ################################################################################
FROM	scratch

ARG	BUILD_ARCH
ARG	VERSION

LABEL	io.hass.name="Pi-hole-DHCP-helper"
LABEL	io.hass.description="DHCP-helper for Pi-hole"
LABEL	io.hass.arch="${BUILD_ARCH}"
LABEL	io.hass.type="addon"
LABEL	io.hass.version="${VERSION}"

LABEL	image="casperklein/homeassistant-pi-hole-dhcp-helper:${VERSION}"
LABEL	maintainer="Casper Klein"
LABEL	url="https://github.com/casperklein/homeassistant-addons/tree/master/pi-hole-dhcp-helper"

COPY	--from=build / /

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD	[ "/usr/bin/run.sh" ]

EXPOSE	67/udp
