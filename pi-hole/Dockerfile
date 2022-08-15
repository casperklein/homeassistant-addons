# Customize upstream image #########################################################################
FROM	pihole/pihole:2022.07.1 as pihole

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Update base image packages, install jq and cleanup
RUN	apt-get update && apt-get -y upgrade \
&&	apt-get -y install jq \
&&	rm -rf /var/lib/apt/lists/*

# Copy root filesystem
COPY	rootfs /

# Disable x-frame-options for Home Assistant Ingress
RUN	sedfile -i '/"X-Frame-Options"/ s/DENY/SAMEORIGIN/g' /etc/.pihole/advanced/lighttpd.conf*

# Fix Ingress caching problem
RUN	sedfile -i 's/"mod_expire"/#"mod_expire"/g'	/etc/.pihole/advanced/lighttpd.conf* \
&&	sedfile -i 's/^expire.url/#expire.url/g'	/etc/.pihole/advanced/lighttpd.conf*

RUN	rm /bin/sedfile

# Silent capsh error output
# https://github.com/pi-hole/docker-pi-hole/pull/1133
# FROM	alpine:3 as patch
# COPY	--from=pihole /bash_functions.sh /
# RUN	apk upgrade --no-cache \
# &&	apk add --no-cache patch wget \
# &&	wget --progress=dot:giga https://patch-diff.githubusercontent.com/raw/pi-hole/docker-pi-hole/pull/1133.diff \
# &&	patch -i 1133.diff bash_functions.sh

# Build dnscrypt-proxy from source #################################################################
FROM	golang:bullseye as dnscrypt

ENV	GIT_USER="dnscrypt"
ENV	GIT_REPO="dnscrypt-proxy"
ENV	GIT_COMMIT="2.1.2"
ENV	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"
ENV	DEBIAN_FRONTEND=noninteractive

RUN	apt-get update && apt-get -y upgrade

WORKDIR	/$GIT_REPO
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz
WORKDIR	/$GIT_REPO/dnscrypt-proxy
RUN	go build -ldflags="-s -w" -mod vendor

# Check if build args are not empty ################################################################
FROM	bash:latest

ARG	BUILD_ARCH
ARG	VERSION

RUN	[ -z "$BUILD_ARCH" ] && echo "Error: Build argument 'BUILD_ARCH' is missing" && exit 1 || true
RUN	[ -z "$VERSION" ] && echo "Error: Build argument 'VERSION' is missing" && exit 1 || true

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
# docker-image-options pihole/pihole:2022.07 | sort | grep -v -e LABEL -e 'ENV PIHOLE_DOCKER_TAG'
ENTRYPOINT ["/s6-init"]
ENV DNSMASQ_USER="pihole"
ENV FTL_CMD="no-daemon"
ENV IPv6="True"
ENV PATH="/opt/pihole:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV PHP_ENV_CONFIG="/etc/lighttpd/conf-enabled/15-fastcgi-php.conf"
ENV PHP_ERROR_LOG="/var/log/lighttpd/error-pihole.log"
ENV phpver="php"
ENV PIHOLE_DOCKER_TAG="2022.07.1"
ENV PIHOLE_INSTALL="/etc/.pihole/automated install/basic-install.sh"
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"
ENV S6_KEEP_ENV="1"
ENV S6_LOGGING="0"
ENV S6_OVERLAY_VERSION="v2.1.0.2"
ENV ServerIP="0.0.0.0"
EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 67/udp
EXPOSE 80/tcp
HEALTHCHECK CMD dig +short +norecurse +retry=0 @127.0.0.1 pi.hole || exit 1
SHELL ["/bin/bash","-c"]

COPY	--from=dnscrypt /dnscrypt-proxy/dnscrypt-proxy/dnscrypt-proxy /
COPY	--from=pihole / /

# COPY	--from=patch /bash_functions.sh /
