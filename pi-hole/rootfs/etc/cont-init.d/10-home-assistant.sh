#!/bin/bash

set -ueo pipefail

date '+[%F %T] *** Customize for Home Assistant..'

# Make Pi-hole configuration persistent
# https://discourse.pi-hole.net/t/what-files-does-pi-hole-use/1684
if [ -d /data/pihole ]; then
	date '+[%F %T] ***** Existing configuration detected..'
	rm -rf /etc/pihole /etc/dnsmasq.d /var/log
else
	date '+[%F %T] ***** First run. Copy initial configuration..'
	mv /etc/pihole 		/data/pihole
	mv /etc/dnsmasq.d 	/data/dnsmasq.d
	mv /var/log		/data/log
fi

date '+[%F %T] ***** Create config symlinks..'
ln -s /data/pihole /etc/pihole
ln -s /data/dnsmasq.d /etc/dnsmasq.d
ln -s /data/log /var/log

# Fix permissions; Sometimes they got lost after a HA backup restore
date '+[%F %T] ***** Fix permissions..'
while IFS=';' read -r FILE MODE OWNER; do
	chmod "$MODE" "$FILE" 2>/dev/null
	chown "$OWNER" "$FILE" 2>/dev/null
done < /etc/permissions || true
