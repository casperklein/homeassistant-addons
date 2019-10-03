FROM	debian:10-slim as build

ENV	PACKAGES="jq sudo postgresql libpq-dev python3-pip python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev graphviz libpq-dev libssl-dev redis-server zlib1g-dev libjpeg-dev"

# Install packages
RUN     apt-get update \
&&	apt-get -y install $PACKAGES

# Copy root filesystem
COPY	rootfs /

# do stuff
ADD	https://github.com/netbox-community/netbox/archive/v2.6.3.tar.gz /
RUN	tar -xzf v2.6.3.tar.gz -C /opt

WORKDIR	/opt
RUN	ln -s netbox-2.6.3/ netbox
RUN	mv /configuration.py /opt/netbox/netbox/netbox/

WORKDIR	/opt/netbox/
RUN	pip3 install -r requirements.txt

WORKDIR	/opt/netbox/netbox
RUN	/etc/init.d/redis-server start \
&&	pg_ctlcluster 11 main start \
&&	sudo -u postgres psql < /db.sql \
&&	rm /db.sql \
&&	python3 manage.py migrate \
&&	python3 manage.py collectstatic --no-input \
&&	python3 manage.py loaddata initial_data \
&&	/etc/init.d/redis-server stop \
&&	pg_ctlcluster 11 main stop

# Build final image
RUN	apt-get -y install dumb-init \
&&	rm -rf /var/lib/apt/lists/*
FROM	scratch
COPY	--from=build / /
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

EXPOSE  80

CMD	["/run.sh"]
