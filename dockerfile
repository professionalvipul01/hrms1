FROM php:8.2-apache

# Install system dependencies (including PostgreSQL dev libs)
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip libzip-dev libpq-dev \
    && docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd zip \
    && a2enmod rewrite \
    && apt-get clean

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy everything (including composer.json if it exists)
COPY . .

# If composer.json exists, install dependencies; otherwise skip
RUN if [ -f composer.json ]; then \
        composer install --no-interaction --no-dev --optimize-autoloader; \
    fi

# Set permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 755 storage bootstrap/cache

EXPOSE 80

CMD ["apache2-foreground"]
