#!/bin/bash

set -ueo pipefail

if [ ! -d /data/postgresql/13 ]; then
	echo "Migrating DB to persistant storage.."
	mkdir -p /data/postgresql/13
	mv /var/lib/postgresql/13/main /data/postgresql/13

	# Override secret key from image
	echo "Generating new secret key.."
	KEY=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 50 || true)
	sedfile -i "s/^SECRET_KEY.*/SECRET_KEY = '$KEY'/" /opt/netbox/netbox/netbox/configuration.py
fi

# Change PostgreSQL data directory
sedfile -i "s;^data_directory.*;data_directory = '/data/postgresql/13/main';" /etc/postgresql/13/main/postgresql.conf

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

# Upgrade Postgres 11 to 13
if [ -d /data/postgresql/11 ]; then
	echo "Info: PostgreSQL 11 database found. Start migration to version 13.."
	cat >> /etc/apt/sources.list <<-"EOF"
		deb http://deb.debian.org/debian buster main
		deb http://security.debian.org/debian-security buster/updates main
		deb http://deb.debian.org/debian buster-updates main
	EOF
	echo "Info: Install PostgreSQL 11.."
	apt-get -qq update
	apt-get -qq install postgresql-11 &>/dev/null
	echo "Info: Configure PostgreSQL 11.."
	sedfile -i "s;^data_directory.*;data_directory = '/data/postgresql/11/main';" /etc/postgresql/11/main/postgresql.conf
	sedfile -i 's|port = .*|port = 5432|g' /etc/postgresql/11/main/postgresql.conf # when a second PosgreSQL instance is installed, the port is incremented --> 5433

	echo "Info: Export netbox database from old cluster.."
	pg_ctlcluster 11 main start
	sudo -u postgres pg_dump netbox > /data/postgresql11_netbox.sql

	#echo "Info: Remove PostgreSQL 11.."
	pg_ctlcluster 11 main stop
	#apt-get -y purge postgresql-11 # Remove PostgreSQL directories when package is purged? [yes/no] --> don't know how to automatic answer this

	echo "Info: Import netbox database to new cluster.."
	pg_ctlcluster 13 main start
	sudo -u postgres psql -c 'drop database netbox' > /dev/null
	sudo -u postgres psql -c 'create database netbox' > /dev/null
	sudo -u postgres psql netbox < /data/postgresql11_netbox.sql > /dev/null
	pg_ctlcluster 13 main stop

	echo "Info: Migration successful."
	rm -rf /data/postgresql/11
	rm /data/postgresql11_netbox.sql
	echo "Info: Cleanup done."
fi

/etc/init.d/redis-server start || {
	echo "Error: Failed to start redis-server"
	exit 1
} >&2

pg_ctlcluster 13 main start || {
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
