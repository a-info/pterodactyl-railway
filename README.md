# 🎮 Pterodactyl Panel & Wings - Railway Production Template

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template?template=https%3A%2F%2Fgithub.com%2Fa-info%2Fpterodactyl-railway)

Production-ready, one-click automated Pterodactyl Panel and Wings setup for **Railway Cloud** with **Cloudflare DNS & Proxy**.

---

## 🌐 Custom Domains Configuration

- **Panel URL**: `https://host.onlinevbs.dpdns.org`
- **Wings Node FQDN**: `node.onlinevbs.dpdns.org`
- **Root Zone**: `onlinevbs.dpdns.org`

---

## 🔑 Default Administrator Credentials

| Field | Configured Value |
| :--- | :--- |
| **Email** | `admin@gmail.com` |
| **Username** | `admin` |
| **Password** | `root` |
| **First Name** | `Admin` |
| **Last Name** | `Root` |

---

## 🚀 One-Click Deployment Guide on Railway

### 1. Deploy the Stack
1. Navigate to **[Railway.com/new](https://railway.com/new)**.
2. Select **"Deploy from GitHub repo"** and choose `a-info/pterodactyl-railway`.
3. Railway will automatically build the `Dockerfile` and link the MySQL/MariaDB and Redis services.

### 2. Configure Environment Variables in Railway
Under **Service Variables**:

| Variable | Recommended Value |
| :--- | :--- |
| `APP_URL` | `https://host.onlinevbs.dpdns.org` |
| `APP_ENV` | `production` |
| `DB_HOST` | `${{MySQL.MYSQLHOST}}` or `${{MariaDB.MARIADB_HOST}}` |
| `DB_PORT` | `3306` |
| `DB_DATABASE` | `panel` |
| `DB_USERNAME` | `${{MySQL.MYSQLUSER}}` or `pterodactyl` |
| `DB_PASSWORD` | `${{MySQL.MYSQLPASSWORD}}` |
| `REDIS_HOST` | `${{Redis.REDISHOST}}` |
| `REDIS_PORT` | `6379` |

### 3. Connect Custom Domain in Railway
1. In Railway, open the **Panel Service** ➔ **Settings** ➔ **Custom Domains**.
2. Add: `host.onlinevbs.dpdns.org`.
3. In Cloudflare, point `host` (CNAME) to your Railway-provided target with **Proxy Status = Proxied (Orange Cloud)**.

---

## 🦅 Wings Node Setup (`node.onlinevbs.dpdns.org`)

1. Login to the Panel at `https://host.onlinevbs.dpdns.org` with `admin` / `root`.
2. Click **Admin Settings (⚙️)** ➔ **Locations** ➔ **Create New** (`Local`).
3. Click **Nodes** ➔ **Create New**:
   - **Name**: `Node-1`
   - **FQDN**: `node.onlinevbs.dpdns.org`
   - **Communicate Over SSL**: `Use SSL Connection`
   - **Behind Proxy**: `Not Behind Proxy`
   - **Daemon Port**: `8080`
   - **Daemon SFTP Port**: `2022`
4. Click **Configuration** tab and copy the generated YAML.
5. Paste it on your Wings host into `/etc/pterodactyl/config.yml` and run `wings` or `docker compose up -d wings`.

---

## 📁 Repository Structure

- `Dockerfile`: Automated Railway container build.
- `entrypoint.sh`: Auto migration and superadmin provisioner.
- `docker-compose.yml`: Full stack compose file for local / VPS setups.
- `railway.json`: Railway orchestration manifest.
- `railway.toml`: Deployment and restart lifecycle policy.
