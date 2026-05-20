#!/bin/sh
set -e

echo "==> Memulai startup script Cloud Run..."

# Ganti PORT default nginx jika Cloud Run memberikan port berbeda
PORT=${PORT:-8080}
sed -i "s/listen 8080;/listen ${PORT};/g" /etc/nginx/nginx.conf

echo "==> Skip migrasi (database diimport manual via Cloud SQL)"
# php artisan migrate --force  # Tidak dipakai - DB diimport dari file SQL

echo "==> Membuat storage symlink..."
php artisan storage:link || true

echo "==> Membersihkan dan mengoptimasi cache..."
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "==> Mengupgrade Filament..."
php artisan filament:upgrade || true

echo "==> Memperbaiki permission storage..."
chmod -R 775 /var/www/html/storage
chmod -R 775 /var/www/html/bootstrap/cache

echo "==> Memulai layanan Nginx + PHP-FPM..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
