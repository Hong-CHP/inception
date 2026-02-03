FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    php7.4-fpm php7.4-mysql curl \
    && rm -rf /var/lib/apt/lists/*

# 安装 wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

WORKDIR /var/www/wordpress
ENTRYPOINT ["setup.sh"]
CMD ["/usr/sbin/php-fpm7.4", "-F"]
