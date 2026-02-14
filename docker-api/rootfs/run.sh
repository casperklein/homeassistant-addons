#!/bin/bash

if [ ! -S /var/run/docker.sock ]; then
	echo "Error: Protection mode is enabled!"
	echo "----------------------------------"
	echo "To be able to use this app, you'll need to disable protection mode on this app."
	echo "Without it, the app is unable to access Docker."
	exit 1
fi >&2

while :; do
	socat -d -d TCP-LISTEN:2375,fork UNIX-CONNECT:/var/run/docker.sock
done
