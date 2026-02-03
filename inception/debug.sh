#!/bin/bash

echo "=== 测试数据库连接 ==="

cd srcs

# 停止所有容器
docker compose down

# 清理旧数据
sudo rm -rf /home/hporta-c/data

# 创建新数据目录
mkdir -p /home/hporta-c/data/mysql
mkdir -p /home/hporta-c/data/wordpress

# 构建容器
echo "构建容器..."
docker compose build --no-cache

# 只启动mariadb
echo "启动MariaDB..."
docker compose up -d mariadb

# 等待MariaDB启动
echo "等待MariaDB完全启动..."
sleep 30

# 测试root登录
echo "测试root登录..."
docker exec mariadb mysql -u root -p$(cat ../secrets/db_root_password) -e "SELECT 1;" 2>&1

if [ $? -eq 0 ]; then
    echo "✓ Root登录成功"
else
    echo "✗ Root登录失败"
fi

# 测试wp_user登录
echo "测试wp_user登录..."
docker exec mariadb mysql -u wp_user -p$(cat ..O/secrets/db_password) -e "SELECT 1;" 2>&1

if [ $? -eq 0 ]; then
    echo "✓ wp_user登录成功"
else
    echo "✗ wp_user登录失败"
    echo "尝试从WordPress容器测试连接..."
    
    # 启动wordpress容器
    docker compose up -d wordpress
    sleep 10
    
    docker exec wordpress bash -c "mysql -h mariadb -u wp_user -puserpwd -e 'SELECT 1;' 2>&1"
    
    if [ $? -eq 0 ]; then
        echo "✓ 从WordPress容器连接成功"
    else
        echo "✗ 从WordPress容器连接失败"
    fi
fi

# 启动所有容器
echo "启动所有容器..."
docker compose up -d

echo "=== 测试完成 ==="
echo "查看日志: docker-compose logs -f"
