#!/bin/bash

_info "PostgreSQL 13 database found. Starting migration to version 15.."
cat >> /etc/apt/sources.list <<-"EOF"
	deb http://deb.debian.org/debian/ bullseye main
	deb http://security.debian.org/debian-security bullseye-security main
	deb http://deb.debian.org/debian/ bullseye-updates main
EOF

_info "Install PostgreSQL 13.."
apt-get -qq update
apt-get -qq install --no-install-recommends postgresql-13 &> /dev/null

_info "Configure PostgreSQL 13.."
sedfile -i "s|^data_directory.*|data_directory = '/data/postgresql/13/main'|" /etc/postgresql/13/main/postgresql.conf
sedfile -i 's|^port = 5433|port = 5432|g' /etc/postgresql/13/main/postgresql.conf # when a second PosgreSQL instance is installed, the port is incremented --> 5433

_info "Export netbox database from old PostgreSQL cluster.."
pg_ctlcluster 13 main start
# shellcheck disable=SC2024
sudo -u postgres pg_dump netbox > /data/postgresql13_netbox.sql
pg_ctlcluster 13 main stop

_info "Remove PostgreSQL 13.."
apt-get -qq remove postgresql-13 &> /dev/null
#apt-get -qq purge postgresql-13 # Remove PostgreSQL directories when package is purged? [yes/no] --> don't know how to automatic answer this

_info "Import netbox database to new PostgreSQL cluster.."
pg_ctlcluster 15 main start
sudo -u postgres psql -c 'drop database netbox' > /dev/null
sudo -u postgres psql -c 'create database netbox' > /dev/null
# shellcheck disable=SC2024
sudo -u postgres psql netbox < /data/postgresql13_netbox.sql > /dev/null
pg_ctlcluster 15 main stop

_info "Database migration successful."

_info "Removing old PostgreSQL 13 database and data export.."
rm -rf /data/postgresql/13
rm /data/postgresql13_netbox.sql
_info "Cleanup done."
