#!/bin/sh

BOOKMARKS=$(jq --raw-output '.bookmarks | .[]' /data/options.json | sed 's/^/  /')

if [ -n "$BOOKMARKS" ]; then
	echo "Bookmarks:"  > stations.yml
	echo "$BOOKMARKS" >> stations.yml
fi

cat stations.yml
echo " "

export FLASK_ENV=development
export FLASK_DEBUG=0
exec /usr/bin/python3 -m ycast -d
