#!/bin/bash

_status() {
	local BLUE=$'\e[0;34m'
	local RESET=$'\e[0m'

	printf -- '%s' "$BLUE"    # Use blue font color
	printf -- '%(%F %T)T ' -1 # Print current date/time
	printf -- '%s' "$1"       # Print status message
	printf -- '%s\n' "$RESET" # Reset color
}

_status "$*" >> /tmp/notify
