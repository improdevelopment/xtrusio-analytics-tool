#!/bin/bash
set -e

# Ensure writable directories exist
mkdir -p /var/www/html/tmp/assets \
         /var/www/html/tmp/cache \
         /var/www/html/tmp/logs \
         /var/www/html/tmp/tcpdf \
         /var/www/html/tmp/templates_c \
         /var/www/html/tmp/sessions

chown -R www-data:www-data /var/www/html/config /var/www/html/tmp /var/www/html/misc
chmod -R 775 /var/www/html/config /var/www/html/tmp /var/www/html/misc

# Pre-seed config.ini.php if it doesn't exist yet.
# Without this file, the FrontController tries to connect to DB
# with empty credentials before the installation wizard can run.
CONFIG_FILE="/var/www/html/config/config.ini.php"
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" <<EOF
; <?php exit; ?> DO NOT REMOVE THIS LINE
; file automatically generated or modified by Xtrusio; you can manually override the default values in global.ini.php by redefining them in this file.
[database]
host = "${MYSQL_HOST:-matomo-db}"
username = "${MYSQL_USER}"
password = "${MYSQL_PASSWORD}"
dbname = "${MYSQL_DATABASE}"
tables_prefix = "matomo_"
charset = "utf8mb4"

[General]
installation_in_progress = 1
EOF
    chown www-data:www-data "$CONFIG_FILE"
    chmod 664 "$CONFIG_FILE"
    echo "[entrypoint] Pre-seeded config.ini.php for installation"
fi

exec "$@"
