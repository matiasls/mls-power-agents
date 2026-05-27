---
name: execution-runbook
description: Generate or audit the EXECUTION.md document that covers running the system in local, staging, and production. Use in Fase 4 (DevOps setup) and at any phase gate where execution clarity matters. Auto-invoke when user says "cómo ejecuto", "cómo levanto el sistema", "cómo deployo", "EXECUTION.md", "/how-to-run".
---

# Execution Runbook

Este skill es la respuesta a otra de las preguntas más repetidas del usuario: "¿cómo ejecuto el sistema?". Garantiza que todo proyecto tiene un `docs/EXECUTION.md` que cubre local + staging + prod con comandos exactos.

## Cuándo usar

- Al crear scaffolding de nuevo proyecto (Fase 4).
- En Gate 4: verificación obligatoria de que `EXECUTION.md` está completo.
- Cuando el usuario pide entender cómo arrancar algo.
- Cuando un colaborador nuevo se suma al proyecto.

## Reglas duras

1. **Todo proyecto DEBE tener `docs/EXECUTION.md`** desde Fase 4.
2. **Tres secciones OBLIGATORIAS**: Local Development, Staging, Production.
3. **Cada sección con comandos exactos**, no descripciones vagas.
4. **Local debe arrancar con UN comando** (ej: `make dev` o `docker compose up`).
5. **Production debe incluir rollback** explícito.
6. **Si una sección no aplica** (ej: no hay staging todavía), declararlo explícito: "Staging: no configurado aún. Se agregará en versión X."

## Template completo de `docs/EXECUTION.md`

```markdown
# Execution Guide

> Cómo ejecutar este sistema en cada entorno.
> Si encontrás un comando que no funciona o un paso que falta, agregarlo acá.

## Overview

[Diagrama o lista breve de los componentes que se ejecutan]

Components:
- Frontend web (React) → puerto 3000
- Backend API (Go) → puerto 8080
- Background worker → no expone puerto
- PostgreSQL → puerto 5432
- Gateway (Caddy) → puerto 443 / 80

---

## Local Development

### Prerequisites

- macOS 13+ or Linux
- Docker Desktop 4.20+ (or compatible)
- Make
- Go 1.22+ (for backend work outside Docker)
- Node 20+ (for frontend work outside Docker)
- Direnv (optional, for auto-loading .env)

### First-time setup

\`\`\`bash
# 1. Clone
git clone <repo-url>
cd <project>

# 2. Copy env template
cp .env.example .env
# Edit .env with local values (DB password, etc.)

# 3. One-command setup
make setup
\`\`\`

`make setup` runs: docker pull, db migrations, seeds, builds.

### Daily development

\`\`\`bash
# Start everything
make dev

# Open in browser
open http://localhost:3000

# Run tests
make test

# Run linter
make lint

# Tear down
make down
\`\`\`

### Available commands

| Command | What it does |
|---|---|
| `make dev` | Start all services (docker compose up) |
| `make test` | Run all tests (backend + frontend) |
| `make test-backend` | Backend tests only |
| `make test-frontend` | Frontend tests only |
| `make lint` | Run linters |
| `make migrate-up` | Apply pending DB migrations |
| `make migrate-down` | Rollback last migration |
| `make seed` | Load seed data |
| `make logs` | Tail logs of all services |
| `make logs-api` | Tail logs of API only |
| `make psql` | Open psql session against local DB |
| `make down` | Stop all services |
| `make clean` | Stop and remove volumes (destructive) |

### Service URLs (local)

| Service | URL |
|---|---|
| Frontend | http://localhost:3000 |
| API | http://localhost:8080 |
| Gateway | http://localhost:8443 (self-signed cert) |
| Adminer (DB UI) | http://localhost:8081 (dev only) |
| Mailhog (email capture) | http://localhost:8025 (dev only) |

### Common troubleshooting

**Port already in use**
\`\`\`bash
# Find what's using the port
lsof -i :8080
# Kill it
kill <pid>
\`\`\`

**DB connection refused after restart**
\`\`\`bash
make clean && make setup
\`\`\`

**Frontend can't reach API**
- Check `VITE_API_URL` in `.env`
- Should be `http://localhost:8080` for local

---

## Staging Environment

### Where it runs

- **Provider**: Railway
- **URL**: https://staging.tudominio.com
- **Region**: us-east-1

### Access

- Frontend (public): https://staging.tudominio.com
- API (public via gateway): https://api-staging.tudominio.com
- DB: not exposed publicly, access via `railway run psql`
- Admin panel: https://admin-staging.tudominio.com (basic auth)

### How to deploy

**Automatic**: every merge to `develop` branch triggers a deploy via Railway GitHub integration.

**Manual** (if needed):
\`\`\`bash
railway up --environment staging
\`\`\`

### How to view logs

\`\`\`bash
railway logs --environment staging --service api
\`\`\`

Or via Railway dashboard.

### How to access DB

\`\`\`bash
railway run psql --environment staging
\`\`\`

### How to seed/reset staging

\`\`\`bash
railway run --environment staging make seed
\`\`\`

### Smoke tests after deploy

\`\`\`bash
curl https://api-staging.tudominio.com/health
curl https://api-staging.tudominio.com/api/v1/version
\`\`\`

---

## Production Environment

### Where it runs

- **Provider**: [Railway / AWS / GCP — completar]
- **URL**: https://tudominio.com
- **Region**: [completar]
- **DNS**: gestionado por [Cloudflare / Route53 — completar]

### Access

- Frontend: https://tudominio.com
- API (via gateway): https://api.tudominio.com
- DB: NO accesible publicamente. Acceso solo vía bastion / Railway shell con MFA.
- Admin panel: https://admin.tudominio.com (con SSO + IP allowlist)

### Pre-deploy checklist

- [ ] Tests verdes en CI
- [ ] CHANGELOG.md actualizado con versión
- [ ] Tag creado: `git tag vX.Y.Z`
- [ ] DB migrations revisadas (zero downtime?)
- [ ] Plan de rollback claro
- [ ] On-call notificado

### How to deploy

**Procedimiento estándar**:

\`\`\`bash
# 1. Asegurar estás en main y al día
git checkout main && git pull

# 2. Crear tag de la nueva versión
git tag vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z

# 3. Deploy
railway up --environment production
# o el comando equivalente según provider
\`\`\`

**Tiempos esperados**: deploy completo ~5-7 min.

### How to verify post-deploy

\`\`\`bash
# Health checks
curl https://api.tudominio.com/health
curl https://api.tudominio.com/api/v1/version  # Should return vX.Y.Z

# Smoke test del flujo crítico
[lista de comandos o pasos]
\`\`\`

### How to rollback

**Si el rollback es URGENTE** (sistema down):

\`\`\`bash
# Roll back via Railway dashboard al deploy anterior
# o
railway redeploy <previous-deploy-id> --environment production
\`\`\`

**Si requiere DB rollback**: ver `docs/runbooks/db-rollback.md`.

### Where to see logs

| Tipo | Dónde |
|---|---|
| Application logs | Railway dashboard / Better Stack / Datadog |
| Access logs (gateway) | Railway dashboard |
| Error tracking | Sentry: https://sentry.io/<org>/<project> |
| Metrics | Datadog / Grafana: <URL> |
| Database slow queries | RDS Performance Insights / pganalyze |

### On-call runbook

Ver `docs/runbooks/oncall.md` para procedimientos de respuesta a incidentes.

### Common operations

- **Restart a service**: ver `docs/runbooks/restart-service.md`
- **Apply a hotfix**: ver `docs/runbooks/hotfix.md`
- **Scale up**: ver `docs/runbooks/scale.md`
- **Rotate secrets**: ver `docs/runbooks/secret-rotation.md`
- **Backup/restore**: ver `docs/runbooks/backup-restore.md`

### Maintenance windows

[Cuándo se hacen mantenimientos planeados, cómo se comunican]

---

## Environment Variables Reference

Las variables están listadas en `.env.example` con descripciones. Las críticas:

| Variable | Local | Staging | Production | Notas |
|---|---|---|---|---|
| `DATABASE_URL` | local docker | Railway | Railway | Nunca commitear |
| `JWT_SECRET` | dev value | Railway secrets | Railway secrets | Rotar cada 90 días |
| `NOSIS_API_KEY` | sandbox | Nosis dev | Nosis prod | Pass-through al cliente |
| ... | | | | |

---

## Disaster Recovery

### Backup policy

- **DB**: Railway PITR (Point-in-Time Recovery), retención 7 días
- **Object storage (si aplica)**: versioning habilitado
- **Configuration**: en repo Git + secrets en Railway/provider

### RTO / RPO objetivos

- RTO (Recovery Time Objective): X horas
- RPO (Recovery Point Objective): X minutos

### Procedure if total loss

Ver `docs/runbooks/disaster-recovery.md`.
```

## Procedure de auditoría

Al ejecutar audit en gate 4 o gate 6:

1. **Existe `docs/EXECUTION.md`?** Si no → bloqueante.
2. **Tiene las 3 secciones (Local, Staging, Production)?** Si falta una → bloqueante (a menos que esté explícitamente marcado como "no aplica todavía").
3. **El comando de start local realmente funciona?** Ejecutar (si es posible) o pedir al usuario que confirme.
4. **`.env.example` está sincronizado con el código?** Detectar uso de envs en código que no estén en `.env.example`.
5. **Hay sección de rollback en Production?** Si no → bloqueante en Gate 4.

## Mantenimiento del documento

- **el Doc Sentinel (doc-sentinel)** verifica este archivo en cada gate.
- Cualquier cambio en cómo se ejecuta debe actualizar este archivo en el mismo PR.
- **Si un nuevo dev no puede arrancar el sistema siguiendo este doc, el doc es bug.**
