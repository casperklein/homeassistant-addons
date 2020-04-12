FROM	debian:10-slim as build

ENV	USER="casperklein"
ENV	NAME="hassio-netbox"
ENV	VERSION="2.7.12"

ENV	NETBOX="https://github.com/netbox-community/netbox/archive/v2.7.12.tar.gz"
ENV	NETBOX_SHA256="4c5f6f5fae54dbd2e4463de1c290c196269fedd0958864ba4de7405d16e677ab"
ENV	NETBOX_DIR="netbox-2.7.12"

ENV	PACKAGES="jq sudo postgresql libpq-dev python3-pip python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev graphviz libpq-dev libssl-dev redis-server zlib1g-dev libjpeg-dev"
ENV	PACKAGES_CLEAN="libpq-dev python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev libjpeg-dev"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN	apt-get update \
&&	apt-get -y install $PACKAGES

# Copy root filesystem
COPY	rootfs /

# Setup netbox
ADD	$NETBOX /
RUN	HASH=$(sha256sum ${NETBOX##*/}) && [ "${HASH:0:64}" == "$NETBOX_SHA256" ] && echo "${NETBOX##*/}: valid " || { echo -e "Stored Hash: $NETBOX_SHA256\nFile Hash:   $HASH"; exit 1; }
RUN	tar -xzf ${NETBOX##*/} -C /opt

WORKDIR	/opt
RUN	ln -s $NETBOX_DIR/ netbox
RUN	mv /configuration.py /opt/netbox/netbox/netbox/

WORKDIR	/opt/netbox/
RUN	pip3 install --no-cache-dir -r requirements.txt

WORKDIR	/opt/netbox/netbox
RUN	/etc/init.d/redis-server start \
&&	pg_ctlcluster 11 main start \
&&	sudo -u postgres psql < /db.sql \
&&	rm -v /db.sql \
&&	python3 manage.py migrate \
&&	python3 manage.py collectstatic --no-input \
&&	/etc/init.d/redis-server stop \
&&	pg_ctlcluster 11 main stop

# Cleanup
RUN	apt-get -y purge $PACKAGES_CLEAN \
&&	apt -y autoremove

# Build final image
RUN	apt-get -y install dumb-init \
&&	rm -rf /var/lib/apt/lists/*
FROM	scratch
COPY	--from=build / /
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

EXPOSE	80

CMD	["/run.sh"]
