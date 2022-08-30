#!/bin/bash

# Fix s6 dependencies: wait for cont-init.d to finish, before starting services s6-rc.d
# This adds "base" as dependency for all services
# https://github.com/just-containers/s6-overlay/issues/471

set -ueo pipefail

cd /etc/s6-overlay/s6-rc.d
for i in */; do
	FILE="$i/dependencies"
	if [ -f "$FILE" ]; then
		# pihole hack. add missing line ending
		sed -i -e '$a\' "$FILE"
	fi
	echo base >> "$FILE"
done
