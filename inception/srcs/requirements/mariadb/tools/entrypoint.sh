#!/bin/bash

set -eu
#-e if error exit
#-u if env var not defined exit

#make sure mariadb is not initialized before
if [ ! -d "/var/lib/mysql/mysql "]; then
	echo "Initializing MariaDB..."

	#initialized mariadb with mysql user and define data directory
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	#initialzed in bootstrap way
	mariadb --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_root_password)';
FLUSH PRIVILEGES;
EOF

	echo "MariaDB initialized"
fi

exec "$@"