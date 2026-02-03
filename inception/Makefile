COMPOSE = docker compose -f srcs/docker-compose.yml

all: up

up:
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean:
	sudo rm -rf /home/hporta-c/data/mysql
	sudo rm -rf /home/hporta-c/data/wordpress
	docker system prune -af

re: fclean all

.PHONY: all up down clean fclean re
