# Execution Guide

> How to run this system in every environment.
> If you find a command that doesn't work or a step that's missing, add it here.

## Overview

Components in this system:
- **Frontend** (React) → port 3000
- **API** (Go) → port 8080
- **Database** (PostgreSQL) → port 5432
- **Gateway** (Caddy, optional locally) → ports 8443/8080

---

## Local Development

### Prerequisites

- macOS 13+ or Linux
- Docker Desktop 4.20+ (or compatible)
- Make
- Go 1.22+ (only for running backend outside Docker)
- Node 20+ (only for running frontend outside Docker)

### First-time setup

```bash
git clone <repo-url>
cd <project>
make setup
```

`make setup` copies `.env.example` → `.env`, pulls Docker images, builds containers.

After setup, edit `.env` if needed (defaults work for local).

### Daily development

```bash
make dev          # start everything
# In another terminal:
open http://localhost:3000
```

### Available commands

Run `make help` for the full list. Most common:

| Command | What it does |
|---|---|
| `make dev` | Start all services |
| `make test` | Run all tests |
| `make lint` | Run linters |
| `make migrate-up` | Apply DB migrations |
| `make psql` | Open psql session |
| `make logs` | Tail all logs |
| `make down` | Stop services |
| `make clean` | Stop + remove volumes (DESTRUCTIVE) |

### Service URLs (local)

| Service | URL | Notes |
|---|---|---|
| Frontend | http://localhost:3000 | Vite dev server with HMR |
| API | http://localhost:8080 | Direct (no gateway in local by default) |
| Adminer | http://localhost:8081 | DB UI — run `docker compose --profile dev-tools up -d` to enable |
| Mailhog | http://localhost:8025 | Email capture — same profile |

### Optional: run with gateway locally

To mirror production setup:

```bash
docker compose --profile with-gateway up
# Access via: https://localhost:8443 (self-signed cert; accept in browser)
```

### Troubleshooting

**Port already in use**
```bash
lsof -i :8080
kill <pid>
```

**DB connection refused after restart**
```bash
make clean && make setup && make dev
```

**Frontend can't reach API**
- Check `VITE_API_URL` in `.env`
- Should be `http://localhost:8080` for local

**Migration error "already exists"**
- DB state mismatch. Try `make clean && make setup && make migrate-up`.

---

## Staging Environment

> ⚠️ **STATUS**: [Not yet configured | Configured]
>
> If not configured: this section will be filled when staging is set up in Fase 4.

### Where it runs

- **Provider**: TBD
- **URL**: TBD
- **Region**: TBD

### How to access

[TBD]

### How to deploy

[TBD]

### How to view logs

[TBD]

### How to reset/seed staging

[TBD]

### Smoke tests after deploy

```bash
curl https://<staging-url>/health
```

---

## Production Environment

> ⚠️ **STATUS**: [Not yet configured | Configured]

### Where it runs

- **Provider**: TBD
- **URL**: TBD
- **Region**: TBD
- **DNS**: TBD

### Access

- Frontend (public): TBD
- API (via gateway): TBD
- DB: NOT exposed publicly. Access via [provider shell / bastion / SSH tunnel — TBD]
- Admin: [URL with SSO + IP allowlist — TBD]

### Pre-deploy checklist

- [ ] CI green on `main`
- [ ] CHANGELOG.md updated with version
- [ ] Tag created: `git tag vX.Y.Z`
- [ ] DB migrations reviewed for zero-downtime compatibility
- [ ] Rollback plan documented for this change
- [ ] On-call notified (if applicable)

### How to deploy

```bash
# 1. Up to date on main
git checkout main && git pull

# 2. Tag
git tag vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z

# 3. Deploy
# TBD: command specific to provider
```

**Expected duration**: ~5-7 min for full deploy.

### Post-deploy verification

```bash
# Health checks
curl https://<prod-api>/health
curl https://<prod-api>/api/v1/version  # Should return vX.Y.Z
```

### How to rollback

**If urgent (system down)**:

```bash
# TBD: rollback command for chosen provider
```

**If DB migration needs rollback**: see `docs/runbooks/db-rollback.md`.

### Where to find logs

| What | Where |
|---|---|
| Application logs | TBD |
| Gateway access logs | TBD |
| Error tracking | TBD |
| Metrics dashboard | TBD |
| DB slow queries | TBD |

### On-call

See [docs/runbooks/oncall.md](runbooks/oncall.md).

---

## Environment Variables Reference

Critical variables (see `.env.example` for full list):

| Variable | Local | Staging | Production | Notes |
|---|---|---|---|---|
| `DATABASE_URL` | docker compose | provider | provider | Never commit |
| `JWT_SECRET` | random dev value | provider secrets | provider secrets | Rotate every 90 days |
| `LOG_LEVEL` | debug | info | warn | |

---

## Disaster Recovery

### Backup policy

- **Database**: TBD (PITR retention, frequency)
- **Object storage** (if applicable): TBD
- **Configuration**: in Git + secrets in provider's secret manager

### RTO / RPO

- **RTO** (Recovery Time Objective): TBD
- **RPO** (Recovery Point Objective): TBD

### Procedure for total loss

See [docs/runbooks/disaster-recovery.md](runbooks/disaster-recovery.md).
