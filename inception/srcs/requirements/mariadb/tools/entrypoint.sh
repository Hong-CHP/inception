#!/bin/bash

bash /usr/local/bin/init.sh

mysqld_safe &

until mysqladmin ping -h localhost --silent; do
    sleep 2
done

export MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ -f /docker-entrypoint-initdb.d/init.sql ];then
    mysql -u root < /docker-entrypoint-initdb.d/init.sql
fi

wait
