#!/bin/bash

set -ueo pipefail

echo "*** Customize for Home Assistant.."

# Avoid error message, that 127.0.0.1 and an additional DNS server have to be set in resolv.conf
#echo "***** Set container DNS servers"
#sed '/^nameserver/d' /etc/resolv.conf	 > /etc/resolv.conf # -i does not work, resolv.conf is mounted
#echo "nameserver 127.0.0.1"		>> /etc/resolv.conf
#echo "nameserver 127.0.0.1"		>> /etc/resolv.conf

# Make Pi-hole configuration persistent
# https://discourse.pi-hole.net/t/what-files-does-pi-hole-use/1684
if [ -d /data/pihole ]; then
	echo "***** Existing configuration detected.."
	rm -rf /etc/pihole /etc/dnsmasq.d /var/log
else
	echo "***** First run. Copy initial configuration.."
	mv /etc/pihole 		/data/pihole
	mv /etc/dnsmasq.d 	/data/dnsmasq.d
	mv /var/log		/data/log
fi

echo "***** Create config symlinks.."
ln -s /data/pihole /etc/pihole
ln -s /data/dnsmasq.d /etc/dnsmasq.d
ln -s /data/log /var/log

echo "***** Fix permissions.."
chown -R www-data: /var/log/lighttpd
