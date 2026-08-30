#!/bin/ash
set -e

echo "=========================================================="
echo " Starting Pterodactyl Panel on Railway Cloud"
echo " Custom Domain: https://host.onlinevbs.dpdns.org"
echo " Admin: admin@gmail.com / root"
echo "=========================================================="

cd /app

# Ensure storage directories exist and have proper permissions
mkdir -p /app/storage/logs /app/storage/framework/sessions /app/storage/framework/views /app/storage/framework/cache
chmod -R 775 /app/storage /app/bootstrap/cache

# If APP_KEY is empty, generate one
if [ -z "$APP_KEY" ]; then
    echo "[+] Generating APP_KEY..."
    php artisan key:generate --force --no-interaction
fi

# Wait for database if specified
if [ -n "$DB_HOST" ]; then
    echo "[+] Waiting for Database ($DB_HOST:$DB_PORT)..."
    until nc -z -v -w30 "$DB_HOST" "${DB_PORT:-3306}"; do
        echo "Waiting for database connection..."
        sleep 2
    done
    echo "[+] Database is reachable!"
fi

# Run migrations and seed database
echo "[+] Running database migrations..."
php artisan migrate --seed --force --no-interaction || true

# Automatically create admin account if not already created
echo "[+] Seeding default Superadmin account..."
php artisan p:user:make \
    --email="admin@gmail.com" \
    --username="admin" \
    --name-first="Admin" \
    --name-last="Root" \
    --password="root" \
    --admin=1 \
    --no-interaction || true

# Execute default Pterodactyl entrypoint
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
