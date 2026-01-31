FROM debian:bookworm-slim

RUN apt update && apt install -y wget tar \
		php-fpm php-mysql php-gd php-xml php-curl php-zip \
	&& mkdir -p /var/www/html \
	&& wget https://wordpress.org/latest.tar.gz \
	&& tar -xzf latest.tar.gz -C /var/www/html --strip-components=1 \
	&& rm -f latest.tar.gz \
	&& rm -rf /var/lib/apt/lists/*

ENV MYSQL_HOST mariadb
ENV MYSQL_USER wp_user
ENV MYSQL_PASSWORD_FILE /run/secrets/db_password
ENV MYSQL_DATABASE wordpress

CMD ["php-fpm", "-F"]
