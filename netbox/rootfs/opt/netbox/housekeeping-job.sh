#!/bin/bash

housekeeping() {
	# printf '%s %s\n' "$(date '+[%F %T %z]')" "Housekeeping.." # gunicorn style
	printf '%s %s\n' "$(date '+[%d/%h/%G %T]')" "Housekeeping.."
	python3 /opt/netbox/netbox/manage.py housekeeping
}

sleep 5m
housekeeping

while :; do
	sleep 1d
	housekeeping
done
