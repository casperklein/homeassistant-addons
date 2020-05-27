FROM	pihole/pihole:v5.0

ENV	USER="casperklein"
ENV	NAME="homeassistant-pihole"
ENV	VERSION="5.0.2"

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

ARG	BUILD_ARCH
LABEL	io.hass.name="Pi-hole"
LABEL	io.hass.description="Network-wide Ad Blocking"
LABEL	io.hass.arch="${BUILD_ARCH}"
LABEL	io.hass.type="addon"
LABEL	io.hass.version="${VERSION}"
LABEL	image="casperklein/homeassistant-pihole:${VERSION}"
LABEL	maintainer="Casper Klein"
LABEL	url="https://github.com/casperklein/homeassistant-addons/tree/master/pi-hole"
