#!/bin/bash

mkdir -p /docker-entrypoint-initdb.d

while [ ! -f /run/secrets/db_password ]; do
	sleep 0.1
done

export MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
echo "Database password loaded"

cat <<EOF > /docker-entrypoint-initdb.d/init.sql
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('888888');
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS 'wp_user'@'%' IDENTIFIED VIA mysql_native_password USING PASSWORD('123456');
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'%';
FLUSH PRIVILEGES;
EOF

echo "Initialization SQL created"