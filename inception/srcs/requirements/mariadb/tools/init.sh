#!/bin/bash

mkdir -p /docker-entrypoint-initdb.d

while [ ! -f /run/secrets/db_password ]; do
	sleep 0.1
done

export MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
export MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
echo "Database password loaded"

# cat <<EOF > /docker-entrypoint-initdb.d/init.sql
# CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
# CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY "${MYSQL_PASSWORD}";
# GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
# FLUSH PRIVILEGES;
# EOF

# echo "Initialization SQL created"

# 使用环境变量（确保它们已经定义）
cat <<EOF > /docker-entrypoint-initdb.d/init.sql
-- 设置 root 密码
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- 创建数据库
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- 创建用户并授权
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- 刷新权限
FLUSH PRIVILEGES;
EOF

echo "Generated init.sql with database: ${MYSQL_DATABASE}"
