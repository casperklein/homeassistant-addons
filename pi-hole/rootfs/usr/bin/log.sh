#!/bin/bash

# shellcheck source=status-function.sh
source /usr/bin/status-function.sh

# Write to PID 1 STDOUT (docker log)
_status "$*" > /proc/1/fd/1
sleep 1
