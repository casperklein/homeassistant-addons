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
	# Makes testing outside of HA easier
	# mkdir -p /data
	# touch /data/options.json

	_status "The add-on is running for the first time"
	_status "Migrating the Pi-hole configuration to persistent storage"
	mv /etc/pihole /data/pihole

	_status "Adjusting the default settings"
	cp /etc/pihole-custom-defaults/pihole.toml /data/pihole
fi
ln -s /data/pihole /etc/pihole

# Not necessary; Pi-hole takes care of this --> https://github.com/pi-hole/pi-hole/blob/master/advanced/Templates/pihole-FTL-prestart.sh
# _status "Set permissions"
# chown -R pihole:pihole /data/pihole
# chown    root:root     /data/pihole/logrotate

_delete_obsolete_files

# Get 'update_gravity_on_start' add-on setting
UPDATE_GRAVITY_ON_START=$(jq --raw-output '.update_gravity_on_start' /data/options.json)
if [ "$UPDATE_GRAVITY_ON_START" == "true" ]; then
	# Run gravity update on Pi-hole start
	patch -i /etc/pihole-patches/update-gravity-on-start.patch /usr/bin/bash_functions.sh >/dev/null
fi

_status "Starting Pi-hole"
supervisor.sh start "Pi-hole" >/dev/null
