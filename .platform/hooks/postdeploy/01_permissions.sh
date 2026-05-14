#!/bin/bash
chmod -R 775 /var/app/current/storage
chmod -R 775 /var/app/current/bootstrap/cache
chown -R webapp:webapp /var/app/current/storage
chown -R webapp:webapp /var/app/current/bootstrap/cache
cd /var/app/current
php artisan optimize:clear
php artisan view:clear
php artisan config:clear
php artisan optimize

