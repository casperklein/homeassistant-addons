#!/bin/bash

set -ueo pipefail

if [ ! -d /data/postgresql ]; then
	# Migrate DB to persistant storage
	echo "Migrating DB.."
	mkdir -p /data/postgresql/11
	mv /var/lib/postgresql/11/main /data/postgresql/11

	# Override secret key from image
	echo "Generating new secret key.."
	KEY=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 50 || true)
	sed -i "s/^SECRET_KEY.*/SECRET_KEY = '$KEY'/" /opt/netbox/netbox/netbox/configuration.py
fi

# Change PostgreSQL data directory
sed -i "s;^data_directory.*;data_directory = '/data/postgresql/11/main';" /etc/postgresql/11/main/postgresql.conf

# Get user/pass from Home Assistant options
USER=$(jq --raw-output '.user' /data/options.json)
PASS=$(jq --raw-output '.password' /data/options.json)

# Get HTTPS settings
HTTPS=$(jq --raw-output '.https' /data/options.json)
CERT=$(jq --raw-output '.certfile' /data/options.json)
KEY=$(jq --raw-output '.keyfile' /data/options.json)

MAIL=netbox@localhost

# fix permissions after snapshot restore
chown -R postgres: /data/postgresql

/etc/init.d/redis-server start || {
	echo "Error: Failed to start redis-server"
	exit 1
} >&2

pg_ctlcluster 11 main start || {
	echo "Error: Failed to start postgresql-server"
	exit 1
} >&2

# add netbox superuser
if [ -n "$USER" ] && [ -n "$PASS" ]; then
	echo "Netbox: Creating new superuser: $USER"
	if ! python3 /opt/netbox/netbox/manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('$USER', '$MAIL','$PASS')"; then
		echo "Error: Failed to create superuser '$USER'."
		exit 1
	fi
fi

# run database migrations
python3 /opt/netbox/netbox/manage.py migrate

if [ "$HTTPS" = true ]; then
	[ ! -f "/ssl/$CERT" ] && echo "Error: Certificate '$CERT' not found." >&2 && exit 1
	[ ! -f "/ssl/$KEY" ] && echo "Error: Certificate key '$KEY' not found." >&2 && exit 1

	cat > /etc/stunnel/stunnel.conf <<-CONFIG
	pid = /var/run/stunnel.pid
	[https]
	accept  = 80
	connect = 443
	cert = /etc/stunnel/stunnel.pem
	CONFIG

	cat /ssl/{"$CERT","$KEY"} > /etc/stunnel/stunnel.pem
	chmod 400 /etc/stunnel/stunnel.pem

	/etc/init.d/stunnel4 start || {
		echo "Error: Failed to start stunnel SSL encryption wrapper."
		exit 1
	} >&2
fi

# start netbox
if [ "$HTTPS" = true ]; then
	exec python3 /opt/netbox/netbox/manage.py runserver 0.0.0.0:443 --insecure
else
	exec python3 /opt/netbox/netbox/manage.py runserver 0.0.0.0:80 --insecure
fi
