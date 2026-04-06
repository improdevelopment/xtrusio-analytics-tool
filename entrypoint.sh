#!/bin/bash
# Fix permissions for config and tmp directories
chown -R www-data:www-data /var/www/html/config /var/www/html/tmp 2>/dev/null
mkdir -p /var/www/html/tmp
chown -R www-data:www-data /var/www/html/tmp

# Start Apache
exec apache2-foreground
