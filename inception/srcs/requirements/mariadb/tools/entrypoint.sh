#!/bin/bash

bash /generate_init.sh

mysqld_safe &

until mysqladmin ping -h localhost --silent; do
    sleep 2
done

if [ -f /docker-entrypoint-initdb.d/init.sql ];then
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" < /docker-entrypoint-initdb.d/init.sql
fi

wait
