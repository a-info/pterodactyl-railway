#!/bin/ash
set -e

echo "=========================================================="
echo " Starting Pterodactyl Panel on Railway Cloud"
echo " Custom Domain: https://host.onlinevbs.dpdns.org"
echo " Admin: admin@gmail.com / root"
echo "=========================================================="

# 1. Initialize embedded Redis
mkdir -p /var/run/redis /var/log/redis
redis-server --daemonize yes --bind 127.0.0.1 --protected-mode no

# 2. Initialize embedded MariaDB
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[+] Initializing new MariaDB database files..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

echo "[+] Starting MariaDB service..."
mysqld --user=mysql --datadir=/var/lib/mysql &
MYSQL_PID=$!

# Wait for MariaDB to respond
echo "[+] Waiting for MariaDB socket to be ready..."
until mariadb-admin ping --silent; do
    sleep 1
done

# Provision user & database if not exists
mariadb -u root << 'SQL_EOF'
CREATE DATABASE IF NOT EXISTS panel;
CREATE USER IF NOT EXISTS 'pterodactyl'@'%' IDENTIFIED BY 'PteroSecretPass123!';
CREATE USER IF NOT EXISTS 'pterodactyl'@'localhost' IDENTIFIED BY 'PteroSecretPass123!';
GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'%';
GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'localhost';
FLUSH PRIVILEGES;
SQL_EOF

cd /app

# 3. Setup storage directories & encryption key
mkdir -p /app/storage/logs /app/storage/framework/sessions /app/storage/framework/views /app/storage/framework/cache
chmod -R 775 /app/storage /app/bootstrap/cache

if [ -z "$APP_KEY" ]; then
    echo "[+] Generating APP_KEY..."
    php artisan key:generate --force --no-interaction
fi

# 4. Run Laravel migrations
echo "[+] Running database migrations & seeds..."
php artisan migrate --seed --force --no-interaction || true

# 5. Create Superadmin User
echo "[+] Seeding admin account (admin@gmail.com / root)..."
php artisan p:user:make \
    --email="admin@gmail.com" \
    --username="admin" \
    --name-first="Admin" \
    --name-last="Root" \
    --password="root" \
    --admin=1 \
    --no-interaction || true

echo "=========================================================="
echo " Pterodactyl Panel initialized successfully on Railway!"
echo " URL     : https://host.onlinevbs.dpdns.org"
echo " User    : admin"
echo " Email   : admin@gmail.com"
echo " Pass    : root"
echo "=========================================================="

# 6. Launch web & queue workers
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
