FROM debian:bookworm-slim

RUN apt update && apt install -y wget tar curl netcat-openbsd \
		php-fpm php-mysql php-gd php-xml php-curl php-zip \
	&& mkdir -p /usr/src/wordpress \
	&& wget https://wordpress.org/latest.tar.gz \
	&& tar -xzf latest.tar.gz -C /usr/src/wordpress --strip-components=1 \
	&& rm -f latest.tar.gz \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
	
CMD ["/usr/sbin/php-fpm8.2", "-F"]
