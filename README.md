# Xtrusio Analytics

White-labeled web analytics platform. Self-hosted, privacy-focused, built on Matomo.

## Requirements

- [Docker](https://www.docker.com/products/docker-desktop/)
- [Docker Compose](https://docs.docker.com/compose/)

## Quick Start

```bash
# 1. Clone the repo
git clone <repo-url>
cd xtrusio-analytics-tool

# 2. Create your environment file
cp .env.example .env

# 3. Edit .env with your credentials
#    (change passwords before deploying to production!)

# 4. Start the application
docker-compose up --build
```

Open **http://localhost:8080** and complete the 8-step installation wizard.

The database credentials are pre-configured from your `.env` file — the Database Setup step will be pre-filled automatically.

## Database Setup Credentials

On step 3 of the installer, use the values from your `.env` file:

| Field | `.env` Variable | Default in `.env.example` |
|-------|----------------|--------------------------|
| Database Server | _(always)_ | `xtrusio-db` |
| Login | `MYSQL_USER` | `xtrusio_user` |
| Password | `MYSQL_PASSWORD` | _(set in your .env)_ |
| Database Name | `MYSQL_DATABASE` | `xtrusio` |
| Table Prefix | _(keep default)_ | `matomo_` |

These are the same credentials you set in `.env` during setup.

## Clean Reinstall

Reset everything (deletes all data and database):

```bash
docker-compose down -v
docker-compose up --build
```

## First-Time Install Notes

- If you see a **"tables already exist"** warning on step 4, click **"Delete the detected tables"** — this means a previous install left data in the database. Use `docker-compose down -v` to avoid this.
- After install completes, `config/config.ini.php` is auto-generated with your database credentials and salt — **do not commit this file** (it's already in `.gitignore`).

## Updating

```bash
git pull
docker-compose up --build
```

## Adding the Tracking Code

After setup, add this to your website's `<head>` tag:

```html
<!-- Xtrusio -->
<script>
  var _paq = window._paq = window._paq || [];
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var u="//YOUR-XTRUSIO-URL/";
    _paq.push(['setTrackerUrl', u+'matomo.php']);
    _paq.push(['setSiteId', 'YOUR-SITE-ID']);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.async=true; g.src=u+'xtrusio.js'; s.parentNode.insertBefore(g,s);
  })();
</script>
<!-- End Xtrusio -->
```

Replace `YOUR-XTRUSIO-URL` and `YOUR-SITE-ID` with your actual values from the setup wizard.

## Useful Commands

```bash
docker-compose up -d          # Start in background
docker-compose down            # Stop
docker-compose restart         # Restart
docker logs xtrusio-app        # View app logs
docker logs xtrusio-db         # View DB logs
docker-compose down -v         # Stop + delete all data
```

## Customizing Logos

| File | Purpose | Recommended size |
|------|---------|-----------------|
| `plugins/Morpheus/images/logo.svg` | Main logo | Vector |
| `plugins/Morpheus/images/logo.png` | Main logo (fallback) | 300x60px |
| `plugins/Morpheus/images/logo-header.png` | Navbar logo | 150x30px |
| `plugins/CoreHome/images/favicon.ico` | Browser tab icon | 32x32px |

## Folder Structure

```
├── config/              # Configuration (auto-generated, gitignored)
├── core/                # Core PHP framework
├── plugins/             # All plugins (UI, features, themes)
├── docker-compose.yml   # Docker services
├── Dockerfile           # PHP + Apache image
├── docker-entrypoint.sh # Container startup script
├── .env.example         # Environment template (copy to .env)
└── .gitignore           # Ignored files
```

## License

GPL v3 or later — see [LICENSE](LICENSE) for details.
