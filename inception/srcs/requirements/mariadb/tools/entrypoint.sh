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
    
    # 关键修复：使用skip-grant-tables启动
    echo "Starting temporary MySQL instance for initialization..."
    mysqld_safe --skip-grant-tables --socket=/var/run/mysqld/mysqld.sock &
    sleep 10

    # 设置root密码 - 使用传统UPDATE方法，这是最可靠的
    echo "Setting root password..."
    mysql --socket=/var/run/mysqld/mysqld.sock <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'ROOT_PASSWORD';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'ROOT_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

    echo "Restarting MySQL with password..."
    mysqladmin --socket=/var/run/mysqld/mysqld.sock shutdown
    sleep 5
    
    # 重新启动MySQL
    mysqld_safe --socket=/var/run/mysqld/mysqld.sock &
    sleep 10

    # 创建数据库和用户
    echo "Creating database and user..."
    mysql --socket=/var/run/mysqld/mysqld.sock -uroot -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

    echo "Stopping temporary instance..."
    mysqladmin --socket=/var/run/mysqld/mysqld.sock -uroot -p$MYSQL_ROOT_PASSWORD shutdown
    sleep 5

    echo "MariaDB initialization completed"
fi
#     mysqld --user=mysql --skip-networking & pid="$!"

#     # 等待MySQL启动
#     for i in {30..0}; do
# 	if  mysqladmin ping --silent; then
# 		break
# 	fi
# 	echo "MariaDB waiting..."
# 	sleep 1
#     done

#     if [ "$i" = 0 ]; then
# 	echo >&2 'MariaDB init faied'
# 	exit 1
#     fi
#     # 设置root密码
#     mysql <<EOF
# CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
# CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
# CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
# GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
# GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
# ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
# FLUSH PRIVILEGES;
# EOF

#     # 停止
#     echo "Stopping temporary instance"
#     mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
#     wait "$pid"

#     echo "MariaDB initialization completed"
# fi

echo "Starting MariaDB..."
exec mysqld --user=mysql
