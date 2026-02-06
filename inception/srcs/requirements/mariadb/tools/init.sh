#!/bin/bash

mkdir -p /docker-entrypoint-initdb.d

while [ ! -f /run/secrets/db_password ]; do
	sleep 0.1
done

export MYSQL_PASSWORD="$(tr -d '\n' < /run/secrets/db_password)"
export MYSQL_ROOT_PASSWORD ="(tr -d '\n' < /run/secrets/db_password)"

cat <<EOF > /docker-entrypoint-initdb.d/init.sql
CREATE DATABASE IF NOT EXISTS '${MYSQL_DATABASE}';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON '${MYSQL_DATABASE}'.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
