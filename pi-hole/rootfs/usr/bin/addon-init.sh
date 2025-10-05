#!/bin/bash

set -ueo pipefail

_status() {
	local BLUE=$'\e[0;34m'
	local RESET=$'\e[0m'

	printf -- '%s' "$BLUE"    # Use blue font color
	printf -- '%(%F %T)T ' -1 # Print current date/time
	printf -- '%s' "$1"       # Print status message
	printf -- '%s\n' "$RESET" # Reset color
}

# TODO Remove in future version
_migrate_dnsmasq_v6() {
	shopt -s nullglob
	if [ -d /data/dnsmasq.d ]; then
		DNSMASQ=$(printf -- '%s' /data/dnsmasq.d/*)
		if [ -z "$DNSMASQ" ]; then
			# Directory is empty, nothing to migrate, delete it
			_status "The Dnsmasq migration was successful"
			rm -rf /data/dnsmasq.d
		else
			_status "Custom Dnsmasq config files have not been migrated to Pi-hole v6 yet"
			# Custom dnsmasq config files that you want to persist. Not needed for most starting fresh with Pi-hole v6.
			# If you're upgrading from v5 you and have used this directory before,
			# you should keep it enabled for the first v6 container start to allow for a complete migration.
			# It can be removed afterwards.
			rm -rf /etc/dnsmasq.d
			ln -s /data/dnsmasq.d /etc/dnsmasq.d
		fi
	fi
}

# TODO Remove in future version
_delete_obsolete_files() {
	# Remove pre v6 saved log directory; Reduce backup size
	rm -rf /data/log

	# Remove old migration backup (2020); V6 migration backup is stored in /data/pihole/migration_backup_v6
	rm -rf /data/pihole/migration_backup
}

# Make Pi-hole configuration persistent
if [ -d /data/pihole ]; then
	_status "Existing Pi-hole configuration detected"
	rm -rf /etc/pihole

	_migrate_dnsmasq_v6
else
	_status "The add-on is running for the first time"
	_status "Migrating the Pi-hole configuration to persistent storage"
	mv /etc/pihole /data/pihole

	_status "Customize initial default settings:"
	_status "  - dns.listeningMode:     all" # Pi-hole uses eth0 by default. If the interface name differs (e.g. end0), DNS resolution will not work (out-of-the-box).
	_status "  - dns.cache.optimizer: -3600" # Respect the TTL and do not return any outdated DNS data.
	_status "  - ntp.ipv4.active:     false" # No need to activate NTP, while DHCP is disabled.
	_status "  - ntp.ipv6.active:     false" # No need to activate NTP, while DHCP is disabled.
	_status "  - ntp.sync.active:     false" # HAOS already syncs the time, see /etc/systemd/timesyncd.conf.
	cp /etc/pihole-custom-defaults/pihole.toml /data/pihole
fi
ln -s /data/pihole /etc/pihole

# Not necessary; Pi-hole takes care of this --> https://github.com/pi-hole/pi-hole/blob/master/advanced/Templates/pihole-FTL-prestart.sh
# _status "Set permissions"
# chown -R pihole:pihole /data/pihole
# chown    root:root     /data/pihole/logrotate

_delete_obsolete_files

OPTIONS="/data/options.json"

# Get 'update_gravity_on_start' add-on setting
UPDATE_GRAVITY_ON_START=$(jq -r '.update_gravity_on_start' "$OPTIONS")
if [ "$UPDATE_GRAVITY_ON_START" == "true" ]; then
	# Run gravity update on Pi-hole start
	patch -i /etc/pihole-patches/update-gravity-on-start.patch /usr/bin/bash_functions.sh >/dev/null
fi

# SLUG="0da538cf_pihole"
SLUG="self"

_status "Configure Ingress IP and port"
# "hassio_api": "true" is not needed in the addon config.json for these queries --> https://developers.home-assistant.io/docs/add-ons/communication#supervisor-api
IP=$(           curl -sSLf -H "Authorization: Bearer $SUPERVISOR_TOKEN" "http://supervisor/addons/$SLUG/info" | jq -r .data.ip_address)
INGRESS_PORT=$( curl -sSLf -H "Authorization: Bearer $SUPERVISOR_TOKEN" "http://supervisor/addons/$SLUG/info" | jq -r .data.ingress_port)
HTTP_PORT=$(    curl -sSLf -H "Authorization: Bearer $SUPERVISOR_TOKEN" "http://supervisor/addons/$SLUG/info" | jq -r '.data.network | ."80/tcp" // empty')
HTTPS_PORT=$(   curl -sSLf -H "Authorization: Bearer $SUPERVISOR_TOKEN" "http://supervisor/addons/$SLUG/info" | jq -r '.data.network | ."443/tcp" // empty')

# Configure ingress IP and port
sedfile -i "s|%INTERFACE%|$IP|"      /etc/nginx/http.d/ingress.conf
sedfile -i "s|%PORT%|$INGRESS_PORT|" /etc/nginx/http.d/ingress.conf

DIRECT_CONF=/etc/nginx/http.d/direct.conf

# Enable HTTP/HTTPS access
if [[ -n "$HTTP_PORT" || -n "$HTTPS_PORT" ]]; then
	# Activate configuration
	mv "$DIRECT_CONF".disabled "$DIRECT_CONF"

	# If HTTP port is configured, enable access
	if [ -n "$HTTP_PORT" ]; then
		_status "Enabling HTTP access on port $HTTP_PORT"
		sedfile -i "s|%HTTP_PORT%|$HTTP_PORT|" "$DIRECT_CONF"
	else
		sedfile -i "/%HTTP_PORT%/d" "$DIRECT_CONF"
	fi

	# If HTTPS port is configured, enable access
	if [ -n "$HTTPS_PORT" ]; then
		_status "Enabling HTTPS access on port $HTTPS_PORT"

		sedfile -i "s|%HTTPS_PORT%|$HTTPS_PORT|" "$DIRECT_CONF"
		sedfile -i 's|%HTTP2%|http2 on;|'      "$DIRECT_CONF"

		# Get certificate paths
		CERTIFICATE=/ssl/$(    jq -r '.certificate'     "$OPTIONS")
		CERTIFICATE_KEY=/ssl/$(jq -r '.certificate_key' "$OPTIONS")

		# Fallback to self-signed certificate, if files do not exist
		if [[ ! -f $CERTIFICATE || ! -f $CERTIFICATE_KEY ]]; then
			_status "Certificate files ($CERTIFICATE, $CERTIFICATE_KEY) not found"

			CERTIFICATE=/etc/pihole/tls.pem
			CERTIFICATE_KEY=/etc/pihole/tls.key

			# Generate certificate if necessary
			if [ ! -f "$CERTIFICATE" ]; then
				_status "Generating self-signed certificate"
				pihole-FTL --gen-x509 "$CERTIFICATE"
			else
				_status "Using self-signed certificate"
			fi

			# Versions before 2025.07.02 did not create $CERTIFICATE_KEY
			if [ ! -f "$CERTIFICATE_KEY" ]; then
				# Extract private key
				sed -n '/-----BEGIN .*PRIVATE KEY-----/,/-----END .*PRIVATE KEY-----/p' "$CERTIFICATE" > "$CERTIFICATE_KEY"
			fi
		fi

		# Configure certificate
		sedfile -i "s|%CERTIFICATE%|$CERTIFICATE|"         "/etc/nginx/includes/ssl.conf"
		sedfile -i "s|%CERTIFICATE_KEY%|$CERTIFICATE_KEY|" "/etc/nginx/includes/ssl.conf"
	else
		# Disable HTTPS
		sedfile -i "/%HTTPS_PORT%/d"             "$DIRECT_CONF"
		sedfile -i "/%HTTP2%/d"                  "$DIRECT_CONF"
		sedfile -i -E '/^\s*include.+ssl.conf/d' "$DIRECT_CONF"
	fi

	# Get 'authentication' add-on setting
	AUTHENTICATION=$(jq -r '.authentication' "$OPTIONS")

	# Enable/disable authentication based on configuration
	if [ "$AUTHENTICATION" == "false" ]; then
		# Remove authentication config
		sedfile -i -E '/^\s*include.+auth-request.conf/d'  "$DIRECT_CONF"
		sedfile -i -E '/^\s*include.+auth-location.conf/d' "$DIRECT_CONF"
	else
		_status "Enabling authentication"
	fi
fi

# Start Notification
supervisor.sh start "Notification" >/dev/null

# Start Nginx
supervisor.sh start "Nginx" >/dev/null

# Start DNSCrypt-Proxy
supervisor.sh start "DNSCrypt-Proxy" >/dev/null
sleep 3 # Give DNSCrypt-Proxy some time to start

# Start Pi-hole
_status "Starting Pi-hole"
supervisor.sh start "Pi-hole" >/dev/null
