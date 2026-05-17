# Deploy to VPS

## 1. Prerequisites
- Ubuntu 22.04+ VPS with Docker Engine and Docker Compose plugin.
- Domain name pointing to the VPS.
- Open ports: `22`, `80`, `443`.

## 2. Server bootstrap
```bash
sudo apt update
sudo apt install -y ca-certificates curl git
```

Install Docker (official convenience script):
```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
```

Re-login to apply Docker group membership.

## 3. Application setup
```bash
git clone <YOUR_REPOSITORY_URL> order-management-system
cd order-management-system
cp .env.example .env
```

Edit `.env` with production values:
- `RAILS_ENV=production`
- `RAILS_MASTER_KEY=<your master key>`
- `POSTGRES_PASSWORD=<strong password>`
- `REDIS_URL=redis://redis:6379/0`
- SMTP credentials (if configured)

## 4. Build and start services
```bash
docker compose -f docker-compose.yaml up -d --build
```

## 5. Database preparation
```bash
docker compose -f docker-compose.yaml exec web bin/rake db:prepare
```

## 6. Smoke checks
```bash
curl -f http://127.0.0.1:3000/up
docker compose ps
```

## 7. Upgrade procedure
```bash
git pull
docker compose -f docker-compose.yaml up -d --build
docker compose -f docker-compose.yaml exec web bin/rake db:migrate
```

## 8. Rollback
```bash
git checkout <previous-stable-commit>
docker compose -f docker-compose.yaml up -d --build
```
