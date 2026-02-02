FROM debian:bookworm-slim

RUN apt update && apt install -y wget tar \
		php-fpm php-mysql php-gd php-xml php-curl php-zip \
	&& mkdir -p /var/www/html \
	&& wget https://wordpress.org/latest.tar.gz \
	&& tar -xzf latest.tar.gz -C /var/www/html --strip-components=1 \
	&& rm -f latest.tar.gz \
	&& rm -rf /var/lib/apt/lists/*

COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
	
CMD ["/usr/sbin/php-fpm8.2", "-F"]
