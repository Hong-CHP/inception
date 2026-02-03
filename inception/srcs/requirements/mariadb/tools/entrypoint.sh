#!/bin/bash

set -eu
#-e if error exit
#-u if env var not defined exit

chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/run/mysqld

#bind adress to any adress
if [ ! -f "/etc/mysql/mariadb.conf.d/50-server.cnf.bak" ]; then
    sed -i "s|127.0.0.1|0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf
    touch /etc/mysql/mariadb.conf.d/50-server.cnf.bak
    echo "Inception: Config updated to listen on 0.0.0.0"
fi
#make sure mariadb is not initialized before
if [ -z "$(ls -A /var/lib/mysql)" ]; then
	echo "Initializing MariaDB..."

	#initialized mariadb with mysql user and define data directory
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	#initialzed in bootstrap way
	mysqld --user=mysql --bootstrap <<EOF
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
#!/bin/bash

# set -eu

# # 设置权限
# chown -R mysql:mysql /var/lib/mysql
# chown -R mysql:mysql /var/run/mysqld

# # 修改配置文件以监听所有地址
# if [ ! -f "/etc/mysql/mariadb.conf.d/50-server.cnf.bak" ]; then
#     sed -i "s|127.0.0.1|0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf
#     touch /etc/mysql/mariadb.conf.d/50-server.cnf.bak
#     echo "配置已更新为监听 0.0.0.0"
# fi

# # 如果数据库未初始化，则进行初始化
# if [ ! -d "/var/lib/mysql/mysql" ]; then
#     echo "初始化MariaDB..."
    
#     # 初始化系统表
#     mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
#     # 启动临时mysqld进程
#     mysqld_safe --datadir=/var/lib/mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    
#     # 等待MySQL启动
#     sleep 10
    
#     # 读取密码
#     ROOT_PASS=$(cat /run/secrets/db_root_password)
#     USER_PASS=$(cat /run/secrets/db_password)
    
#     echo "设置root密码: $ROOT_PASS"
#     echo "设置用户密码: $USER_PASS"
    
#     # 设置root密码（使用mysql_native_password插件）
#     mysql <<EOF
# USE mysql;
# UPDATE user SET plugin='mysql_native_password' WHERE User='root';
# FLUSH PRIVILEGES;
# ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
# DELETE FROM mysql.user WHERE User='';
# DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
# DROP DATABASE IF EXISTS test;
# DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
# FLUSH PRIVILEGES;
# EOF
    
#     # 停止临时进程
#     kill $(cat /var/run/mysqld/mysqld.pid)
#     sleep 5
    
#     # 重新启动mysqld以应用更改
#     echo "重新启动MariaDB以应用配置..."
#     mysqld_safe --datadir=/var/lib/mysql &
#     sleep 10
    
#     # 创建数据库和用户
#     mysql -u root -p${ROOT_PASS} <<EOF
# CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
# CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${USER_PASS}';
# CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${USER_PASS}';
# GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
# GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
# FLUSH PRIVILEGES;
# EOF
    
#     # 停止mysqld
#     mysqladmin -u root -p${ROOT_PASS} shutdown
#     sleep 5
    
#     echo "MariaDB初始化完成"
# else
#     echo "MariaDB已存在，跳过初始化"
# fi

# echo "启动MariaDB..."
# exec mysqld --user=mysql
