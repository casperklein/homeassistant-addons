#!/bin/bash

# shellcheck source=status-function.sh
source /usr/bin/status-function.sh

# Output to docker log
_status "$*" > /proc/1/fd/1
sleep 1
