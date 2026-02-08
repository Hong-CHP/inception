# Developer documentation

## Set up the environment from scratch

### I. Prerequisites
1. **OS required:** Debian/Ubuntu
2. **Install Docker:** 
	- visit official docker website `www.https://docs.docker.com/engine/install/`
	- chose your os system
	- follow commands used to intall docker on your Debian/Ubuntu system
3. **Docker compose:**
	- ensure your docker compose is installed by command: `docker compose version`
	- if you don't have docker compose, please use command: `$ sudo apt-get update` `$ sudo apt-get install docker-compose-plugin`
4. **Install make:**
	- `$ sudo apt-get update`
	- `$ sudo apt-get install build-essential`
	check make installed successfully:
	- `make --version`

### II. Configuration files
1. **.env**
	- use to replace variables in docker-compose.yml
	- in this file: you need change DOMAIN_NAME=<login>.42.fr
	- ensure host data path is DATA_PATH=/home/<login>/data
	- have a db_datebase name: MYSQL_DATABSE
	- have a db_user: MYSQL_USER

2. **/etc/hosts**
	- make sure the rule `127.0.0.1 <login>.42.fr` is added to your `/etc/hosts`.

### III. Secrets
In directory secrets/, we find three .txt files
1. **credential.txt**: WordPress admin informations
2. **db_password.txt**: wordpress user password
3. **db_root_password.txt**: MariaDB root user password

In **docker-compose.yml**, we find a `secrets`content in which we define a path to each .txt contain a password correspond. Below of `secrets`, each container has a `services` content in which a line call a password mounted. When command `docker compose up` executed, Docker read /run/secrets/xx_password.

In `Dockerfile`, ENV define, for example `ENV MYSQL_PASSWORD_FILE /run/secrets/db_password` to read file.

## Build and launch

### I. MariaDB:
1. **Dockerfile**: 
	- Base from debian:bookworm-slim;
	- update system then install `mariadb-server` and `mariadb-client`, remove all install package
	- mkdir `/var/run/mysqld` where stocks a mysqld.sock, and `/var/lib/mysql` stocks all mysql data
	- ensure mysql user have permission to read `/var/run/mysqld` and `/var/lib/mysql`
	- copy init.sh entrypoint.sh scripts in `/usr/local/bin` and make sure the script can be executed
	- expose 3306 port
	- execute cmd `/usr/local/bin/entrypoint.sh`
2. **init.sh**
	- export password files as environment variables, because these contents are not stocken in .env as environment variables, there are in /secrets, and when docker run, docker get invisibly in /run/secrets
	- create an init.sql, heredoc inside :
		- create root with root password, and grant all privileges on all databases to root
		- create database(wordpress)
		- create mysql_user(wp_user) with user password, and grant all privileges wordpress database to wp_user
3. **entrypoint.sh**(the most complicated configuration)
	- make sure the directory are exist and has right (for socket)
	- get start init.sh
	- get root password again
	-  need be initialized when start it first time, and can't be reinitialized repeatly when run it again. We need create this logic:
	"if `/var/lib/mysql/myqsl` is empty:
		initial database
		create a pid listen mysqld.sock to set up
		executing init.sql
		stop pid as mysqladmin through socket
	start mariadb"

### II. WordPress:
1. **Dockerfile**: 
	- Base from debian:bookworm-slim;
	- update system then install `wget`, `curl`, `php-fpm`, `php-mysql`
	- `mkdir -p /usr/src/wordpress`
	- wget wordpress website content
	- tar wordpress package under directory /usr/src/wordpress
	- remove all install package
	- copy entrypoint script in `/usr/local/bin` and make sure the script can be executed
	- curl wp-cli.phar command tools in /usr/local/bin/wp make sure executable for using commands in side of wordpress container to config user 
	- copy www.conf, entrypoint.sh
	- execute cmd `/usr/local/bin/entrypoint.sh` append `/usr/sbin/php-fpm8.2 -F`
2. **conf/www.conf**
	- loading php and read php.ini and extension is too slow, so we need fastcgi_pass process pool
	- php-fpm user is www-data to ensure permission for /var/www/html
	- use dynamic mode to cross or decrease according to need 
2. **entrypoint.sh**
	- make sure www-data user have permission
	- copy files from /usr/src/wordpress to /var/www/html, give permission
	- waiting port mariadb 3306 open
	- use /var/www/html/wp-config.php to config how wordpress connects mariadb
	- check is wordpress tab is ok, if not, config then
	- take all user data from credentials file
	- root install wordpress
	- root create user

### III. Nginx
1. **Dockerfile**:
	- Base from debian:bookworm-slim;
	- update system then install `nginx`, `openssl`, `ca-certificates`
	- `mkdir -p /etc/nginx/ssl`
	- new key and pem out
	- copy conf file from host to container
2. **nginx.conf**
	- define ssl_protocols and certificates
	- listen 443 as required
	- define server_name to ensure <login>.42.fr == 127.0.0.1
	- define root directory for web and default index content
	- if match location /, try find file at /var/www/html/ or /var/www/html/* else, do index.php with args. Match with ext .php, include all env of fastcgi, tranferer request to wordpress:9000, then handler by /var/www/html/scriptname.sh

### docker-compose.yml
	- define secrets files's paths
	- container_name as required;
	- build from path?
	- secrets sources from ?
	- volumes host_path:container_path
	- define a network driver bridge

### build
**Without Makefile**
- build each images separatly with cmd:
`$ docker compose build mariadb`
`$ docker compose build wordpress`
`$ docker compose build nginx`
- create container from images and launch it in detached mode(en background) with cmd:
`$ docker compose up -d mariadb`
`$ docker compose up -d wordpress`
`$ docker compose up -d nginx`
- open an interactive terminal inside a running container with cmd:
`$ docker exec -it mariadb bash`
`$ docker exec -it wordpress bash`
`$ docker exec -it nginx bash`
- remove container and network
`$ docker compose down`
- clean container, network and remove named volumes declared in the "volumes" section of the Compose file and anonymous volumes attached to containers
`$ docker compose down -v`
- remove all images, build cache
`$ docker system prune -af`

**With Make**
- make all: make up
- make up: build images and lauch it in detached mode
- make down: remove container and network
- make clean: remove container, network and volumes
- make fclean: remove container, network and bind volumes, cache and all images
- make re: make clean then make up

## Manage the containers and volumes
- create volumes for containers by add volumes parameter in docker-compose.yml
"volumes:
	- host_path:container_path"

## Data persistence
When container or images are removed, the volumes mounted in host directory will persist.
When we build a new image and a new container
- volumes defined in docker-compose.yml can cover container volumes's path
- a script can resolv and make sure an exitant directory or file would not be reinitialized by a new one
- when rebuild image totally, make sure all data is remove on host