#!/bin/bash

set -ueo pipefail

_shutdown() {
	echo "Info: Container shutdown in progress.."
	# supervisorctl shutdown &> /dev/null
	kill 1
	if [ -n "${NETBOX_PID:-}" ]; then
		kill "$NETBOX_PID" 2> /dev/null
		while kill -0 "$NETBOX_PID" 2> /dev/null; do
			echo "Info: Netbox still running. Waiting.."
			sleep 1
		done
	fi
}
trap _shutdown EXIT

# get addon identifier
# printf %s https://github.com/casperklein/homeassistant-addons | sha1sum | head -c8
# 0da538cf

# ? HOST                                 CONTAINER
# ? ---------------------------------------------------
# ? /addon_configs/0da538cf_netbox  -->  /config
# ? /config                         -->  /homeassistant
# ? <persistant storage>            -->  /data

NETBOX_CONFIG_CUSTOM=/config/configuration.py
NETBOX_CONFIG=/opt/netbox/netbox/netbox/configuration.py
NETBOX_SECRET_KEY=/data/secret-key.py

if [ ! -f "$NETBOX_SECRET_KEY" ]; then
	# Override secret key from image
	# https://docs.netbox.dev/en/stable/configuration/required-parameters/#secret_key
	echo "Info: Generating new secret key.."
	SECRET_KEY=$(tr -dc A-Za-z0-9 2> /dev/null < /dev/urandom | head -c 50 || true)
	if [[ ! $SECRET_KEY =~ ^[A-Za-z0-9]{50}$ ]]; then
		echo "Error: Key generation failed."
		exit 1
	fi >&2
	echo "SECRET_KEY = '$SECRET_KEY'" > "$NETBOX_SECRET_KEY"
fi

if [ ! -d /data/postgresql/13 ]; then
	echo "Info: Moving DB to persistant storage.."
	mkdir -p /data/postgresql/13
	mv /var/lib/postgresql/13/main /data/postgresql/13
fi
# Change PostgreSQL data directory
sedfile -i "s;^data_directory.*;data_directory = '/data/postgresql/13/main';" /etc/postgresql/13/main/postgresql.conf

# Make media files persistant
if [ ! -d /data/media ]; then
	echo "Info: Moving media to persistant storage.."
	mv /opt/netbox/netbox/media /data/
fi
rm -rf /opt/netbox/netbox/media
ln -s /data/media /opt/netbox/netbox/media

# Get user/pass from Home Assistant options
USER=$(jq --raw-output '.user' /data/options.json)
PASS=$(jq --raw-output '.password' /data/options.json)

# Get HTTPS settings
HTTPS=$(jq --raw-output '.https' /data/options.json)
CERT=$(jq --raw-output '.certfile' /data/options.json)
KEY=$(jq --raw-output '.keyfile' /data/options.json)

# Create /config/configuration-merged.py ?
DEBUG=$(jq --raw-output '.debug' /data/options.json)

# Get netbox option
LOGIN_REQUIRED=$(jq --raw-output '.LOGIN_REQUIRED' /data/options.json)

# admin email address
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
	apt-get -qq install postgresql-11 &> /dev/null
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

# set netbox option
if [ "$LOGIN_REQUIRED" = true ]; then
	# https://docs.netbox.dev/en/stable/configuration/security/#login_required
	echo "Info: Setting 'LOGIN_REQUIRED' to 'true' in configuration.py"
	sedfile -i 's/^LOGIN_REQUIRED = False$/LOGIN_REQUIRED = True/' "$NETBOX_CONFIG"
fi

echo -e "\n# custom configuration starts here" >> "$NETBOX_CONFIG"

# update secret key
cat "$NETBOX_SECRET_KEY" >> "$NETBOX_CONFIG"

# import additional configuration (e.g. for plugins)
if [ -f "/homeassistant/netbox/configuration.py" ]; then
	echo "Info: Custom configuration (config/netbox/configuration.py) found."
	cat /homeassistant/netbox/configuration.py >> "$NETBOX_CONFIG"
fi
if [ -f "$NETBOX_CONFIG_CUSTOM" ]; then
	echo "Info: Custom configuration (addon_configs/0da538cf_netbox/configration.py) found."
	dos2unix -q "$NETBOX_CONFIG_CUSTOM"
	cat "$NETBOX_CONFIG_CUSTOM" >> "$NETBOX_CONFIG"
fi

# import additional requirements (e.g. for plugins)
if [ -f "/homeassistant/netbox/requirements.txt" ]; then
	echo "Info: Installing custom requirements (config/netbox/requirements).."
	pip install --no-cache-dir -r /homeassistant/netbox/requirements.txt
fi
if [ -f "/config/requirements.txt" ]; then
	dos2unix -q /config/requirements.txt
	echo "Info: Installing custom requirements (addon_configs/0da538cf_netbox/requirements.txt).."
	pip install --no-cache-dir -r /config/requirements.txt
fi

if [ "$DEBUG" = true ]; then
	echo "# This file is auto-generated and just for debugging" > /config/configuration-merged.py
	cat "$NETBOX_CONFIG" > /config/configuration-merged.py
fi

supervisorctl start redis > /dev/null
while ! redis-cli ping &> /dev/null; do
	echo "Info: Waiting until Redis is ready.."
	sleep 1
done
echo "Info: Redis is ready.."

supervisorctl start postgresql > /dev/null
while ! pg_isready -q; do
	echo "Info: Waiting until Postgresql is ready.."
	sleep 1
done
echo "Info: Postgresql is ready.."

# ? pip3-venv
# source /opt/netbox/venv/bin/activate

# ? pip3-venv
# https://docs.netbox.dev/en/stable/installation/3-netbox/#run-the-upgrade-script

# - Create a Python virtual environment
# - Installs all required Python packages
# - Run database schema migrations
# - Builds the documentation locally (for offline use)
# - Aggregate static resource files on disk

# /opt/netbox/upgrade.sh
# ? ---------

MANAGE_PY=/opt/netbox/netbox/manage.py

echo "Info: Applying database migrations.."
python3 "$MANAGE_PY" migrate

echo "Info: Collecting static files.."
python3 "$MANAGE_PY" collectstatic --no-input

# add netbox superuser
if [ -n "$USER" ] && [ -n "$PASS" ]; then
	echo "Netbox: Creating new superuser: $USER"
	if ! python3 "$MANAGE_PY" shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('$USER', '$MAIL','$PASS')"; then
		echo "Error: Failed to create superuser '$USER'."
		exit 1
	fi >&2
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
python3 "$MANAGE_PY" housekeeping	# one-shot
supervisorctl start housekeeping > /dev/null            # run once a day

# https://docs.netbox.dev/en/stable/plugins/development/background-tasks/
echo "Info: Starting RQ worker process.."
supervisorctl start rqworker > /dev/null

echo "Info: Starting netbox.."
# exec gunicorn --bind 127.0.0.1:$PORT --pid /var/tmp/netbox.pid --pythonpath /opt/netbox/netbox --config /opt/netbox/gunicorn.py netbox.wsgi

python3 "$MANAGE_PY" runserver 0.0.0.0:$PORT --insecure &
NETBOX_PID=$!
wait
