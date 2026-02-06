#!/bin/bash

bash /usr/local/bin/init.sh

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