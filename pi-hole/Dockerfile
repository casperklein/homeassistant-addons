FROM	pihole/pihole:v5.1.1 as build

ENV	USER="casperklein"
ENV	NAME="homeassistant-pihole"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Update base image packages
RUN	apt-get update && apt-get -y upgrade && rm -rf /var/lib/apt/lists/*

# Copy root filesystem
COPY	rootfs /

# Disable x-frame-options for Home Assistant Ingress
RUN	sed -i '/"X-Frame-Options"/ s/DENY/ALLOW/g' /etc/.pihole/advanced/lighttpd.conf*

# Unset Pi-hole password for Home Assistant Ingress
#RUN	echo | pihole -a -p

# For network host mode, ServerIP have to be set --> https://github.com/pi-hole/docker-pi-hole/issues/495
#RUN	echo 'ServerIP=$(ip route get 1.1.1.1 | cut -d" " -f7)' >> /bash_functions.sh

# https://github.com/pi-hole/docker-pi-hole/issues/505
# Custom Pi-hole upstream DNS server
#ENV	DNS1="1.1.1.1"
#ENV	DNS2="8.8.8.8"

FROM	scratch
COPY	--from=build / /

ARG	BUILD_ARCH
ENV	VERSION="5.1.1"
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
ENV DNSMASQ_USER root
ENV FTL_CMD no-daemon
ENV IPv6 True
ENV PATH /opt/pihole:${PATH}
ENV PHP_ENV_CONFIG '/etc/lighttpd/conf-enabled/15-fastcgi-php.conf'
ENV PHP_ERROR_LOG '/var/log/lighttpd/error.log'
ENV PIHOLE_INSTALL /root/ph_install.sh
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2
ENV S6_KEEP_ENV 1
ENV S6_LOGGING 0
ENV S6OVERLAY_RELEASE https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz
ENV ServerIP 0.0.0.0
ENV VERSION v5.1.1
EXPOSE 443
EXPOSE 53 53/udp
EXPOSE 67/udp
EXPOSE 80
HEALTHCHECK CMD dig +norecurse +retry=0 @127.0.0.1 pi.hole || exit 1
