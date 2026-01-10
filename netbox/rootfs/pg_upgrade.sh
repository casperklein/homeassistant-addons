#!/bin/bash

_info "PostgreSQL 15 database found. Starting migration to version 17.."

_info "Install PostgreSQL 15.."
	cat >> /etc/apt/sources.list.d/debian.sources <<-"EOF"
		Types: deb
		URIs: http://deb.debian.org/debian
		Suites: bookworm bookworm-updates
		Components: main
		Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

		Types: deb
		URIs: http://deb.debian.org/debian-security
		Suites: bookworm-security
		Components: main
		Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
	EOF
	export DEBIAN_FRONTEND=noninteractive
	apt-get -qq update
	apt-get -qq install --no-install-recommends postgresql-15 &> /dev/null
	# pg_lsclusters
	pg_createcluster 15 main > /dev/null # This creates /etc/postgresql/15/*

_info "Configure PostgreSQL 15.."
	sedfile -i "s|^data_directory =.*|data_directory = '/data/postgresql/15/main'|g" /etc/postgresql/15/main/postgresql.conf
	# When a second PosgreSQL instance is installed, the port is incremented --> 5433
	sedfile -i 's|^port = 5433.*|port = 5432|g'                                      /etc/postgresql/15/main/postgresql.conf

_info "Export netbox database from old PostgreSQL cluster.."
	pg_ctlcluster 15 main start
	# shellcheck disable=SC2024
	sudo -u postgres pg_dump netbox > /data/postgresql15_netbox.sql
	pg_ctlcluster 15 main stop

_info "Remove PostgreSQL 15.."
	apt-get -qq remove postgresql-15 &> /dev/null
	#apt-get -qq purge postgresql-13 # Remove PostgreSQL directories when package is purged? [yes/no] --> I don't know how to automatically answer this

_info "Import netbox database to new PostgreSQL cluster.."
	pg_ctlcluster 17 main start
	sudo -u postgres psql -c 'drop database netbox' > /dev/null
	sudo -u postgres psql -c 'create database netbox' > /dev/null
	# shellcheck disable=SC2024
	sudo -u postgres psql netbox < /data/postgresql15_netbox.sql > /dev/null
	pg_ctlcluster 17 main stop

_info "Database migration successful."

_info "Removing old PostgreSQL 15 database and data export.."
	rm -rf /data/postgresql/15
	rm /data/postgresql15_netbox.sql

_info "Cleanup done."
