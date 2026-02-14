#!/bin/bash

set -u

echo "WordPress Initialization"
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "Waiting for port 3306 to be open..."
for i in {1..30}; do
    if nc -z "${MYSQL_HOST}" 3306 2>/dev/null; then
        echo "Port 3306 is open after ${i} seconds"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "Port 3306 still not open after 60 seconds"
    fi
    sleep 2
done

echo "MariaDB is ready!"
sleep 5

MYSQL_PASSWORD=$(cat "/run/secrets/db_password")

echo "Checking database connection with wp-cli.."
sleep 10

if [ ! -f "/var/www/html/wp-config.php" ]; then
	cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

	sed -i "s/database_name_here/${MYSQL_DATABASE}/" /var/www/html/wp-config.php
	sed -i "s/username_here/${MYSQL_USER}/" /var/www/html/wp-config.php
	sed -i "s/password_here/${MYSQL_PASSWORD}/" /var/www/html/wp-config.php
	sed -i "s/localhost/${MYSQL_HOST}/" /var/www/html/wp-config.php
fi

if ! wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
	ADMIN_USER=$(grep WP_ADMIN_USER /run/secrets/credentials | cut -d '=' -f2)
	ADMIN_PWD=$(grep WP_ADMIN_PASSWORD /run/secrets/credentials | cut -d '=' -f2)
	WPU_USR=$(grep WP_USR /run/secrets/credentials | cut -d '=' -f2)
    WPU_PWD=$(grep WP_PWD /run/secrets/credentials | cut -d '=' -f2)
    WPU_EMAIL=$(grep WP_EMAIL /run/secrets/credentials | cut -d '=' -f2)

	echo "WordPress database not found. Installing..."
	wp core install \
		--path=/var/www/html \
		--url="https://hporta-c.42.fr" \
		--title="Inception" \
		--admin_user="${ADMIN_USER}" \
		--admin_password="${ADMIN_PWD}" \
		--admin_email="hporta-c@student.42.fr" \
		--skip-email \
		--allow-root

	wp user create \
		"${WPU_USR}" "${WPU_EMAIL}" \
		--user_pass="${WPU_PWD}" \
        --role=author \
		--path=/var/www/html \
		--allow-root
else
	echo "WordPress already installed."
fi

mkdir -p /run/php
chown www-data:www-data /run/php

echo "WordPress launch succesfully!"

exec /usr/sbin/php-fpm7.4 -F