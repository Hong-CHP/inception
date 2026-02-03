FROM debian:bookworm-slim

RUN apt update && apt install -y nginx openssl ca-certificates && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 \
	-newkey rsa:2048 \
	-keyout /etc/nginx/ssl/cert.key \
	-out /etc/nginx/ssl/cert.pem \
	-subj "/CN=hporta.42.fr" 

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
