#!/bin/bash

mkdir -p /run/php

# 等待数据库启动
until mysqladmin ping -h"mariadb" --silent; do
    sleep 2
done

if [ ! -f "wp-config.php" ]; then
    wp core download --allow-root
    wp config create --allow-root \
        --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER \
        --dbpass=$(cat /run/secrets/db_password) --dbhost=mariadb
    
    wp core install --allow-root \
        --url=$DOMAIN_NAME --title="Inception" \
        --admin_user=$WP_ADMIN --admin_password=$(cat /run/secrets/db_password) \
        --admin_email="admin@42.fr"
    
    wp user create $WP_USER user@42.fr --user_pass=$(cat /run/secrets/db_password) --role=author --allow-root
fi

exec "$@"