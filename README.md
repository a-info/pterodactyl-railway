# Pterodactyl Panel & Wings One-Click Template

## 1. Cloudflare DNS Configuration
In your Cloudflare DNS table for `onlinevbs.dpdns.org`:

| Type | Name | Target | Proxy Status |
| :--- | :--- | :--- | :--- |
| `CNAME` | `host` | `<your-railway-panel-service>.up.railway.app` | 🟠 Proxied |
| `CNAME` | `node` | `<your-wings-public-ip-or-host>` | ⚪ DNS Only |

---

## 2. Deploy to Railway
1. Push this repository to GitHub.
2. Open [Railway.app](https://railway.app) and select **New Project** ➔ **Deploy from GitHub repo**.
3. Railway automatically loads `docker-compose.yml` with MariaDB, Redis, and Pterodactyl Panel.
4. Under Panel **Settings** ➔ **Custom Domain**, add `host.onlinevbs.dpdns.org`.

---

## 3. Pre-Configured Credentials
- **URL**: `https://host.onlinevbs.dpdns.org`
- **Username**: `admin`
- **Password**: `root`
- **Admin Email**: `admin@gmail.com`
