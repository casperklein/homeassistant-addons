# Customzie upstream image #########################################################################
FROM	pihole/pihole:v5.8.1 as pihole

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Update base image packages, install jq and cleanup
RUN	apt-get update && apt-get -y upgrade \
&&	apt-get -y install jq \
&&	rm -rf /var/lib/apt/lists/*

# Disable x-frame-options for Home Assistant Ingress
RUN	sed -i '/"X-Frame-Options"/ s/DENY/SAMEORIGIN/g' /etc/.pihole/advanced/lighttpd.conf*

# Fix Ingress caching problem
RUN	sed -i 's/"mod_expire"/#"mod_expire"/g'	/etc/.pihole/advanced/lighttpd.conf* \
&&	sed -i 's/^expire.url/#expire.url/g'	/etc/.pihole/advanced/lighttpd.conf*

# Copy root filesystem
COPY	rootfs /

# Fix chmod/chown errors on startup
# PR 676: Not yet merged in upstream
# https://github.com/pi-hole/docker-pi-hole/pull/676
#RUN	wget https://patch-diff.githubusercontent.com/raw/pi-hole/docker-pi-hole/pull/676.diff \
#&&	patch -i 676.diff bash_functions.sh \
#&&	apt-get -y purge patch \
#&&	rm 676.diff

# Build dnscrypt-proxy from source #################################################################
FROM	ubuntu:20.04 as dnscrypt

ENV	GIT_USER="dnscrypt"
ENV	GIT_REPO="dnscrypt-proxy"
ENV	GIT_COMMIT="2.1.0"
ENV	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"
ENV	DEBIAN_FRONTEND=noninteractive

RUN	apt-get update && apt-get -y upgrade && apt-get -y --no-install-recommends install golang

WORKDIR	/$GIT_REPO
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz
WORKDIR	dnscrypt-proxy
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
ENTRYPOINT [ "/s6-init" ]
ENV	DNSMASQ_USER root
ENV	FTL_CMD no-daemon
ENV	IPv6 True
ENV	PATH /opt/pihole:${PATH}
ENV	PHP_ENV_CONFIG /etc/lighttpd/conf-enabled/15-fastcgi-php.conf
ENV	PHP_ERROR_LOG /var/log/lighttpd/error.log
ENV	PIHOLE_INSTALL /etc/.pihole/automated install/basic-install.sh
ENV	S6_BEHAVIOUR_IF_STAGE2_FAILS 2
ENV	S6_KEEP_ENV 1
ENV	S6_LOGGING 0
ENV	ServerIP 0.0.0.0
ENV	VERSION v5.8.1
#EXPOSE	443
EXPOSE	53 53/udp
#EXPOSE	67/udp
EXPOSE	80
HEALTHCHECK CMD dig +norecurse +retry=0 @127.0.0.1 pi.hole || exit 1

COPY	--from=dnscrypt /dnscrypt-proxy/dnscrypt-proxy/dnscrypt-proxy /
COPY	--from=pihole / /
