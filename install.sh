#!/bin/bash
set -e

echo "[+] Starting Pterodactyl One-Click Automated Setup..."

# 1. Start containers
docker compose -f /root/docker-compose.yml up -d

# 2. Wait for database readiness
echo "[+] Waiting for MariaDB service..."
until docker exec ptero_db mariadb-admin ping -h "127.0.0.1" -u "pterodactyl" --password="PteroSecretPass123!" --silent; do
    echo "[*] Database initializing, waiting 3s..."
    sleep 3
done

# 3. Panel environment generation and migrations
echo "[+] Generating encryption key and running migrations..."
docker exec ptero_panel php artisan key:generate --force
docker exec ptero_panel php artisan migrate --seed --force

# 4. Create admin user non-interactively
echo "[+] Provisioning user: admin / password: root..."
docker exec ptero_panel php artisan p:user:make \
  --email="admin@gmail.com" \
  --username="admin" \
  --name-first="Admin" \
  --name-last="User" \
  --password="root" \
  --admin=1 --no-interaction

echo "=========================================================="
echo " [SUCCESS] Pterodactyl Installation Complete!"
echo " Panel URL : https://host.onlinevbs.dpdns.org"
echo " Username  : admin"
echo " Password  : root"
echo " Wings FQDN: node.onlinevbs.dpdns.org"
echo "=========================================================="
