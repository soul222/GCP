# ─── Stage 1: Build aset frontend ────────────────────────────────────────────
FROM node:20-alpine AS frontend-builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --prefer-offline

COPY resources/ resources/
COPY vite.config.js ./
COPY postcss.config.js* ./
COPY tailwind.config.js* ./
COPY public/ public/
RUN npm run build

# ─── Stage 2: Production PHP + Nginx ─────────────────────────────────────────
FROM php:8.2-fpm-alpine AS production

RUN apk add --no-cache \
    nginx supervisor curl zip unzip git \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    libzip-dev oniguruma-dev mysql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo pdo_mysql gd zip bcmath mbstring opcache pcntl

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy source code Laravel
COPY . .

# Copy hasil build frontend dari stage 1
COPY --from=frontend-builder /app/public/build public/build

# Install PHP dependencies (production only)
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# Copy konfigurasi server
COPY gcp-config/nginx.conf       /etc/nginx/nginx.conf
COPY gcp-config/supervisord.conf /etc/supervisord.conf
COPY gcp-config/php.ini          /usr/local/etc/php/conf.d/custom.ini
COPY gcp-config/start.sh         /start.sh
RUN chmod +x /start.sh

# Permission
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

ENV PORT=8080
EXPOSE 8080

CMD ["/start.sh"]
