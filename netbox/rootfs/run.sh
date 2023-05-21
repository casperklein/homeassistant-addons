#!/bin/bash

set -ueo pipefail

if [ ! -d /data/postgresql/13 ]; then
	echo "Info: Migrating DB to persistant storage.."
	mkdir -p /data/postgresql/13
	mv /var/lib/postgresql/13/main /data/postgresql/13

	# Override secret key from image
	echo "Info: Generating new secret key.."
	KEY=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 50 || true)
	sedfile -i "s/^SECRET_KEY.*/SECRET_KEY = '$KEY'/" /opt/netbox/netbox/netbox/configuration.py
fi

# Change PostgreSQL data directory
sedfile -i "s;^data_directory.*;data_directory = '/data/postgresql/13/main';" /etc/postgresql/13/main/postgresql.conf

# Make media files persistant
if [ -d /data/media ]; then
	rm -rf /opt/netbox/netbox/media
else
	mv /opt/netbox/netbox/media /data/
fi
ln -s /data/media /opt/netbox/netbox/media

# Get user/pass from Home Assistant options
USER=$(jq --raw-output '.user' /data/options.json)
PASS=$(jq --raw-output '.password' /data/options.json)

# Get HTTPS settings
HTTPS=$(jq --raw-output '.https' /data/options.json)
CERT=$(jq --raw-output '.certfile' /data/options.json)
KEY=$(jq --raw-output '.keyfile' /data/options.json)

# Get netbox option
LOGIN_REQUIRED=$(jq --raw-output '.LOGIN_REQUIRED' /data/options.json)

MAIL=netbox@localhost

# fix permissions after snapshot restore
chown -R postgres: /data/postgresql

# TODO Remove with Debian 12 (Bookworm)
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
	# shellcheck disable=SC2024
	sudo -u postgres pg_dump netbox > /data/postgresql11_netbox.sql

	#echo "Info: Remove PostgreSQL 11.."
	pg_ctlcluster 11 main stop
	#apt-get -y purge postgresql-11 # Remove PostgreSQL directories when package is purged? [yes/no] --> don't know how to automatic answer this

	echo "Info: Import netbox database to new cluster.."
	pg_ctlcluster 13 main start
	sudo -u postgres psql -c 'drop database netbox' > /dev/null
	sudo -u postgres psql -c 'create database netbox' > /dev/null
	# shellcheck disable=SC2024
	sudo -u postgres psql netbox < /data/postgresql11_netbox.sql > /dev/null
	pg_ctlcluster 13 main stop

	echo "Info: Migration successful."
	rm -rf /data/postgresql/11
	rm /data/postgresql11_netbox.sql
	echo "Info: Cleanup done."
fi

# remove stale pid
rm -f /data/postgresql/13/main/postmaster.pid

/etc/init.d/redis-server start || {
	echo "Error: Failed to start redis-server"
	exit 1
} >&2

pg_ctlcluster 13 main start || {
	echo "Error: Failed to start postgresql-server"
	exit 1
} >&2

# set netbox option
if [ "$LOGIN_REQUIRED" = true ]; then
	# https://docs.netbox.dev/en/stable/configuration/security/#login_required
	echo "Info: Setting 'LOGIN_REQUIRED' to 'true' in configuration.py"
	sedfile -i 's/^LOGIN_REQUIRED = False$/LOGIN_REQUIRED = True/' /opt/netbox/netbox/netbox/configuration.py
fi

# import additional configuration (for plugins)
if [ -f "/config/netbox/configuration.py" ]; then
	echo "Info: Custom configuration found."
	cat /config/netbox/configuration.py >> /opt/netbox/netbox/netbox/configuration.py
fi

# ? pip3-venv
# source /opt/netbox/venv/bin/activate

# import additional requirements (for plugins)
if [ -f "/config/netbox/requirements.txt" ]; then
	echo "Info: Installing custom requirements.."
	pip install --no-cache-dir -r /config/netbox/requirements.txt
fi

# ? pip3-venv
# https://docs.netbox.dev/en/stable/installation/3-netbox/#run-the-upgrade-script

# - Create a Python virtual environment
# - Installs all required Python packages
# - Run database schema migrations
# - Builds the documentation locally (for offline use)
# - Aggregate static resource files on disk

# /opt/netbox/upgrade.sh
# ? ---------

echo "Info: Applying database migrations.."
python3 /opt/netbox/netbox/manage.py migrate

echo "Info: Collecting static files.."
python3 /opt/netbox/netbox/manage.py collectstatic --no-input

# add netbox superuser
if [ -n "$USER" ] && [ -n "$PASS" ]; then
	echo "Netbox: Creating new superuser: $USER"
	if ! python3 /opt/netbox/netbox/manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('$USER', '$MAIL','$PASS')"; then
		echo "Error: Failed to create superuser '$USER'."
		exit 1
	fi
fi

if [ "$HTTPS" = true ]; then
	[ ! -f "/ssl/$CERT" ] && echo "Error: Certificate '$CERT' not found." >&2 && exit 1
	[ ! -f "/ssl/$KEY" ] && echo "Error: Certificate key '$KEY' not found." >&2 && exit 1

	cat > /etc/stunnel/stunnel.conf <<-"CONFIG"
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
	PORT=443
else
	PORT=80
fi

# Housekeeping
# printf '%s %s\n' "$(date '+[%F %T %z]')" "Housekeeping.." # gunicorn style
printf '%s %s\n' "$(date '+[%d/%h/%G %T]')" "Housekeeping.."
python3 /opt/netbox/netbox/manage.py housekeeping	# one-shot
/opt/netbox/housekeeping-job.sh &			# run once a day

# https://docs.netbox.dev/en/stable/plugins/development/background-tasks/
echo "Info: Starting RQ worker process.."
python3 /opt/netbox/netbox/manage.py rqworker high default low &

echo "Info: Starting netbox.."
# exec gunicorn --bind 127.0.0.1:$PORT --pid /var/tmp/netbox.pid --pythonpath /opt/netbox/netbox --config /opt/netbox/gunicorn.py netbox.wsgi
exec python3 /opt/netbox/netbox/manage.py runserver 0.0.0.0:$PORT --insecure
