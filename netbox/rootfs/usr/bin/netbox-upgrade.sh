#!/bin/bash

# https://github.com/netbox-community/netbox/blob/develop/upgrade.sh

set -ueo pipefail
shopt -s inherit_errexit

MANAGE_PY="python3 /opt/netbox/netbox/manage.py"

_info() {
	local GREEN=$'\e[0;32m'
	local RESET=$'\e[0m'
	echo "${GREEN}Info: $1$RESET"
}

_info "Applying database migrations.."
$MANAGE_PY migrate

_info "Collecting static files.."
$MANAGE_PY collectstatic --no-input

# Your models in app(s): 'netbox_bgp' have changes that are not yet reflected in a migration, and so won't be applied.
# Run 'manage.py makemigrations' to make new migrations, and then re-run 'manage.py migrate' to apply them.
#? This command is available for development purposes only! It will NOT resolve any issues with missing or unapplied migrations.
# $MANAGE_PY makemigrations && $MANAGE_PY migrate

# Trace any missing cable paths (not typically needed)
_info "Running trace_paths.."
$MANAGE_PY trace_paths --no-input

# TODO Needs reverse proxy for auto-indexing: http://netboxhost/static/docs/ --> http://netboxhost/static/docs/index.html
# TODO https://github.com/netbox-community/netbox/discussions/13165
# Build the local documentation
# mkdocs build

# Delete any stale content types
_info "Removing stale content types.."
$MANAGE_PY remove_stale_contenttypes --no-input

# Rebuild the search cache (lazily)
_info "Building search index (lazy).."
$MANAGE_PY reindex --lazy

#? done by housekeeping-job.sh
# Delete any expired user sessions
# _info "Removing expired user sessions.."
# $MANAGE_PY clearsessions
