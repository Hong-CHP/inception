# User documentation

## Service:
- **MariaDB**: database service, WordPress data stockage
- **WordPress**: website service, offering site's connections and gestions
- **Nginx**: HTTPS server service, receive client's requests and transfering these requests to PHP
- **PHP-FPM**: environment which handlers WordPress PHP codes

## Start and stop:
- find / directory where Makefile is
- **start**: make up
- **stop**: make stop (only stop running container)
- **clean**: make down (only remove container will not clean data volumes)
- **fclean**: make fclean (clean all history data on host, remove all container, images and build cache)
- **rebuild**: make re (clean all history data on host, remove all container, images and build cache; then, build again)

## Access
- **URL**: http://hporta-c.42.fr
	- to visit homepage
- **URL**: http://hporta-c.42.fr/wp-admin
	- visit as adminstrator

## Locate and manage credentials
- all sensible informations are memoried in /secrets/credentials.txt
- access it using command:
`$ /run/secrets/credentials`

## Status:
`docker ps` to check status about all running containers
`docker logs <container's name>` to check all output about running container