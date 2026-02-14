FROM debian:bullseye

RUN apt update && apt install -y wget tar curl netcat-openbsd \
		php-fpm php-mysql php-gd php-xml php-curl php-zip \
#		mariadb-client \
	&& mkdir -p /var/www/html/ \
	&& wget https://wordpress.org/latest.tar.gz \
	&& tar -xzf latest.tar.gz -C /var/www/html/ --strip-components=1 \
	&& rm -f latest.tar.gz \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

RUN chown -R www-data:www-data /var/www/html \
    && chmod 755 /var/www/html

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

CMD ["/usr/local/bin/entrypoint.sh"]