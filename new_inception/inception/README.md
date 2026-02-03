# Inception
*This project has been created as part of 42 curriculum by hporta-c.*


## Description:

**Docker** is a intergation technology to unify a program with its enviroment in a image by publicating on Docker hub for rendring the utilsation of apk more convinient and efficient.
This project is a learning environment for exploring the Docker ecosystem. It covers how to build custom Docker images, manage containers efficiently, and use Docker Compose to orchestrate multi‑container applications. The goal is to provide hands‑on examples that help you understand the real‑world Docker workflows.  struct by Docker compose, include Nginx, MariaDB and WordPress(PHP-FPM) custom docker images base from debian: bookworm-slim.

### 1. Design choices: 
1. **Nginx**: Nginx is webserver, using to read and send request from client connection. Nginx is the only entrypoint. Implemented a reverse proxy pattern. Nginx is the only service exposing a port 443 to the host:
- **Enhance security**: By isolating WordPress and MariaDB in a private network.
- **Centralize SSL/TLS**: Nginx handles the encryption/decryption using TSLv1.2/v1.3, ensuring all incoming traffic is secure before reaching internal services.
- **Simplified infrastructure**: it allows for a single point of configuration for routing, logging, and security policies.
2. **MariaDB**: contains `mariadb-server` and `mariadb-client`. The first one is the server and the second one is client. Server part has missions to start mysql and manage data files, listen port `3306`, it offers WordPress(PHP-FPM) other services. Client part is a mysql commands tool, could connect to server part and test the database running normaly, and executes and operates database.  
3. **WordPress**: 
4. **Automation**: Custom-built images based on `debian:bookworm-slim`, orchestrated via a private bridge network. A `Makefile` manages the entire lifecycle (build, run, clean).
	
### 2. Comparison:
- **Virtual Machine vs Docker**: VM contain the entire OS, resulting in slow startup and high resource consumption. However, Docker shares the host machine kernel, offering lightweight operation and instant startup.
- **Secrets vs Environment variables**: Environment variables are leaked in docker inspect, but Secrets are mounted via memory files(/run/secrets), which is more secure.
- **Docker network vs Host network**: Docker network has three principal mode, bridge, host or none. Host mode shares directly network between host and container. 
	Using cmd(for example):
	`$ docker network create --driver bridge --subnet 196.168.0.0/16	--gateway 192.168.0.1 mynet`
	can create a network "mynet" in bridge mode with subnet address than using cmd:
	`$ docker run -d -P --name debian01 --net mynet debian`
	can isolat container "debian01" in a independant network system.
- **Docker Volumes vs Bind Mounts**: Binds Mounts depends on the host path, in contrary, Volumes is operated by docker-compose.yml, better cross-platfrom compatibility and greater security.


## Instructions

### 1. Installation & Configuration
Before running the infrastructure, you need to set up your local environment:
- **Domain**: Add `127.0.0.1 <login>.42.fr` to your `/etc/hosts`.
- **Environment**: Create a `.env` file in `srcs/` based on `.env.example`.
- **Data Volumes**: Ensure the data directories exist (e.g., `/home/<login>/data`).

### 2. Compilation & Execution
This project uses a **Makefile** to automate the Docker Compose process:
- To build and start the containers: `make`
- To stop the services: `make down`
- To reset the project (including volumes): `make fclean`

### 3. Usage
Once the build is complete, access the website via **HTTPS**: `https://<login>.42.fr`.
For more detailed administrative or technical instructions, please refer to [USER_DOC.md](./USER_DOC.md) and [DEV_DOC.md](./DEV_DOC.md).

## Resources
* [Docker Documentation](https://docs.docker.com)
* [【狂神说Java】Docker最新超详细版教程通俗易懂](https://www.bilibili.com/video/BV1og4y1q7M4/?spm_id_from=333.337.search-card.all.click)
* [1 小时教你学会 Docker Docker-compose](https://www.bilibili.com/video/BV16M4y1H7aH/?spm_id_from=333.337.search-card.all.click)

### AI Usage
- **Tools**: Gemini (or ChatGPT) was used as a learning assistant.
- **Tasks**: 
  - Designing the logic for the `Makefile` to ensure proper container orchestration.
  - Refined the ssl configuration for the Nginx `nginx.conf`.
  - helps to write a Makefile call docker-compose.yml