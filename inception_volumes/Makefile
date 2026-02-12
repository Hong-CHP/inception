COMPOSE = docker compose -p inception -f srcs/docker-compose.yml

all: up

up:
	mkdir -p /home/hporta-c/data/mariadb
	mkdir -p /home/hporta-c/data/wordpress
	sudo chown -R 999:999 /home/hporta-c/data/mariadb
	sudo chown -R 33:33 /home/hporta-c/data/wordpress
	$(COMPOSE) up -d --build

stop:
	$(COMPOSE) stop

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean: clean
	sudo rm -rf /home/hporta-c/data/mariadb
	sudo rm -rf /home/hporta-c/data/wordpress
	$(COMPOSE) images -q | xargs -r docker rmi -f
	docker buildx prune -f --filter "label=com.docker.compose.project=inception"

re: fclean all

.PHONY: all up down clean fclean re
