#!/bin/bash

SLEEP="1d"

while :; do
	sleep "$SLEEP"
	# printf '%s %s\n' "$(date '+[%F %T %z]')" "Housekeeping.." # gunicorn style
	printf '%s %s\n' "$(date '+[%d/%h/%G %T]')" "Housekeeping.."
	python3 /opt/netbox/netbox/manage.py housekeeping
done
