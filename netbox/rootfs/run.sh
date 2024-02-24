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

if [ ! -d /data/postgresql/15 ]; then
	echo "Info: Moving database to persistant storage.."
	mkdir -p /data/postgresql/15
	mv /var/lib/postgresql/15/main /data/postgresql/15
fi
# Change PostgreSQL data directory
echo "Info: Configuring PostgreSQL.."
sedfile -i "s;^data_directory.*;data_directory = '/data/postgresql/15/main';" /etc/postgresql/15/main/postgresql.conf

# Make media files persistant
if [ ! -d /data/media ]; then
	echo "Info: Moving media to persistant storage.."
	mv /opt/netbox/netbox/media /data/
fi
echo "Info: Setting up media usage.."
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

# fix permissions after snapshot restore
echo "Info: Fixing PostgreSQL permissions.."
chown -R postgres: /data/postgresql

# Debian 11 to 12
# Upgrade PostgreSQL 13 to 15
if [ -d /data/postgresql/13 ]; then
	source /pg_upgrade.sh
fi

# remove stale pid
rm /data/postgresql/15/main/postmaster.pid 2>/dev/null && echo "Info: Removing stale PostgreSQL pid file.."

# set netbox option
if [ "$LOGIN_REQUIRED" = true ]; then
	# https://docs.netbox.dev/en/stable/configuration/security/#login_required
	echo "Info: Setting 'LOGIN_REQUIRED' to 'true' in configuration.py"
	sedfile -i 's/^LOGIN_REQUIRED = False$/LOGIN_REQUIRED = True/' "$NETBOX_CONFIG"
fi

echo -e "\n# custom configuration starts here" >> "$NETBOX_CONFIG"

# update secret key
echo "Info: Restoring secret key.."
cat "$NETBOX_SECRET_KEY" >> "$NETBOX_CONFIG"

# import additional configuration (e.g. for plugins)
if [ -f "/homeassistant/netbox/configuration.py" ]; then
	# TODO kept for compatibility
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
	# TODO kept for compatibility
	echo "Info: Installing custom requirements (config/netbox/requirements).."
	pip install --no-cache-dir -r /homeassistant/netbox/requirements.txt
fi
if [ -f "/config/requirements.txt" ]; then
	dos2unix -q /config/requirements.txt
	echo "Info: Installing custom requirements (addon_configs/0da538cf_netbox/requirements.txt).."
	pip install --no-cache-dir -r /config/requirements.txt
fi

if [ "$DEBUG" = true ]; then
	echo "Info: DEBUG is enabled. Creating /config/configuration-merged.py"
	echo    "# $(date +%c)"                                           > /config/configuration-merged.py
	echo -e "# This file is auto-generated and just for debugging\n" >> /config/configuration-merged.py
	cat "$NETBOX_CONFIG"                                             >> /config/configuration-merged.py
fi

echo "Info: Starting redis.."
supervisorctl start redis > /dev/null
while ! redis-cli ping &> /dev/null; do
	echo "Info: Waiting until Redis is ready.."
	sleep 1
done
echo "Info: Redis is ready.."

echo "Info: Starting PostgreSQL.."
supervisorctl start postgresql > /dev/null
while ! pg_isready -q; do
	echo "Info: Waiting until PostgreSQL is ready.."
	sleep 1
done
echo "Info: PostgreSQL is ready.."

MANAGE_PY="python3 /opt/netbox/netbox/manage.py"

# run migration when needed
echo "Info: Check if migration is needed.."
if ! $MANAGE_PY migrate --check &>/dev/null; then
	netbox-upgrade.sh
fi

# add netbox superuser
if [ -n "$USER" ] && [ -n "$PASS" ]; then
	echo "Netbox: Creating new superuser: $USER"
	# Create user + API token: https://github.com/netbox-community/netbox-docker/blob/f1ca9ab7ebc16b288fd9da8825176c75d6b7ea4f/docker/docker-entrypoint.sh#L74-L80
	if ! $MANAGE_PY shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('$USER', '${MAIL:-}','$PASS')"; then
		echo "Error: Failed to create superuser '$USER'."
		exit 1
	fi >&2
fi

# enable HTTPS
if [ "$HTTPS" = true ]; then
	echo "Info: Enabling HTTPS.."
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
echo "Info: Starting housekeeping background job.."
supervisorctl start housekeeping > /dev/null

# https://docs.netbox.dev/en/stable/plugins/development/background-tasks/
echo "Info: Starting RQ worker process.."
supervisorctl start rqworker > /dev/null

echo "Info: Starting netbox.."
# exec gunicorn --bind 127.0.0.1:$PORT --pid /var/tmp/netbox.pid --pythonpath /opt/netbox/netbox --config /opt/netbox/gunicorn.py netbox.wsgi

[ "$DEBUG" = true ] && echo "Debug: Startup took $SECONDS seconds."

$MANAGE_PY runserver 0.0.0.0:$PORT --insecure &
NETBOX_PID=$!
wait
