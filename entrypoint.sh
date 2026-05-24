#!/bin/bash
set -e

# Wait for database to be ready
if [ ! -z "$DB_HOST" ]; then
    echo "Waiting for database connection..."
    wait-for-it ${DB_HOST}:${DB_PORT:-3306} -t 60
    echo "Database is ready!"
fi

# Run database migrations
if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "Running database migrations..."
    php artisan migrate --force
fi

# Run database seeders (optional)
if [ "$RUN_SEEDERS" = "true" ]; then
    echo "Running database seeders..."
    php artisan db:seed --force
fi

# Clear and cache configurations
echo "Caching configurations..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set proper permissions
chown -R www-data:www-data /var/www/html/storage
chown -R www-data:www-data /var/www/html/bootstrap/cache

# Start Apache
exec apache2-foreground