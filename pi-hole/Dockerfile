# Customize upstream image #########################################################################
FROM	pihole/pihole:2024.07.0 AS pihole

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Check if build args are not empty ################################################################
ARG	BUILD_ARCH
ARG	VERSION
RUN	[ -z "$BUILD_ARCH" ] && echo "Error: Build argument 'BUILD_ARCH' is missing" && exit 1 || true
RUN	[ -z "$VERSION" ] && echo "Error: Build argument 'VERSION' is missing" && exit 1 || true

# Update base image packages, install jq and cleanup
RUN	apt-get update && apt-get -y upgrade \
&&	apt-get -y install jq \
&&	rm -rf /var/lib/apt/lists/*

# Copy root filesystem
COPY	rootfs /

# Disable x-frame-options for Home Assistant Ingress
RUN	sedfile -i '/"X-Frame-Options"/ s/DENY/SAMEORIGIN/g' /etc/.pihole/advanced/pihole-admin.conf

# Remove docker-pi-hole update instructions
RUN	sedfile -i 's|To install updates, <a href="https://github.com/pi-hole/docker-pi-hole#upgrading-persistence-and-customizations" \
rel="noopener" target="_blank">replace this old container with a fresh upgraded image</a>.||g' /var/www/html/admin/scripts/pi-hole/php/footer.php

RUN	rm /bin/sedfile

# Build dnscrypt-proxy from source #################################################################
FROM	golang:bullseye AS dnscrypt

ENV	GIT_USER="dnscrypt"
ENV	GIT_REPO="dnscrypt-proxy"
ENV	GIT_COMMIT="2.1.5"
ENV	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"
ENV	DEBIAN_FRONTEND=noninteractive

RUN	apt-get update && apt-get -y upgrade

WORKDIR	/$GIT_REPO
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz
WORKDIR	/$GIT_REPO/dnscrypt-proxy
RUN	go build -ldflags="-s -w" -mod vendor

# Build final image ################################################################################
FROM	scratch

ARG	BUILD_ARCH
ARG	VERSION

LABEL	io.hass.name="Pi-hole"
LABEL	io.hass.description="Network-wide Ad Blocking"
LABEL	io.hass.arch="${BUILD_ARCH}"
LABEL	io.hass.type="addon"
LABEL	io.hass.version="${VERSION}"

LABEL	image="casperklein/homeassistant-pihole:${VERSION}"
LABEL	maintainer="Casper Klein"
LABEL	url="https://github.com/casperklein/homeassistant-addons/tree/master/pi-hole"

# From base image
# docker-image-options pihole/pihole:latest | sort | grep -v LABEL
ENTRYPOINT ["/s6-init"]
ENV DNSMASQ_USER="pihole"
ENV FTL_CMD="no-daemon"
ENV FTLCONF_LOCAL_IPV4="0.0.0.0"
ENV IPv6="True"
ENV PATH="/opt/pihole:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV PHP_ERROR_LOG="/var/log/lighttpd/error-pihole.log"
ENV phpver="php"
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME="0"
ENV S6_KEEP_ENV="1"
EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 67/udp
EXPOSE 80/tcp
HEALTHCHECK CMD dig +short +norecurse +retry=0 @127.0.0.1 pi.hole || exit 1
SHELL ["/bin/bash","-c"]

COPY	--from=dnscrypt /dnscrypt-proxy/dnscrypt-proxy/dnscrypt-proxy /
COPY	--from=pihole / /
