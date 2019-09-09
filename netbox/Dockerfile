FROM    debian:10-slim as build

ENV	PACKAGES="jq sudo postgresql libpq-dev python3-pip python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev graphviz libpq-dev libssl-dev redis-server zlib1g-dev"

# Install packages
RUN     apt-get update \
&&	apt-get -y install $PACKAGES

# Copy root filesystem
COPY	rootfs /

# do stuff
ADD	https://github.com/netbox-community/netbox/archive/v2.6.3.tar.gz /
RUN	/etc/init.d/redis-server start \
&&	pg_ctlcluster 11 main start \
&&	sudo -u postgres psql < db.sql \
&&	tar -xzf v2.6.3.tar.gz -C /opt \
&&	cd /opt/ \
&&	ln -s netbox-2.6.3/ netbox \
&&	cd /opt/netbox/ \
&&	pip3 install -r requirements.txt \
&&	mv /configuration.py /opt/netbox/netbox/netbox/ \
&&	cd /opt/netbox/netbox \
&&	python3 manage.py migrate \
&&	python3 manage.py collectstatic --no-input \
&&	python3 manage.py loaddata initial_data \
&&	pg_ctlcluster 11 main stop \
&&	/etc/init.d/redis-server stop

# Build final image
RUN	apt-get -y install dumb-init \
&&	rm -rf /var/lib/apt/lists/*
FROM	scratch
COPY	--from=build / /
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

EXPOSE  80

CMD	["/run.sh"]
