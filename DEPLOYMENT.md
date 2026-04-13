# Xtrusio Analytics — VPS Deployment Guide

## Prerequisites

- Ubuntu 22.04+ VPS (2 GB RAM min, 4 GB recommended)
- Docker + docker-compose installed
- A domain with DNS A record pointing to VPS IP
- Ports 80 and 443 open in firewall

## 1. System prep

```bash
# Install Docker (if not installed)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker

# Install Caddy (handles SSL automatically)
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy

# Firewall
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## 2. Deploy Xtrusio

```bash
sudo mkdir -p /opt/xtrusio && sudo chown $USER:$USER /opt/xtrusio
cd /opt/xtrusio
git clone <your-repo-url> .

# Generate strong passwords
ROOT_PW=$(openssl rand -base64 24)
DB_PW=$(openssl rand -base64 24)

cp .env.example .env
# Edit .env — set the 3 critical values:
#   MYSQL_ROOT_PASSWORD=$ROOT_PW
#   MYSQL_PASSWORD=$DB_PW
#   XTRUSIO_TRUSTED_HOSTS=analytics.yourdomain.com
#   XTRUSIO_FORCE_SSL=1
#   XTRUSIO_BEHIND_PROXY=1
nano .env

docker-compose up --build -d
docker-compose logs -f matomo   # watch for errors; Ctrl+C when ready
```

## 3. Set up reverse proxy (Caddy auto-handles SSL)

```bash
sudo cp Caddyfile.example /etc/caddy/Caddyfile
sudo nano /etc/caddy/Caddyfile   # change `analytics.yourdomain.com` to your real domain
sudo systemctl reload caddy
```

Open `https://analytics.yourdomain.com` → run installation wizard. Skip DB step creds — the wizard will use what's in `config.ini.php` (already seeded from `.env`).

## 4. Schedule the archiving cron

Without this, reports get slow. Add to root crontab (`sudo crontab -e`):

```cron
5 * * * * docker exec xtrusio-app php /var/www/html/console core:archive --url=https://analytics.yourdomain.com > /dev/null 2>&1
```

## 5. Schedule daily backups

```bash
chmod +x /opt/xtrusio/scripts/backup.sh
sudo crontab -e
# Add:
0 3 * * * /opt/xtrusio/scripts/backup.sh >> /var/log/xtrusio-backup.log 2>&1
```

Backups go to `/var/backups/xtrusio/` (14-day retention by default). Offsite copy recommended — `rsync` to S3/B2 or similar.

## 6. First-login checklist

1. Create admin account during install wizard.
2. Go to **Settings → General → Email server settings** and configure SMTP.
3. **Settings → Privacy** → review IP anonymization, cookie settings (GDPR).
4. **Settings → System → Update settings** → enable 2FA for admin user.
5. Delete the default `anonymous` user if not needed.

## Troubleshooting

**Site returns 502 Bad Gateway** → app container not running:
```bash
cd /opt/xtrusio && docker-compose ps
docker-compose logs matomo --tail=50
```

**Login redirects loop / cookies broken** → reverse-proxy headers not trusted. Verify in `.env`: `XTRUSIO_FORCE_SSL=1` and `XTRUSIO_BEHIND_PROXY=1`, then:
```bash
docker-compose restart matomo
```

**Diagnostics shows "Cron not set up"** → see step 4 above.

**Need to update code** → pull latest, then:
```bash
cd /opt/xtrusio && git pull && docker-compose up --build -d
```

## Post-deploy verification

```bash
# 1. All containers healthy?
docker-compose ps

# 2. Redis connected?
docker exec xtrusio-app php -r "(new Redis())->connect('redis',6379); echo 'OK';"

# 3. DB has tables?
docker exec xtrusio-db mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW TABLES;" $MYSQL_DATABASE | wc -l

# 4. HTTPS works?
curl -I https://analytics.yourdomain.com
```

All four should succeed. You're live.
