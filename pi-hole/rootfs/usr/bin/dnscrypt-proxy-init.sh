#!/bin/bash

set -ueo pipefail

ADDON_OPTIONS="/data/options.json"
DNSCRYPT_CONFIG="/etc/dnscrypt-proxy.toml"
PH_CONFIG="/etc/pihole/pihole.toml"

_status() {
	local BLUE=$'\e[0;34m'
	local RESET=$'\e[0m'

	printf -- '%s' "$BLUE"    # Use blue font color
	printf -- '%(%F %T)T ' -1 # Print current date/time
	printf -- '%s' "$1"       # Print status message
	printf -- '%s\n' "$RESET" # Reset color
}

# Get all upstream DNS servers
DNS=()
while read -r UPSTREAMS; do
	DNS+=("$UPSTREAMS")
done < <(yq -r '.dns.upstreams[]' "$PH_CONFIG")

# Check if DNSCrypt-Proxy is configured in Pi-hole
CONFIGURED_IN_PH=0
for i in "${DNS[@]}"; do
	if [ "$i" == "127.0.0.1#5353" ]; then
		CONFIGURED_IN_PH=1
	fi
done

# Check if there are dnscrypt settings
# if ! grep -qF '"dnscrypt": []' "$ADDON_OPTIONS"; then
if (( $(jq '.dnscrypt | length' "$ADDON_OPTIONS") > 0 )); then
	# Append configuration only on first run
	if ! grep -qF 'server_names' "$DNSCRYPT_CONFIG"; then
		# _status "Creating DNSCrypt-Proxy configuration"

		# Read settings
		while read -r SERVER; do
			# {"name":"cloud1","stamp":"sdns://AgcAAAAAAAAABzEuMS4xLjEAEmNsb3VkZmxhcmUtZG5zLmNvbQovZG5zLXF1ZXJ5"}
			NAME+=("$(echo "$SERVER" | base64 -d | cut -d'"' -f4)")
			STAMP+=("$(echo "$SERVER" | base64 -d | cut -d'"' -f8)")
		done < <(jq -r '.dnscrypt[] | @base64' "$ADDON_OPTIONS")

		# Create DNSCrypt-Proxy configuration
		{
			FIRST_SERVER=1
			echo -n 'server_names = ['
			for i in "${NAME[@]}"; do
				if (( FIRST_SERVER == 1 )) then
					echo -n "'$i'"
					FIRST_SERVER=0
				else
					echo -n ",'$i'"
				fi
			done
			echo ']'
			echo "[static]"
		} >> "$DNSCRYPT_CONFIG"

		for i in "${!NAME[@]}"; do
			echo "[static.'${NAME[i]}']"
			echo "stamp = '${STAMP[i]}'"
		done >> "$DNSCRYPT_CONFIG"
	fi

	if (( CONFIGURED_IN_PH == 0 )); then
		_status "WARNING: Custom DNS server 127.0.0.1#5353 is not configured. DNSCrypt/DoH name resolution will not work until this is resolved."
	fi

	# Check if custom DNS server is properly configured
	if (( ${#DNS[@]} > 1 )); then
		if (( CONFIGURED_IN_PH == 1 )); then
			_status "WARNING: More than one DNS upstream server is configured in Pi-hole. Not all DNS queries will be handled by DNSCrypt-Proxy."
		fi
	fi

	exec dnscrypt-proxy -config "$DNSCRYPT_CONFIG"
else
	_status "INFO: No DNSCrypt/DoH settings found in the add-on configuration"
	_status "INFO: DNSCrypt-Proxy is not being started"

	# Check if custom DNS server is configured
	if (( CONFIGURED_IN_PH == 1 )); then
		_status "WARNING: DNSCrypt-Proxy (127.0.0.1#5353) is configured as a custom DNS upstream server. DNS resolution will not work until DNSCrypt-Proxy is set up in the add-on configuration."
	fi

	exit 0 # Graceful exit, to not trigger a restart by supervisor.sh
fi
