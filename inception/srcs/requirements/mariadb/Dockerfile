# FROM debian:bookworm-slim

# ENV DEBIAN_FRONTEND=noninteractive

# RUN apt-get update && apt-get install -y \
# 	mariadb-server \
# 	mariadb-client \
# 	&& sed -i "s|127.0.0.1|0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf \
# 	&& apt-get clean \
# 	&& rm -rf /var/lib/apt/lists/*

# EXPOSE 3306

# RUN mkdir -p /var/lib/mysql /var/run/mysqld && \
# 	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# COPY tools/init.sh /usr/local/bin
# RUN chmod +x /usr/local/bin/init.sh

# COPY tools/entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/entrypoint.sh

# CMD ["/usr/local/bin/entrypoint.sh"]
# 基础镜像
FROM ubuntu:22.04

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 安装必要工具
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    debconf-utils \
    && rm -rf /var/lib/apt/lists/*

# 预设 root 密码
RUN echo "mariadb-server-10.11 mysql-server/root_password password MyRootPass123" | debconf-set-selections && \
    echo "mariadb-server-10.11 mysql-server/root_password_again password MyRootPass123" | debconf-set-selections

# 创建初始化脚本：创建普通用户 myuser
COPY tools/init.sh /usr/local/bin
RUN chmod +x /usr/local/bin/init.sh

# 设置工作目录
WORKDIR /var/lib/mysql

# 公开端口
EXPOSE 3306

# 启动 MariaDB
CMD ["mysqld_safe"]
