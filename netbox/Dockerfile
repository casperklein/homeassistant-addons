FROM	debian:11-slim as build

ENV	GIT_USER="netbox-community"
ENV	GIT_REPO="netbox"
ENV	GIT_COMMIT="v3.4.3"
ENV	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"

#ENV	PACKAGES="python3-venv stunnel4 jq sudo postgresql libpq-dev python3-pip python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev graphviz libpq-dev libssl-dev redis-server zlib1g-dev libjpeg-dev"
ENV	PACKAGES="python3-pip"
# python3-venv"
#                                                  python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev"
# ENV	PACKAGES_CLEAN="                           python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev"
ENV	PACKAGES="$PACKAGES stunnel4 jq sudo postgresql redis-server dumb-init"


SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
ENV	DEBIAN_FRONTEND=noninteractive
RUN	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y --no-install-recommends install $PACKAGES \
&&	rm -rf /var/lib/apt/lists/*

# Download source
WORKDIR	/opt/netbox
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz

# Copy root filesystem
COPY	rootfs /

WORKDIR	/opt/netbox/netbox/netbox
RUN	cp configuration_example.py configuration.py

# Customize
# https://github.com/netbox-community/netbox/blob/develop/netbox/netbox/configuration_example.py
#	ALLOWED_HOSTS = [] --> ALLOWED_HOSTS = ['*']
RUN	sedfile -i "s/^ALLOWED_HOSTS = \[\]$/ALLOWED_HOSTS = ['*']/" configuration.py
#	Set PostgreSQL user/password
RUN	sedfile -i "s/^    'USER': '',               # PostgreSQL username$/    'USER': 'netbox',               # PostgreSQL username/" configuration.py
RUN	sedfile -i "s/^    'PASSWORD': '',           # PostgreSQL password$/    'PASSWORD': 'netbox',           # PostgreSQL password/" configuration.py
#	If not set to a dummy value, 'python3 manage.py migrate' fails
RUN	sedfile -i "s/^SECRET_KEY = ''$/SECRET_KEY = '**************************************************'/" configuration.py

# Install dependencies
# ? Disable, when pip-venv is used
WORKDIR	/opt/netbox
RUN	pip3 install --no-cache-dir --upgrade pip setuptools wheel \
;	pip3 install --no-cache-dir -r requirements.txt

# Setup netbox
WORKDIR	/opt/netbox/netbox
RUN	/etc/init.d/redis-server start \
&&	pg_ctlcluster 13 main start \
&&	sudo -u postgres psql < /db.sql \
&&	rm -v /db.sql \
# ? no pip3-venv
&&	python3 manage.py migrate \
&&	python3 manage.py collectstatic --no-input \
# ? pip3-venv; see run.sh for comments
# &&	/opt/netbox/upgrade.sh \
&&	/etc/init.d/redis-server stop \
&&	pg_ctlcluster 13 main stop \
#	Disable x-frame-options for usage with https://www.home-assistant.io/integrations/panel_iframe/
&&	sedfile -i "s;X_FRAME_OPTIONS = 'SAMEORIGIN';X_FRAME_OPTIONS = 'ALLOWALL';" /opt/netbox/netbox/netbox/settings.py \
#	Let PostgreSQL listen on all interfaces
&&	sedfile -i "s/#listen_addresses =.*/listen_addresses = '*'/" /etc/postgresql/13/main/postgresql.conf \
&&	echo 'host all all 0.0.0.0/0 md5' >> /etc/postgresql/13/main/pg_hba.conf

# Setup gunicorn
# RUN	cp /opt/netbox/contrib/gunicorn.py	/opt/netbox/gunicorn.py \
# &&	sedfile -i "/bind = '127.0.0.1:8001'/d"	/opt/netbox/gunicorn.py

# Build the local documentation
# TODO Needs reverse proxy for auto-indexing: http://netboxhost/static/docs/ --> http://netboxhost/static/docs/index.html
WORKDIR	/opt/netbox/
RUN	mkdocs build

# Cleanup
# RUN	apt-get -y purge $PACKAGES_CLEAN \
# RUN	apt-get -y autoremove

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

WORKDIR	/opt/netbox
