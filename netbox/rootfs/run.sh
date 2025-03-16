#!/bin/bash

set -ueo pipefail

_log() {
	local RED=$'\e[0;31m'
	local GREEN=$'\e[0;32m'
	# local YELLOW=$'\e[0;33m'
	local BLUE=$'\e[0;34m'
	local RESET=$'\e[0m'
	local OUTPUT
	case "$1" in
		debug)	OUTPUT="${BLUE}Debug: $2$RESET" ;;
		error)	OUTPUT="${RED}Error: $2$RESET"  ;;
		info)	OUTPUT="${GREEN}Info: $2$RESET" ;;
	esac
	echo "$OUTPUT"
}

_debug() { _log debug "$1"; }
_error() { _log error "$1"; }
_info()  { _log info  "$1"; }

_shutdown() {
	_info "Container shutdown in progress.."
	# supervisorctl shutdown &> /dev/null
	kill 1
	if [ -n "${NETBOX_PID:-}" ]; then
		kill "$NETBOX_PID" 2> /dev/null
		while kill -0 "$NETBOX_PID" 2> /dev/null; do
			_info "Netbox still running. Waiting.."
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
	_info "Generating new secret key.."
	SECRET_KEY=$(tr -dc A-Za-z0-9 2> /dev/null < /dev/urandom | head -c 50 || true)
	if [[ ! $SECRET_KEY =~ ^[A-Za-z0-9]{50}$ ]]; then
		_error "Key generation failed."
		exit 1
	fi >&2
	echo "SECRET_KEY = '$SECRET_KEY'" > "$NETBOX_SECRET_KEY"
fi

if [ ! -d /data/postgresql/15 ]; then
	_info "Moving database to persistant storage.."
	mkdir -p /data/postgresql/15
	mv /var/lib/postgresql/15/main /data/postgresql/15
fi
# Change PostgreSQL data directory
_info "Configuring PostgreSQL.."
sedfile -i "s;^data_directory.*;data_directory = '/data/postgresql/15/main';" /etc/postgresql/15/main/postgresql.conf

# Make media files persistant
if [ ! -d /data/media ]; then
	_info "Moving media to persistant storage.."
	mv /opt/netbox/netbox/media /data/
fi
_info "Setting up media usage.."
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
_info "Fixing PostgreSQL permissions.."
chown -R postgres: /data/postgresql

# Debian 11 to 12
# Upgrade PostgreSQL 13 to 15
if [ -d /data/postgresql/13 ]; then
	source /pg_upgrade.sh
fi

# remove stale pid
rm /data/postgresql/15/main/postmaster.pid 2>/dev/null && _info "Removing stale PostgreSQL pid file.."

# set netbox option
if [ "$LOGIN_REQUIRED" = false ]; then
	# https://docs.netbox.dev/en/stable/configuration/security/#login_required
	_info "Setting 'LOGIN_REQUIRED' to 'false' in configuration.py"
	sedfile -i 's/^LOGIN_REQUIRED = True$/LOGIN_REQUIRED = False/' "$NETBOX_CONFIG"
fi

echo -e "\n# custom configuration starts here" >> "$NETBOX_CONFIG"

# update secret key
_info "Restoring secret key.."
cat "$NETBOX_SECRET_KEY" >> "$NETBOX_CONFIG"

# import additional configuration (e.g. for plugins)
if [ -f "/homeassistant/netbox/configuration.py" ]; then
	# TODO kept for compatibility: 2024-02-24 / netbox 3.7.3
	_info "Custom configuration (config/netbox/configuration.py) found."
	cat /homeassistant/netbox/configuration.py >> "$NETBOX_CONFIG"
fi
if [ -f "$NETBOX_CONFIG_CUSTOM" ]; then
	_info "Custom configuration (addon_configs/0da538cf_netbox/configration.py) found."
	dos2unix -q "$NETBOX_CONFIG_CUSTOM"
	cat "$NETBOX_CONFIG_CUSTOM" >> "$NETBOX_CONFIG"
fi

# import additional requirements (e.g. for plugins)
if [ -f "/homeassistant/netbox/requirements.txt" ]; then
	# TODO kept for compatibility: 2024-02-24 / netbox 3.7.3
	_info "Installing custom requirements (config/netbox/requirements).."
	uv pip install --no-cache-dir -r /homeassistant/netbox/requirements.txt
fi
if [ -f "/config/requirements.txt" ]; then
	dos2unix -q /config/requirements.txt
	_info "Installing custom requirements (addon_configs/0da538cf_netbox/requirements.txt).."
	uv pip install --no-cache-dir -r /config/requirements.txt
fi

if [ "$DEBUG" = true ]; then
	_debug "Creating /config/configuration-merged.py for debugging.."
	echo    "# $(date +%c)"                                           > /config/configuration-merged.py
	echo -e "# This file is auto-generated and just for debugging\n" >> /config/configuration-merged.py
	cat "$NETBOX_CONFIG"                                             >> /config/configuration-merged.py
fi

_info "Starting redis.."
supervisorctl start redis > /dev/null
while ! redis-cli ping &> /dev/null; do
	_info "Waiting until Redis is ready.."
	sleep 1
done
_info "Redis is ready.."

_info "Starting PostgreSQL.."
supervisorctl start postgresql > /dev/null
while ! pg_isready -q; do
	_info "Waiting until PostgreSQL is ready.."
	sleep 1
done
_info "PostgreSQL is ready.."

MANAGE_PY="python3 /opt/netbox/netbox/manage.py"

# run migration when needed
_info "Check if migration is needed.."
if ! $MANAGE_PY migrate --check &>/dev/null; then
	netbox-upgrade.sh
else
	# Run collectstatic, regardless of whether the database needs migration (https://github.com/casperklein/homeassistant-addons/issues/28)
	$MANAGE_PY collectstatic --no-input
fi

# add netbox superuser
if [ -n "$USER" ] && [ -n "$PASS" ]; then
	_info "Creating new netbox superuser: $USER"
	# Create user + API token: https://github.com/netbox-community/netbox-docker/blob/f1ca9ab7ebc16b288fd9da8825176c75d6b7ea4f/docker/docker-entrypoint.sh#L74-L80
	if ! RESULT=$($MANAGE_PY shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('$USER', '${MAIL:-}','$PASS')" 2>&1); then
		if grep -qP 'Key \(username\)=.+ already exists' <<<"$RESULT"; then
			_error "Failed to create superuser '$USER', because the user already exists. Remove 'user' and 'password' from the add-on options."
		else
			_error "$RESULT"
			_error "Failed to create superuser '$USER'. See error details above."
		fi
		_info " The add-on will continue startup in 1 minute."
		sleep 1m
		# exit 1
	fi >&2
fi

# enable HTTPS
if [ "$HTTPS" = true ]; then
	_info "Enabling HTTPS.."
	[ ! -f "/ssl/$CERT" ] && _error "Certificate '$CERT' not found." >&2 && exit 1
	[ ! -f "/ssl/$KEY" ] && _error "Certificate key '$KEY' not found." >&2 && exit 1

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
		_error "Failed to start stunnel SSL encryption wrapper."
		exit 1
	} >&2
	PORT=443
else
	PORT=80
fi

# Housekeeping
_info "Starting housekeeping background job.."
supervisorctl start housekeeping > /dev/null

# https://docs.netbox.dev/en/stable/plugins/development/background-tasks/
_info "Starting RQ worker process.."
supervisorctl start rqworker > /dev/null

_info "Starting netbox.."
# exec gunicorn --bind 127.0.0.1:$PORT --pid /var/tmp/netbox.pid --pythonpath /opt/netbox/netbox --config /opt/netbox/gunicorn.py netbox.wsgi

[ "$DEBUG" = true ] && _debug "Startup took $SECONDS seconds."

$MANAGE_PY runserver 0.0.0.0:$PORT --insecure &
NETBOX_PID=$!
wait
