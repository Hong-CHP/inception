#!/bin/bash

echo "=== Inception Project Test ==="

# 进入srcs目录
cd srcs

# 构建
echo "2. Building containers..."
docker compose build --no-cache

# 只启动mariadb
echo "3. Starting MariaDB..."
docker compose up -d mariadb

# 等待
echo "4. Waiting for MariaDB to initialize..."
sleep 40

# 测试连接
echo "5. Testing database connections..."
echo "Testing root connection..."
if docker compose exec mariadb mysql -u root -p"$(cat ../secrets/db_root_password.txt)" -e "SELECT 1;" 2>/dev/null; then
    echo "✓ Root connection successful"
else
    echo "✗ Root connection failed"
fi

echo "Testing wp_user connection..."
if docker compose exec mariadb mysql -u wp_user -p"$(cat ../secrets/db_password.txt)" -e "SELECT 1;" 2>/dev/null; then
    echo "✓ wp_user connection successful"
else
    echo "✗ wp_user connection failed"
fi

# 启动所有服务
echo "6. Starting all services..."
docker compose up -d

# 等待并检查
echo "7. Waiting for services to start..."
sleep 20

echo "8. Checking container status..."
docker compose ps

echo "9. Checking logs..."
docker compose logs --tail=30

echo "=== Test Complete ==="
EOF

chmod +x test_inception.sh
./test_inception.sh
