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

CONFIG_FILE="/var/www/html/config/config.ini.php"

# Pre-seed config.ini.php if it doesn't exist yet.
# Without this file, the FrontController tries to connect to DB
# with empty credentials before the installation wizard can run.
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" <<EOF
; <?php exit; ?> DO NOT REMOVE THIS LINE
; file automatically generated or modified by Xtrusio; you can manually override the default values in global.ini.php by redefining them in this file.
[database]
host = "${MYSQL_HOST:-xtrusio-db}"
username = "${MYSQL_USER}"
password = "${MYSQL_PASSWORD}"
dbname = "${MYSQL_DATABASE}"
tables_prefix = "${MYSQL_TABLE_PREFIX:-xtrusio_}"
charset = "utf8mb4"

[General]
installation_in_progress = 1
EOF
    chown www-data:www-data "$CONFIG_FILE"
    chmod 664 "$CONFIG_FILE"
    echo "[entrypoint] Pre-seeded config.ini.php for installation"
fi

# Inject Redis cache config if missing
if ! grep -q "\[Cache\]" "$CONFIG_FILE"; then
    cat >> "$CONFIG_FILE" <<EOF

[Cache]
backend = chained
backends[] = array_cache
backends[] = redis

[RedisCache]
host = "${REDIS_HOST:-redis}"
port = "${REDIS_PORT:-6379}"
timeout = 0.0
database = 0
EOF
    echo "[entrypoint] Injected Redis cache config"
fi

# ── Production hardening ─────────────────────────────────────────────
# Inject/update trusted_hosts, force_ssl, and reverse-proxy headers
# based on environment variables. Safe to re-run on every container start.

if [ -n "${XTRUSIO_TRUSTED_HOSTS}" ]; then
    # Remove any existing trusted_hosts[] lines then append fresh ones
    sed -i '/^trusted_hosts\[\]/d' "$CONFIG_FILE"
    IFS=',' read -ra HOSTS <<< "${XTRUSIO_TRUSTED_HOSTS}"
    for host in "${HOSTS[@]}"; do
        host_trimmed=$(echo "$host" | xargs)
        # Append under [General] — add [General] if not present
        if ! grep -q "^\[General\]" "$CONFIG_FILE"; then
            echo -e "\n[General]" >> "$CONFIG_FILE"
        fi
        # Append right after [General] header
        sed -i "/^\[General\]/a trusted_hosts[] = \"${host_trimmed}\"" "$CONFIG_FILE"
    done
    echo "[entrypoint] Set trusted_hosts: ${XTRUSIO_TRUSTED_HOSTS}"
fi

if [ "${XTRUSIO_FORCE_SSL}" = "1" ]; then
    if ! grep -q "^force_ssl" "$CONFIG_FILE"; then
        sed -i "/^\[General\]/a force_ssl = 1\nassume_secure_protocol = 1" "$CONFIG_FILE"
        echo "[entrypoint] Enabled force_ssl"
    fi
fi

if [ "${XTRUSIO_BEHIND_PROXY}" = "1" ]; then
    if ! grep -q "^proxy_client_headers" "$CONFIG_FILE"; then
        sed -i "/^\[General\]/a proxy_client_headers[] = \"HTTP_X_FORWARDED_FOR\"\nproxy_host_headers[] = \"HTTP_X_FORWARDED_HOST\"" "$CONFIG_FILE"
        echo "[entrypoint] Enabled reverse-proxy header trust"
    fi
fi

exec "$@"
