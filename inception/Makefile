COMPOSE = docker compose -f srcs/docker-compose.yml

all: up

up:
	mkdir -p /home/hporta-c/data/mariadb
	mkdir -p /home/hporta-c/data/wordpress
	chown -R 999:999 /home/hporta-c/data/mariadb
	chown -R 33:33 /home/hporta-c/data/wordpress
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean:
	sudo rm -rf /home/hporta-c/data/mariadb
	sudo rm -rf /home/hporta-c/data/wordpress
	docker system prune -af

re: fclean all

.PHONY: all up down clean fclean re
