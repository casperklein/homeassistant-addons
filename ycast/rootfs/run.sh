#!/bin/sh

BOOKMARKS=$(jq --raw-output '.bookmarks | .[]' /data/options.json 2> /dev/null | sed 's/^/  /')

if [ -n "$BOOKMARKS" ]; then
	echo "Bookmarks:"  > stations.yml
	echo "$BOOKMARKS" >> stations.yml
fi

cat stations.yml
echo " "

export FLASK_ENV=production # obsolet? https://stackoverflow.com/a/52162979/568737
export FLASK_DEBUG=0
exec /usr/bin/python3 -m ycast -d
