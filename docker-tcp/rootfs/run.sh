#!/bin/bash

if [ ! -S /var/run/docker.sock ]; then
	echo "Error: Protection mode is enabled!"
	echo "----------------------------------"
	echo "To be able to use this add-on, you'll need to disable protection mode on this add-on."
	echo "Without it, the add-on is unable to access Docker."
	exit 1
fi

while :; do
	socat -d -d TCP-LISTEN:2375 UNIX-CONNECT:/var/run/docker.sock
done
