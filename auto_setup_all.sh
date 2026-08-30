#!/bin/bash
set -e

echo "=========================================================="
echo "  Pterodactyl 100% Automated Setup for onlinevbs.dpdns.org"
echo "=========================================================="

# 1. Update and install dependencies
echo "[1/6] Installing Docker, Docker Compose, curl, and network tools..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release dnsutils

# Install official Docker
if ! command -v docker &> /dev/null; then
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

# Ensure docker service is running
service docker start || true

# 2. Write docker-compose.yml
echo "[2/6] Writing production Docker Compose configuration..."
cat << 'DOCKER_EOF' > /root/docker-compose.yml
version: '3.8'

networks:
  pterodactyl:
    driver: bridge

volumes:
  panel_data:
  panel_logs:
  db_data:

services:
  database:
    image: mariadb:10.11
    container_name: ptero_db
    restart: always
    command: --default-authentication-plugin=mysql_native_password
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_DATABASE: panel
      MYSQL_USER: pterodactyl
      MYSQL_PASSWORD: PteroSecretPass123!
      MYSQL_ROOT_PASSWORD: RootSecretPass123!
    networks:
      - pterodactyl

  cache:
    image: redis:alpine
    container_name: ptero_redis
    restart: always
    networks:
      - pterodactyl

  panel:
    image: ghcr.io/pterodactyl/panel:latest
    container_name: ptero_panel
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - panel_data:/app/var/
      - panel_logs:/app/storage/logs
    environment:
      APP_URL: "https://host.onlinevbs.dpdns.org"
      APP_ENV: "production"
      APP_ENVIRONMENT_ONLY: "false"
      APP_TIMEZONE: "UTC"
      DB_HOST: "database"
      DB_PORT: "3306"
      DB_DATABASE: "panel"
      DB_USERNAME: "pterodactyl"
      DB_PASSWORD: "PteroSecretPass123!"
      CACHE_DRIVER: "redis"
      SESSION_DRIVER: "redis"
      QUEUE_CONNECTION: "redis"
      REDIS_HOST: "cache"
      REDIS_PORT: "6379"
    depends_on:
      - database
      - cache
    networks:
      - pterodactyl
DOCKER_EOF

# 3. Pull images and launch stack
echo "[3/6] Starting Pterodactyl Panel, MariaDB & Redis..."
docker compose -f /root/docker-compose.yml up -d

# 4. Wait for MariaDB initialization
echo "[4/6] Waiting for database health check..."
for i in {1..30}; do
    if docker exec ptero_db mariadb-admin ping -h "127.0.0.1" -u "pterodactyl" --password="PteroSecretPass123!" --silent; then
        echo "[+] Database is ready."
        break
    fi
    echo "[*] Database starting, waiting 3s ($i/30)..."
    sleep 3
done

# 5. Initialize Laravel Panel & Migrations
echo "[5/6] Generating Laravel encryption key and running database migrations..."
docker exec ptero_panel php artisan key:generate --force
docker exec ptero_panel php artisan migrate --seed --force

# 6. Seed Administrator Account (admin:root)
echo "[6/6] Auto-provisioning Administrator (admin:root)..."
docker exec ptero_panel php artisan p:user:make \
  --email="admin@gmail.com" \
  --username="admin" \
  --name-first="Admin" \
  --name-last="User" \
  --password="root" \
  --admin=1 --no-interaction

echo "=========================================================="
echo " [SUCCESS] Pterodactyl All-in-One Configuration Finished!"
echo " Panel URL : https://host.onlinevbs.dpdns.org"
echo " Username  : admin"
echo " Password  : root"
echo " Wings FQDN: node.onlinevbs.dpdns.org"
echo "=========================================================="
