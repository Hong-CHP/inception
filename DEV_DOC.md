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
	need be initialized when start it first time, and can't be reinitialized repeatly when run it again. We need create this logic:
	"if data is empty:
		initial database
		create database
		create user
		give permission
	start mariadb"

## Manage the containers and volumes
## Data persistence