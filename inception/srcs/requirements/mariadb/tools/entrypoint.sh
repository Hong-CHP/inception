#!/bin/bash

set -e
#-e if error exit
#-u if env var not defined exit

chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/run/mysqld

#bind adress to any adress
sed -i "s|127.0.0.1|0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf

#make sure mariadb is not initialized before
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."

    #initialized mariadb with mysql user and define data directory
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)

    echo "root password will be : $MYSQL_ROOT_PASSWORD"
    echo "user password will be : $MYSQL_PASSWORD"

    mysqld --user=mysql --skip-networking & pid="$!"

    # 等待MySQL启动
    for i in {30..0}; do
	if  mysqladmin ping --silent; then
		break
	fi
	echo "MariaDB waiting..."
	sleep 1
    done

    if [ "$i" = 0 ]; then
	echo >&2 'MariaDB init faied'
	exit 1
    fi
    # 设置root密码
    mysql <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # 停止
    echo "Stopping temporary instance"
    mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid"

    echo "MariaDB initialization completed"
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql
