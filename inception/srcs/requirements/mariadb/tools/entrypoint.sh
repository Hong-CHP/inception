#!/bin/bash

set -eu
#-e if error exit
#-u if env var not defined exit

#bind adress to any adress
if [ ! -f "/etc/mysql/mariadb.conf.d/50-server.cnf.bak" ]; then
    sed -i "s|127.0.0.1|0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf
    touch /etc/mysql/mariadb.conf.d/50-server.cnf.bak
    echo "Inception: Config updated to listen on 0.0.0.0"
fi
#make sure mariadb is not initialized before
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB..."

	#initialized mariadb with mysql user and define data directory
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	#initialzed in bootstrap way
	mysqld --bootstrap <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_password)';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_root_password)';
FLUSH PRIVILEGES;
EOF

	echo "MariaDB initialized"
fi

exec mysqld --user=mysql
