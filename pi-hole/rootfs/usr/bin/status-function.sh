#!/bin/bash

_status() {
	local output
	local blue=$'\e[0;34m'
	local reset=$'\e[0m'

	printf -v output -- '%s'                     "$blue"  # Blue font color
	printf -v output -- '%s%(%F %T)T ' "$output"    -1    # Current date/time
	printf -v output -- '%s%s'         "$output"   "$1"   # Status message
	printf -v output -- '%s%s\n'       "$output" "$reset" # Reset color

	printf -- '%s' "$output"
}
