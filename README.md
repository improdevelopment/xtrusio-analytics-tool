# Xtrusio Analytics

White-labeled analytics platform built on Matomo, customized with Xtrusio branding.

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/) installed
- [Docker Compose](https://docs.docker.com/compose/) installed
- Git installed

## Installation

### 1. Clone the repository

```bash
git clone <repo-url>
cd matomo-wihte-labling
```

### 2. Start the application

```bash
docker-compose up -d --build
```

This will start two containers:
- **imapro-analytics** — Xtrusio web app (PHP + Apache)
- **imapro-analytics-db** — MariaDB database

### 3. Open in browser

```
http://localhost:8080
```

### 4. Complete the setup wizard

You will see the Xtrusio installation wizard. Follow these steps:

1. **Welcome** — Click Next
2. **System Check** — Click Next
3. **Database Setup** — Enter:
   - Database Server: `matomo-db`
   - Login: `matomo`
   - Password: `imapro_matomo_2024`
   - Database Name: `matomo`
   - Table Prefix: `matomo_`
4. **Creating the Tables** — Wait for completion
5. **Superuser** — Create your admin account (username + password)
6. **Set up a Website** — Add your website name and URL
7. **JavaScript Tracking Code** — Copy the tracking code and add it to your website
8. **Congratulations** — Done!

### 5. Login

After setup, login with the superuser credentials you created in step 5.

## Adding the tracking code

After setup, you will get a JavaScript tracking code. Add it to your website's `<head>` tag:

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
    g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
  })();
</script>
<!-- End Xtrusio Code -->
```

Replace `YOUR-XTRUSIO-URL` and `YOUR-SITE-ID` with your actual values from the setup.

## Managing users

1. Go to **Settings** (gear icon) > **System** > **Users**
2. Click **Add new user**
3. Set username, email, and password
4. Assign permissions:
   - **View** — Can only view reports
   - **Write** — Can view reports + create goals/segments
   - **Admin** — Can manage website settings
   - **Super User** — Full system access

## Useful commands

```bash
# Start the application
docker-compose up -d

# Stop the application
docker-compose down

# Restart the application
docker-compose restart

# View logs
docker logs imapro-analytics
docker logs imapro-analytics-db

# Reset everything (deletes all data)
docker-compose down -v
docker-compose up -d --build
```

## Folder structure

```
├── config/              # Configuration files
├── core/                # Core PHP framework
├── plugins/             # All plugins (UI, features, themes)
│   ├── Morpheus/        # Theme (logos, styles)
│   │   └── images/      # Logo files (replace for custom branding)
│   ├── CoreHome/        # Main UI templates
│   └── Login/           # Login page
├── docker-compose.yml   # Docker setup
├── Dockerfile           # PHP + Apache container
└── .gitignore           # Ignored files
```

## Customizing logos

Replace these files with your own logos:

| File | Purpose | Recommended size |
|------|---------|-----------------|
| `plugins/Morpheus/images/logo.svg` | Main logo | Vector |
| `plugins/Morpheus/images/logo.png` | Main logo (fallback) | 300x60px |
| `plugins/Morpheus/images/logo-header.png` | Navbar logo | 150x30px |
| `plugins/CoreHome/images/favicon.ico` | Browser tab icon | 32x32px |

## License

GPL v3 or later — see [LICENSE](LICENSE) for details.
