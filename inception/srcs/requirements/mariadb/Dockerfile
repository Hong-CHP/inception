FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	mariadb-server \
	mariadb-client \
	&& sed -i "s|127.0.0.1|0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

EXPOSE 3306

# COPY tools/init.sh /usr/local/bin
# RUN chmod +x /usr/local/bin/init.sh

COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
