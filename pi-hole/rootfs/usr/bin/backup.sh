#!/bin/bash

case "$1" in
	pre)
		# https://github.com/casperklein/homeassistant-addons/issues/43
		killall -q crond

		notify.sh "Home Assistant is creating a backup. Stopping Pi-hole to ensure database consistency."
		sleep 0.5
		supervisor.sh stop "Pi-hole"
		;;

	post)
		notify.sh "Home Assistant has finished creating the backup. Starting Pi-hole to resume normal operation."
		sleep 0.5
		supervisor.sh start "Pi-hole"
		;;

	*)
		echo "Error: Unknown command '$*'"
		echo "Usage: backup.sh <pre|post>"
		echo
		exit 1
		;;
esac
