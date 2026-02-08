#!/bin/bash

#------------------------v1-----------------------
# set -e

# MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE"
#unset MYSQL_HOST
#MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")

# DATADIR="/var/lib/mysql"
# SOCKET="/run/mysqld/mysqld.sock"

# echo "▶ MariaDB entrypoint starting"

# # ------------------------------------------------------------------
# # INIT PHASE (first run only)
# # ------------------------------------------------------------------
# if [ ! -d "$DATADIR/mysql" ]; then
#     echo "▶ Initializing database directory"

#     chown -R mysql:mysql "$DATADIR"
#     mysql_install_db --user=mysql --datadir="$DATADIR"

#     echo "▶ Starting MariaDB (socket only, no TCP)"
#     mysqld --user=mysql \
#            --datadir="$DATADIR" \
#            --skip-networking \
#            --socket="$SOCKET" &
#     pid="$!"

#     echo "▶ Waiting for socket to be ready"
#     until mysqladmin --socket="$SOCKET" ping --silent; do
#         sleep 1
#     done

#     echo "▶ Setting root password and basic security"
#     mysql --socket="$SOCKET" -u root <<EOF
# ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
# DELETE FROM mysql.user WHERE User='';
# DROP DATABASE IF EXISTS test;
# DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
# FLUSH PRIVILEGES;
# EOF

#     if [ -f /docker-entrypoint-initdb.d/init.sql ]; then
#         echo "▶ Running init.sql"
#         mysql --socket="$SOCKET" -u root -p"${MYSQL_ROOT_PASSWORD}" \
#             < /docker-entrypoint-initdb.d/init.sql
#     fi

#     echo "▶ Shutting down temporary MariaDB"
#     mysqladmin --socket="$SOCKET" -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
#     wait "$pid"

#     echo "▶ Database initialization completed"
# fi

# # ------------------------------------------------------------------
# # RUN PHASE
# # ------------------------------------------------------------------
# echo "▶ Starting MariaDB (TCP enabled)"
# exec mysqld --user=mysql --datadir="$DATADIR"

#------------------------v2-----------------------
# bash /usr/local/bin/init.sh

# mysqld_safe &

# export MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
# echo "my root pwd is : ${MYSQL_ROOT_PASSWORD}"

# echo "Waiting for MariaDB to start..."
# until mysqladmin ping -h localhost --silent; do
#     sleep 2
# done

# if [ -f /docker-entrypoint-initdb.d/init.sql ]; then
#     echo "Running initialization SQL..."
#     mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < /docker-entrypoint-initdb.d/init.sql
# fi

# wait

#------------------------v3-----------------------
# export MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
# echo "my root pwd is : ${MYSQL_ROOT_PASSWORD}"

# if [ ! -d "/var/lib/mysql/mysql" ]; then

#     echo "Initializing database..."
#     mysql_install_db --user=mysql --datadir=/var/lib/mysql

#     bash /usr/local/bin/init.sh

#     mysqld_safe --skip-networking &
#     PID=$!

#     echo "Waiting for MariaDB to start..."
#     until mysqladmin ping -h localhost --silent; do
#         sleep 2
#     done

#     echo "Setting root password..."
#     mysql -u root <<EOF
# ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
# DELETE FROM mysql.user WHERE User='';
# DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
# DROP DATABASE IF EXISTS test;
# DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
# FLUSH PRIVILEGES;
# EOF

#     if [ -f /docker-entrypoint-initdb.d/init.sql ];then
#         echo "Running initialization SQL..."
#         mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < /docker-entrypoint-initdb.d/init.sql
#     fi

#     if ! kill -s TERM "$PID" || ! wait "$PID"; then
#         echo "MariaDB initialization process failed"
#         exit 1
#     fi

#     echo "Database initialized successfully"
# fi

# echo "Starting MariaDB..."
# exec mysqld_safe

#------------------------v4-----------------------
# export MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
# echo "my root pwd is : ${MYSQL_ROOT_PASSWORD}"

# if [ ! -d "/var/lib/mysql/mysql" ]; then

#     echo "Initializing database..."
#     mysql_install_db --user=mysql --datadir=/var/lib/mysql

#     bash /usr/local/bin/init.sh

#     mysqld --user=mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
#     PID=$!

#     echo "Waiting for MariaDB to start..."
#     until mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; do
#         sleep 2
#     done

#     echo "Setting root password..."
#     mysql --socket=/var/run/mysqld/mysqld.sock -u root <<EOF
# ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
# DELETE FROM mysql.user WHERE User='';
# DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
# DROP DATABASE IF EXISTS test;
# DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
# FLUSH PRIVILEGES;
# EOF

    # if [ -f /docker-entrypoint-initdb.d/init.sql ];then
    #     echo "Running initialization SQL..."
    #     mysql --socket=/var/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" < /docker-entrypoint-initdb.d/init.sql
    # fi

#     if ! kill -s TERM "$PID" || ! wait "$PID"; then
#         echo "MariaDB initialization process failed"
#         exit 1
#     fi

#     echo "Database initialized successfully"
# fi

# echo "Starting MariaDB..."
# exec mysqld --user=mysql


#------------------------v4-----------------------
set -e

echo "Starting MariaDB setup..."

# 确保目录存在且有正确权限
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql

# 生成初始化脚本（使用环境变量）
bash /usr/local/bin/init.sh

export MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
echo "my root pwd is : ${MYSQL_ROOT_PASSWORD}"

# 如果数据库未初始化，则进行初始化
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    
    # 初始化数据库
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # 启动临时服务
    mysqld_safe --datadir=/var/lib/mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    MYSQL_PID=$!
    
    # 等待MySQL启动
    until mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; do
	sleep 2
    done
    
    echo "Setting up initial database..."
    
    # 使用环境变量设置 root 密码
    mysql -uroot --socket=/var/run/mysqld/mysqld.sock <<EOF
        USE mysql;
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE user = '';
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        FLUSH PRIVILEGES;
EOF
    
    # 执行初始化SQL
    if [ -f "/docker-entrypoint-initdb.d/init.sql" ]; then
        echo "Executing init.sql..."
        mysql -uroot --socket=/var/run/mysqld/mysqld.sock -p"${MYSQL_ROOT_PASSWORD}" < /docker-entrypoint-initdb.d/init.sql
    fi
    
    # 停止临时服务
    kill ${MYSQL_PID}
    wait ${MYSQL_PID}
fi

echo "Starting MariaDB server..."
# 最终启动服务
exec mysqld_safe --user=mysql --datadir=/var/lib/mysql
