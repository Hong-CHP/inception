#!/bin/bash

mkdir -p /docker-entrypoint-initdb.d

while [ ! -f /run/secrets/db_password ]; do
	sleep 0.1
done

export MYSQL_PASSWORD=$(cat"$MYSQL_PASSWORD_FILE")

echo "my pwd is : ${MYSQL_PASSWORD}"

cat <<EOF > /docker-entrypoint-initdb.d/init.sql
CREATE DATABASE IF NOT EXISTS '${MYSQL_DATABASE}';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON '${MYSQL_DATABASE}'.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# bash /usr/local/bin/init.sh

mysqld_safe &

until mysqladmin ping -h localhost --silent; do
    sleep 2
done

export MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")

echo "my root pwd is : ${MYSQL_ROOT_PASSWORD}"

if [ -f /docker-entrypoint-initdb.d/init.sql ];then
    mysql -u root -p'${MYSQL_ROOT_PASSWORD}' < /docker-entrypoint-initdb.d/init.sql
fi

wait
