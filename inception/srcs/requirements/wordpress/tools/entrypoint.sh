#!/bin/bash

set -eu

if [ -f "/etc/php/8.2/fpm/pool.d/www.conf" ]; then
      sed -i "s|listen = /run/php/php8.2-fpm.sock|listen = 9000|g" /etc/php/8.2/fpm/pool.d/www.conf
fi

if [ -z "$(ls -A /var/www/html)" ]; then
    cp -r /usr/src/wordpress/* /var/www/html/
fi

if [ ! -f "/var/www/html/wp-config.php" ]; then
	cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

	sed -i "s/database_name_here/${MYSQL_DATABASE}/" /var/www/html/wp-config.php
	sed -i "s/username_here/${MYSQL_USER}/" /var/www/html/wp-config.php
	sed -i "s/password_here/$(cat ${MYSQL_PASSWORD_FILE})/" /var/www/html/wp-config.php
	sed -i "s/localhost/${MYSQL_HOST}/" /var/www/html/wp-config.php
fi

cd /var/www/html

if ! wp core is-installed --allow-root; then
	ADMIN_USER=$(grep WP_ADMIN_USER /run/secrets/credentials | cut -d '=' -f2)
	ADMIN_PWD=$(grep WP_ADMIN_PASSWORD /run/secrets/credentials | cut -d '=' -f2)
	WPU_USR=$(grep WP_USR /run/secrets/credentials | cut -d '=' -f2)
    WPU_PWD=$(grep WP_PWD /run/secrets/credentials | cut -d '=' -f2)
    WPU_EMAIL=$(grep WP_EMAIL /run/secrets/credentials | cut -d '=' -f2)

	echo "WordPress database not found. Installing..."
	wp core install --allow-root \
		--url="${DOMAIN_NAME}" \
		--title="Inception" \
		--admin_user="${ADMIN_USER}" \
		--admin_password="${ADMIN_PWD}" \
		--admin_email="hporta-c@student.42.fr" \
		--skip-email

	wp user create --allow-root \
		"${WPU_USR}" "${WPU_EMAIL}" \
		--user_pass="${WPU_PWD}" \
        --role=author
fi

echo "WordPress launch succesfully!"

exec "$@"
