-- https://docs.netbox.dev/en/stable/installation/1-postgresql/#database-creation
CREATE DATABASE netbox;
CREATE USER netbox WITH PASSWORD 'netbox';
ALTER DATABASE netbox OWNER TO netbox;
-- the next two commands are needed on PostgreSQL 15 and later
\connect netbox;
GRANT CREATE ON SCHEMA public TO netbox;
