FROM	debian:11-slim as build

ENV	GIT_USER="netbox-community"
ENV	GIT_REPO="netbox"
ENV	GIT_COMMIT="v3.3.6"
ENV	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"

ENV	PACKAGES="stunnel4 jq sudo postgresql libpq-dev python3-pip python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev graphviz libpq-dev libssl-dev redis-server zlib1g-dev libjpeg-dev"
ENV	PACKAGES_CLEAN="libpq-dev python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev libjpeg-dev"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN	apt-get update \
&&	apt-get -y install $PACKAGES

# Download source
WORKDIR	/opt/netbox
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz

# Copy root filesystem
COPY	rootfs /

# Verify
#RUN	HASH=$(sha256sum ${NETBOX##*/}) && [ "${HASH:0:64}" == "$NETBOX_SHA256" ] && echo "${NETBOX##*/}: valid " || { echo -e "Stored Hash: $NETBOX_SHA256\nFile Hash:   $HASH"; exit 1; }

# Install dependencies
RUN	pip3 install --no-cache-dir --upgrade pip \
;	pip3 install --no-cache-dir -r requirements.txt

# Setup netbox
WORKDIR	/opt/netbox/netbox
RUN	/etc/init.d/redis-server start \
&&	pg_ctlcluster 13 main start \
&&	sudo -u postgres psql < /db.sql \
&&	rm -v /db.sql \
&&	python3 manage.py migrate \
&&	python3 manage.py collectstatic --no-input \
&&	/etc/init.d/redis-server stop \
&&	pg_ctlcluster 13 main stop \
# Disable x-frame-options for usage with https://www.home-assistant.io/integrations/panel_iframe/
&&	sedfile -i "s;X_FRAME_OPTIONS = 'SAMEORIGIN';X_FRAME_OPTIONS = 'ALLOWALL';" /opt/netbox/netbox/netbox/settings.py \
# Let PostgreSQL listen on all interfaces
&&	sedfile -i "s/#listen_addresses =.*/listen_addresses = '*'/" /etc/postgresql/13/main/postgresql.conf \
&&	echo 'host all all 0.0.0.0/0 md5' >> /etc/postgresql/13/main/pg_hba.conf

# Cleanup
RUN	apt-get -y purge $PACKAGES_CLEAN \
&&	apt-get -y autoremove

# Install dumb-init
RUN	apt-get -y install dumb-init \
&&	rm -rf /var/lib/apt/lists/*

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

LABEL	io.hass.name="Netbox"
LABEL	io.hass.description="NetBox is an open source web application designed to help manage and document computer networks"
LABEL	io.hass.arch="${BUILD_ARCH}"
LABEL	io.hass.type="addon"
LABEL	io.hass.version="${VERSION}"
LABEL	image="casperklein/homeassistant-netbox:${VERSION}"
LABEL	maintainer="Casper Klein"
LABEL	url="https://github.com/casperklein/homeassistant-addons/tree/master/netbox"

EXPOSE	80

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD	["/run.sh"]

COPY	--from=build / /
