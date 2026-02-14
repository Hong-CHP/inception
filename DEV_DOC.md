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
2. **db_password.txt**: mysql user password
3. **db_root_password.txt**: mysql root password

In **docker-compose.yml**, we find a `secrets` section in which we define a path to go each .txt contain a password string. When command `docker compose up` executed, Docker read for example, in environment, /run/secrets/xx_password, call `secrets: xx_password`, find password file through path defined in `secrets`.

In a script where we need the password content to configure, by export environment definition in docker-compose, for example `export MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")` to read file.

## Build and launch

### I. MariaDB:
1. **Dockerfile**: 
	- Base from debian:bullseye;
	- update system then install `mariadb-server` and `mariadb-client`, remove all install package
	- mkdir `/var/run/mysqld` where stocks a mysqld.sock, and `/var/lib/mysql` stocks all mysql data
	- change all files et directories : `/var/run/mysqld` and `/var/lib/mysql` owner, to user mysql, group mysql
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
	- get start init.sh
	- get root password again
	- `mysql_install_db` starts the mysql initialization
	- `mysqld_safe` start mysql server, create a listen socket with pid
	- `mysqladmin ping` checks connection
	- connect and enter mariadb as root, use mysql database then change psseword and delete test database， flush privileges
	- execute init.sql
	- stop temporary server 
	- start mariadb again

### II. WordPress:
1. **Dockerfile**: 
	- Base from debian:bullseye;
	- update system then install `wget`, `curl`, `php-fpm`, `php-mysql`
	- `mkdir -p /var/www/html/`
	- wget wordpress website content
	- tar wordpress package under directory /var/www/html/
	- remove all install package
	- copy entrypoint script in `/usr/local/bin` and make sure the script can be executed
	- curl wp-cli.phar command tools in /usr/local/bin/wp make sure executable for using commands in side of wordpress container to config user 
	- copy www.conf, entrypoint.sh
	- execute cmd `/usr/local/bin/entrypoint.sh`
2. **conf/www.conf** (process pool)
	- loading php and read php.ini and extension is too slow, so we need fastcgi_pass process pool
	- execute pool as existant user www-data and existent group www-data
	- configure socket user and group as www-data
	- use dynamic mode to cross or decrease according to need
	- max 5 children process
	- create 2 children when start
	- ensure min children process, create new one if not enough
	- ensure maximun children process, if beyond the max, kill someone
2. **entrypoint.sh**
	- make sure user and group owner
	- waiting port mariadb 3306 open
	- use /var/www/html/wp-config.php to config how mariadb gets wordpress data
	- check is wordpress tab is ok, if not, config then
	- take all user data from credentials file
	- root install wordpress, create adminstator managering website configurations, users, design...
	- root create normal user for publishing...

### III. Nginx
1. **Dockerfile**:
	- Base from debian:bullseye;
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
	- `secrets` section, `services` section, `networks` section and `volumes` section
	- define secrets files's paths
	- container_name as required;
	- build from path?
	- secrets sources from ?
	- used named volume method to create docker volume
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
- make fclean: remove container, network and named volumes, cache and all images identifed by a same label
- make re: make clean then make up

## Manage the containers and volumes
- create volumes sections and named volumes
- indicate in internal container a data volumes under directory: /var/lib/docker/volumes/*
- when we use driver options, we use actually src path on host machine to bind volume

## Data persistence
When container or images are removed, the volumes mounted in host directory will persist.
When we build a new image and a new container
- volumes defined in docker-compose.yml can cover container volumes's path
- a script can resolv and make sure an exitant directory or file would not be reinitialized by a new one
- when rebuild image totally, make sure all data is remove on host