#!/bin/bash

set -eu
#-e if error exit
#-u if env var not defined exit

chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/run/mysqld

#bind adress to any adress
sed -i "s|127.0.0.1|0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf

#make sure mariadb is not initialized before
if [ -z "$(ls -A /var/lib/mysql)" ]; then
	echo "Initializing MariaDB..."

	#initialized mariadb with mysql user and define data directory
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
	
	echo "root password will be : $MYSQL_ROOT_PASSWORD"
	echo "user password will be : $MYSQL_PASSWORD"

    echo "Starting temporary MySQL instance..."
    mysqld_safe --datadir=/var/lib/mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    
    # 等待MySQL启动
    sleep 10
    
    # 设置root密码
    echo "Setting root password..."
    mysql --socket=/var/run/mysqld/mysqld.sock<<EOF
USE mysql;
UPDATE user SET password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root';
UPDATE user SET plugin='mysql_native_password' WHERE User='root';
FLUSH PRIVILEGES;
EOF

    echo "Root password set"
    # 停止临时实例
    mysqladmin --socket=/var/run/mysqld/mysqld.sock shutdown
    sleep 5
    
    # 重新启动以创建数据库和用户
    echo "Starting MySQL to create database and user..."
    mysqld_safe --datadir=/var/lib/mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    sleep 10
    
    # 创建数据库和用户
    mysql --socket=/var/run/mysqld/mysqld.sock -uroot -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

    echo "Database and user created"

    # 停止MySQL
    echo "Stopping MySQL..."
    mysqladmin --socket=/var/run/mysqld/mysqld.sock -uroot -p$MYSQL_ROOT_PASSWORD shutdown
    sleep 3
    
    echo "MariaDB initialization completed"
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql