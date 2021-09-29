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

#echo "***** Fix permissions.."
#chown -R www-data: /data/log/lighttpd
