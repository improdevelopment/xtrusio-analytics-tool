#!/bin/bash
# Xtrusio Analytics — daily backup script
# Add to VPS crontab:  0 3 * * * /opt/xtrusio/scripts/backup.sh

set -e

BACKUP_DIR="${BACKUP_DIR:-/var/backups/xtrusio}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Load .env so we know DB creds
if [ -f "$(dirname "$0")/../.env" ]; then
    set -a; source "$(dirname "$0")/../.env"; set +a
fi

# 1. MySQL dump (gzipped)
echo "[backup] Dumping database..."
docker exec xtrusio-db mysqldump \
    -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
    --single-transaction --quick --lock-tables=false \
    "${MYSQL_DATABASE}" | gzip > "$BACKUP_DIR/db_${TIMESTAMP}.sql.gz"

# 2. Config dir (small, contains salt + custom settings)
echo "[backup] Archiving config..."
tar czf "$BACKUP_DIR/config_${TIMESTAMP}.tar.gz" \
    -C "$(dirname "$0")/.." config/

# 3. Prune old backups
echo "[backup] Pruning backups older than ${RETENTION_DAYS} days..."
find "$BACKUP_DIR" -name "db_*.sql.gz" -mtime +${RETENTION_DAYS} -delete
find "$BACKUP_DIR" -name "config_*.tar.gz" -mtime +${RETENTION_DAYS} -delete

echo "[backup] Done: $BACKUP_DIR"
ls -lh "$BACKUP_DIR" | tail -5
