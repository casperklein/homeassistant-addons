FROM	debian:12-slim AS build

ENV	GIT_USER="netbox-community"
ENV	GIT_REPO="netbox"
ENV	GIT_COMMIT="v4.4.2"
ENV	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"

#? https://docs.netbox.dev/en/stable/installation/3-netbox/#install-system-packages
# ENV	PACKAGES="python3-venv stunnel4 jq sudo postgresql redis-server dumb-init supervisor procps dos2unix nginx net-tools"
ENV	PACKAGES="             stunnel4 jq sudo postgresql redis-server dumb-init supervisor procps dos2unix nginx net-tools"
ENV	PACKAGES_BUILD="python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev"
ENV	PACKAGES="$PACKAGES $PACKAGES_BUILD"
ENV 	PACKAGES_CLEAN="$PACKAGES_BUILD"

SHELL	["/bin/bash", "-e", "-o", "pipefail", "-c"]

# Check if build args are not empty
ARG	BUILD_ARCH
ARG	VERSION
RUN	[ -z "$BUILD_ARCH" ] && echo "Error: Build argument 'BUILD_ARCH' is missing" && exit 1 || true
RUN	[ -z "$VERSION" ] && echo "Error: Build argument 'VERSION' is missing" && exit 1 || true

# Install packages
ENV	DEBIAN_FRONTEND=noninteractive
RUN <<EOF
	apt-get update
	apt-get -y upgrade
	apt-get -y --no-install-recommends install $PACKAGES
	rm -rf /var/lib/apt/lists/*
EOF

# Download source
WORKDIR	/opt/netbox
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz

# Copy root filesystem
COPY	rootfs /

RUN <<EOF
	# Change supervisord defaults
	# Fix for: CRIT Supervisor is running as root. Privileges were not dropped because no user is specified in the config file.
	sedfile -i 's|\[supervisord\]|[supervisord]\nuser=root|'                            /etc/supervisor/supervisord.conf

	# Fix for: CRIT Server 'unix_http_server' running without any HTTP authentication checking.
	sedfile -i 's|\[unix_http_server\]|[unix_http_server]\nusername=foo\npassword=foo|' /etc/supervisor/supervisord.conf
	sedfile -i 's|\[supervisorctl\]|[supervisorctl]\nusername=foo\npassword=foo|'       /etc/supervisor/supervisord.conf
EOF

WORKDIR	/opt/netbox/netbox/netbox

RUN <<EOF
	cp configuration_example.py configuration.py

	# Customize netbox
	# https://github.com/netbox-community/netbox/blob/develop/netbox/netbox/configuration_example.py
	# ALLOWED_HOSTS = [] --> ALLOWED_HOSTS = ['*']
	sedfile -i "s/^ALLOWED_HOSTS = \[\]$/ALLOWED_HOSTS = ['*']/" configuration.py

	# Set PostgreSQL user/password
	sedfile -i "s/^        'USER': '',               # PostgreSQL username$/        'USER': 'netbox',               # PostgreSQL username/" configuration.py
	sedfile -i "s/^        'PASSWORD': '',           # PostgreSQL password$/        'PASSWORD': 'netbox',           # PostgreSQL password/" configuration.py

	# If not set to a dummy value, 'python3 manage.py migrate' fails
	sedfile -i "s/^SECRET_KEY = ''$/SECRET_KEY = '**************************************************'/" configuration.py
EOF

# Install 'uv', an extremely fast Python package and project manager, written in Rust.
# https://github.com/astral-sh/uv
COPY	--from=ghcr.io/astral-sh/uv:latest /uv /usr/bin/uv

# create and use python virtual environment
ENV	VIRTUAL_ENV=/opt/netbox/.venv
RUN	uv venv "$VIRTUAL_ENV"
ENV	PATH="$VIRTUAL_ENV/bin:$PATH"

WORKDIR	/opt/netbox
# RUN	pip3 install --no-cache-dir --upgrade pip setuptools wheel \
# RUN	pip3 install --no-cache-dir --upgrade pip wheel \

RUN <<EOF
	# Install dependencies
	uv pip install --no-cache-dir -r requirements.txt
	# Needed for some plugins, e.g. qrcode: https://github.com/casperklein/homeassistant-addons/issues/29
	uv pip install --no-cache-dir setuptools wheel
EOF

# Setup netbox
WORKDIR	/opt/netbox/netbox
RUN <<EOF
	/etc/init.d/redis-server start
	pg_ctlcluster 15 main start

	sudo -u postgres psql < /db.sql
	rm -v /db.sql

	netbox-upgrade.sh

	/etc/init.d/redis-server stop
	pg_ctlcluster 15 main stop

	# Disable x-frame-options for usage with https://www.home-assistant.io/integrations/panel_iframe/
	sedfile -i "s;X_FRAME_OPTIONS = 'SAMEORIGIN';X_FRAME_OPTIONS = 'ALLOWALL';" /opt/netbox/netbox/netbox/settings.py

	# Let PostgreSQL listen on all interfaces
	sedfile -i "s/#listen_addresses =.*/listen_addresses = '*'/" /etc/postgresql/15/main/postgresql.conf
	echo 'host all all 0.0.0.0/0 md5' >> /etc/postgresql/15/main/pg_hba.conf
EOF

RUN <<EOF
	# Customize redis
	sedfile -i 's|^daemonize yes$|daemonize no|' /etc/redis/redis.conf

	# Setup nginx
	mv /opt/netbox/contrib/nginx.conf /etc/nginx/sites-available/netbox
	rm /etc/nginx/sites-enabled/default

	# Setup gunicorn
	mv /opt/netbox/contrib/gunicorn.py	/opt/netbox/gunicorn.py
EOF

# Build the local documentation
WORKDIR	/opt/netbox/
RUN	mkdocs build

# Cleanup
RUN <<EOF
	apt-get -y purge $PACKAGES_CLEAN
	apt-get -y autoremove
EOF

# Build final image
FROM	scratch

ARG	BUILD_ARCH
ARG	VERSION
ENV	VERSION="$VERSION"

# activate python virtual environment
# needed for rqworker, run.sh, housekeeping.sh
# same as 'source /opt/netbox/.venv/bin/activate'
ENV	PATH="/opt/netbox/.venv/bin:$PATH"

# Show python output immediately, not buffered.
ENV     PYTHONUNBUFFERED=1

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

CMD	["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

COPY	--from=build / /

WORKDIR	/opt/netbox
