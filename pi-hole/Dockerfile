# check=skip=SecretsUsedInArgOrEnv
FROM	pihole/pihole:2026.10.0 AS pihole

ARG	YQ_VERSION=v4.54.1
ARG	SV_VERSION=0.18
ARG	TARGETARCH

SHELL	["/bin/bash", "-e", "-o", "pipefail", "-c"]

# Ensure that build args are given
ARG	BUILD_ARCH
ARG	VERSION
RUN	[ -z "$BUILD_ARCH" ] && echo "Error: Build argument 'BUILD_ARCH' is missing" && exit 1 || true
RUN	[ -z "$VERSION" ] && echo "Error: Build argument 'VERSION' is missing" && exit 1 || true

# Check if default CSP value was updated
RUN <<EOF
	# Create /etc/pihole/versions file and extract FTL version
	chmod o+w /etc/pihole
	FTL_VERSION=$(pihole version | grep  "^FTL version is" | awk '{print $4}')

	# Get FTL config.c file
	FTL_CONFIG=$(curl -sSLf https://raw.githubusercontent.com/pi-hole/FTL/refs/tags/$FTL_VERSION/src/config/config.c)

	CSP_CHECKSUM=$(grep 'cJSON_CreateStringReference("Content-Security-Policy:' <<<"$FTL_CONFIG" | sha256sum)
	if [ "$CSP_CHECKSUM" != "1f981ee8f2a91fcf659a646264937ce7c36ad2f113687de8a905b6d013d1af88  -" ]; then
		echo "Warning: The CSP default value was updated."
		echo
		echo "Verify changes at: https://github.com/pi-hole/FTL/blob/$FTL_VERSION/src/config/config.c"
		echo "Update 'add_header Content-Security-Policy' in rootfs/etc/nginx/http.d/ingress.conf"
		echo
		echo "New Checksum: $CSP_CHECKSUM"
		exit 1
	fi
EOF

# Update base image packages and install additional software
RUN <<EOF
	apk upgrade --no-cache
	apk add     --no-cache dumb-init nginx nginx-mod-http-lua patch
EOF

# Copy root filesystem
COPY	rootfs /

# Install yq (needed for supervisor.sh and rootfs/usr/bin/dnscrypt-proxy-init.sh)
RUN <<EOF
	curl -sSLf -o /usr/bin/yq "https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_$TARGETARCH"
	chmod +x /usr/bin/yq

	# Test binary
	yq --version
EOF

# Install supervisor.sh
RUN <<EOF
	curl -sSLf -o /usr/bin/supervisor.sh               "https://raw.githubusercontent.com/casperklein/supervisor.sh/refs/tags/$SV_VERSION/supervisor.sh"
	curl -sSLf -o /etc/bash_completion.d/supervisor.sh "https://raw.githubusercontent.com/casperklein/supervisor.sh/refs/tags/$SV_VERSION/supervisor-completion.bash"
	chmod +x /usr/bin/supervisor.sh

	# Validate configuration
	supervisor.sh lint > /dev/null
EOF

# Disable Pi-hole's update check
# This prevents:
#   - "Update available" messages in the UI
#   - Home Assistant Pi-hole integrations to report updates (which cannot be installed)
RUN <<EOF
	# The CSP check at the top runs "pihole version" (/opt/pihole/updatecheck.sh) which creates /etc/pihole/versions
	VERSIONS_FILE=/etc/pihole/versions

	COUNT=$(grep -c ^GITHUB_ "$VERSIONS_FILE" || true)
	if (( COUNT != 7 )); then
		echo "Error: 7 matching '^GITHUB_' lines are expected."
		exit 1
	fi

	# Align GITHUB_* values with local values.
	for name in $(grep ^GITHUB_ "$VERSIONS_FILE" | cut -d= -f1); do
		name=${name:7}
		value=$(       grep        "^$name=" "$VERSIONS_FILE" | cut -d= -f2)
		github_value=$(grep "^GITHUB_$name=" "$VERSIONS_FILE" | cut -d= -f2)

		if [ "$value" != "$github_value" ]; then
			sedfile -i "s/^GITHUB_$name=.*/GITHUB_$name=$value/" "$VERSIONS_FILE"
		fi
	done

	# Disable update check
	sedfile -i 's/.*pihole updatechecker/#& # Disabled by Pi-hole for Home Assistant app/' /crontab.txt
	sedfile -i                   '1a exit 0 # Disabled by Pi-hole for Home Assistant app'  /opt/pihole/updatecheck.sh
	sedfile -i                   '1a exit 0 # Disabled by Pi-hole for Home Assistant app'  /etc/.pihole/advanced/Scripts/updatecheck.sh
EOF

# Check if /etc/pihole directory structure is as expected
RUN <<EOF
	# Does not work with busybox: find . -printf '%y %p\n'
	_get_directory_structure() {
		{
			find "$1" -type d | sed 's/^/d /'
			find "$1" -type f | sed 's/^/f /'
			find "$1" -type l | sed 's/^/l /'
		} | LC_ALL=C sort
	}
	if ! diff /etc/pihole-directory-structure <(_get_directory_structure /etc/pihole); then
		echo
		echo "Expected directory structure:"
		echo
		echo "/etc/pihole"
		echo "└── versions"
		echo
		echo "Actual directory structure:"
		echo
		tree /etc/pihole
		echo
		echo "Update app-init.sh to move new files/directories to persistent storage: /data/pihole"
		exit 1
	fi
EOF

# Remove docker-pi-hole update instructions
# RUN	sedfile -i 's|To install updates, <a href="https://github.com/pi-hole/docker-pi-hole#upgrading-persistence-and-customizations" rel="noopener noreferrer" target="_blank">replace this old container with a fresh upgraded image</a>.||' /var/www/html/admin/scripts/js/footer.js

# Adjust wording slightly. Pi-hole may be stopped (during HA backup), but the app keeps running.
RUN	sedfile -i    's|echo "  \[i\] Container stop requested..."|echo "  [i] Pi-hole stop requested..."|' /usr/bin/start.sh

# Hide Docker instructions that are not applicable for this app
RUN	sedfile -i    's|echo "  \[i\] Container will now stop or restart depending on your restart policy"|#&|' /usr/bin/start.sh
RUN	sedfile -i -E 's|echo "\s+https://docs.docker.com/engine/containers/start-containers-automatically/|#&|' /usr/bin/start.sh

# Display real FTL exit code. 'start.sh' sometimes returns 143 (SIGTERM) or 1 despite FTL exits gracefully (0)
RUN	sedfile -i 's,echo "  \[i\] pihole-FTL exited with status.*,echo -n "  [i] pihole-"; tac \$FTLlogFile | grep -o -m 1 "FTL terminated after.*!",' /usr/bin/start.sh

# Hide uncritical error message --> wait: pid 123 is not a child of this shell
# There is a race condition, when supervisor is faster sending SIGTERM to FTL than start.sh
# start.sh:stop()
RUN	sedfile -i 's|        wait $CAPSH_PID|& 2>/dev/null|' /usr/bin/start.sh

# Remove obsolete files
RUN	rm /etc/nginx/http.d/default.conf

# Build dnscrypt-proxy from source #################################################################
FROM	golang:trixie AS dnscrypt

ARG	DNSCRYPT_VERSION="2.1.20"
ENV	URL="https://github.com/dnscrypt/dnscrypt-proxy/archive/$DNSCRYPT_VERSION.tar.gz"

ENV	DEBIAN_FRONTEND="noninteractive"
RUN	apt-get update && apt-get -y upgrade

WORKDIR	/build
RUN	curl -sSLf "$URL" | tar --strip-component 1 -xz
WORKDIR	/build/dnscrypt-proxy

# Compile with static linking (including all library code in the binary); needed for alpine image
# Otherwise --> /dnscrypt-proxy: cannot execute: required file not found
ENV	CGO_ENABLED=0

# Builds a Go binary without symbol tables and debugging information, reducing the file size.
RUN	go build -trimpath -ldflags="-s -w" -mod vendor

# Test binary
RUN	./dnscrypt-proxy -version

# Build final image ################################################################################
FROM	scratch

ARG	BUILD_ARCH
ARG	VERSION

LABEL	io.hass.name="Pi-hole"
LABEL	io.hass.description="Network-wide Ad Blocking"
LABEL	io.hass.arch="${BUILD_ARCH}"
LABEL	io.hass.type="app"
LABEL	io.hass.version="${VERSION}"

LABEL	image="casperklein/homeassistant-pi-hole:${VERSION}"
LABEL	maintainer="Casper Klein"
LABEL	url="https://github.com/casperklein/homeassistant-addons/tree/master/pi-hole"

# Disable Pi-hole authentication --> Single Sign On via HA Ingress
ENV	FTLCONF_webserver_api_password=""

# Placeholder for HA Ingress token (required for substitution, see rootfs/etc/nginx/http.d/ingress.conf)
ENV	FTLCONF_webserver_paths_prefix="/live-long-and-prosper"

# Let Pi-hole web server listen on port 3.1415
ENV	FTLCONF_webserver_port="127.0.0.1:31415"

COPY	--from=dnscrypt /build/dnscrypt-proxy/dnscrypt-proxy /usr/bin/
COPY	--from=pihole / /

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD	[ "/usr/bin/supervisor.sh", "--config", "/etc/supervisor.yaml" ]

# From base image
# docker-image-options pihole/pihole:latest | sort | grep -v LABEL

# ENTRYPOINT ["start.sh"]
ENV DNSMASQ_USER="pihole"
ENV FTL_CMD="no-daemon"
EXPOSE 123/udp
EXPOSE 443/tcp
EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 67/udp
EXPOSE 80/tcp
# Healthcheck is disabled, to avoid waiting 30s (until container is healthy) to access Pi-hole via HA Ingress
# HEALTHCHECK CMD dig -p $(pihole-FTL --config dns.port) +short +norecurse +retry=0 @127.0.0.1 pi.hole || exit 1
WORKDIR /
