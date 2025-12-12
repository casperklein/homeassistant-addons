#!/bin/bash

case "$1" in
	pre)
		# https://github.com/casperklein/homeassistant-addons/issues/43
		killall -q crond

		log.sh "Home Assistant is creating a backup. Stopping Pi-hole to ensure database consistency."
		supervisor.sh stop "Pi-hole"
		;;

	post)
		log.sh "Home Assistant has finished creating the backup. Starting Pi-hole to resume normal operation."
		supervisor.sh start "Pi-hole"
		;;

	*)
		echo "Error: Unknown command '$*'"
		echo "Usage: backup.sh <pre|post>"
		echo
		exit 1
		;;
esac
