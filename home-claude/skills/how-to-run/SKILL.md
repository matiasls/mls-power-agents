---
name: how-to-run
description: Generate or audit docs/EXECUTION.md covering how to run the system in local, staging, and production with exact commands. Use in Fase 4 (DevOps setup), at any phase gate where execution clarity matters, or when the document drifts. Auto-invoke when user says "cómo ejecuto", "cómo levanto el sistema", "cómo deployo", "EXECUTION.md", "actualizar EXECUTION", "/how-to-run".
---

# How To Run (Execution Runbook)

Garantiza que todo proyecto tiene un `docs/EXECUTION.md` que cubre local + staging + prod con comandos exactos. Es la respuesta permanente a "¿cómo ejecuto el sistema?".

## Reglas duras

1. **Todo proyecto DEBE tener `docs/EXECUTION.md`** desde Fase 4. Bloqueante en Gate 4.
2. **Tres secciones OBLIGATORIAS**: Local Development, Staging, Production.
3. **Cada sección con comandos exactos**, no descripciones vagas.
4. **Local debe arrancar con UN comando** (ej: `make dev`).
5. **Production debe incluir rollback explícito**.
6. **Si una sección no aplica**, declararlo explícito: "Staging: no configurado aún. Pendiente en Fase X."
7. **`.env.example` siempre presente**, `.env` siempre en `.gitignore`.

## Procedimiento

### Paso 1: Verificar existencia

- Si `docs/EXECUTION.md` no existe: crear desde el template de abajo.
- Si existe: leer y validar completitud contra la auditoría del final.

### Paso 2: Recolectar info del proyecto

Leer: `package.json` / `go.mod` (runtime y deps), `Makefile` (comandos), `docker-compose.yml` (services), `.env.example` (env vars), `docs/context/03-architecture.md` (módulos), `docs/context/04-infra.md` (dónde corre staging/prod).

### Paso 3: Generar/actualizar con el template

Usar el template completo de abajo, adaptado al proyecto real (no dejar placeholders sin marcar como `[completar]`).

### Paso 4: Validar comandos

Si es posible (en entorno seguro): probar `make dev` o equivalente, verificar que las URLs locales responden, marcar pasos que fallan o quedan poco claros.

### Paso 5: Generar Makefile estándar si falta

```makefile
.PHONY: setup dev test lint down clean help

help:
	@echo "make setup | dev | test | lint | down | clean"

setup: ## First-time setup
	cp -n .env.example .env || true
	docker compose pull && docker compose build

dev: ## Start local environment
	docker compose up

test: ## Run all tests
	docker compose run --rm api go test ./...
	docker compose run --rm frontend npm test

lint: ## Run linters
	docker compose run --rm api golangci-lint run ./...
	docker compose run --rm frontend npm run lint

down: ## Stop all services
	docker compose down

clean: ## Stop and remove volumes (destructive)
	docker compose down -v
```

### Paso 6: Generar `.env.example` si falta

Basarse en el uso de env vars en el código. Toda variable usada en código debe estar en `.env.example` con valor de ejemplo o vacío.

### Paso 7: Output al usuario

Reportar por sección: ✅ completa / ⚠️ incompleta (qué falta) / declarada como "no aplica". Listar lo que falta del usuario (provider de prod, URLs, runbooks pendientes).

## Template de `docs/EXECUTION.md`

```markdown
# Execution Guide

> Cómo ejecutar este sistema en cada entorno.
> Si encontrás un comando que no funciona o un paso que falta, agregarlo acá.

## Overview

Components:
- Frontend web (React) → puerto 3000
- Backend API (Go) → puerto 8080
- PostgreSQL → puerto 5432
- Gateway (Caddy) → puerto 443 / 80

---

## Local Development

### Prerequisites

- Docker Desktop (o compatible), Make
- Go / Node según stack (para trabajar fuera de Docker)

### First-time setup

\`\`\`bash
git clone <repo-url> && cd <project>
cp .env.example .env   # editar valores locales
make setup
\`\`\`

### Daily development

| Command | What it does |
|---|---|
| `make dev` | Start all services |
| `make test` | Run all tests |
| `make lint` | Run linters |
| `make migrate-up` / `migrate-down` | Apply / rollback DB migrations |
| `make seed` | Load seed data |
| `make logs` | Tail logs |
| `make psql` | psql session against local DB |
| `make down` / `make clean` | Stop / stop+remove volumes |

### Service URLs (local)

| Service | URL |
|---|---|
| Frontend | http://localhost:3000 |
| API | http://localhost:8080 |
| Gateway | http://localhost:8443 |

### Troubleshooting

- **Port in use**: `lsof -i :8080` → `kill <pid>`
- **DB connection refused tras restart**: `make clean && make setup`
- **Frontend no llega a la API**: revisar `VITE_API_URL` en `.env`

---

## Staging Environment

- **Provider**: [Railway / completar] — **URL**: https://staging.[dominio]
- **DB**: no expuesta públicamente, acceso vía `railway run psql`

### Deploy

Automático: cada merge a `develop` deploya vía integración GitHub.
Manual: `railway up --environment staging`

### Logs y DB

\`\`\`bash
railway logs --environment staging --service api
railway run psql --environment staging
\`\`\`

### Smoke tests post-deploy

\`\`\`bash
curl https://api-staging.[dominio]/health
curl https://api-staging.[dominio]/api/v1/version
\`\`\`

---

## Production Environment

- **Provider**: [completar] — **URL**: https://[dominio] — **DNS**: [completar]
- **DB**: NO accesible públicamente. Solo vía bastion / shell del provider con MFA.
- **Admin panel**: con SSO + IP allowlist.

### Pre-deploy checklist

- [ ] Tests verdes en CI
- [ ] CHANGELOG.md actualizado con versión
- [ ] Tag creado: `git tag vX.Y.Z`
- [ ] DB migrations revisadas (¿zero downtime?)
- [ ] Plan de rollback claro

### Deploy

\`\`\`bash
git checkout main && git pull
git tag vX.Y.Z -m "Release vX.Y.Z" && git push origin vX.Y.Z
railway up --environment production   # o equivalente según provider
\`\`\`

### Verify post-deploy

\`\`\`bash
curl https://api.[dominio]/health
curl https://api.[dominio]/api/v1/version   # debe devolver vX.Y.Z
# + smoke test del flujo crítico
\`\`\`

### Rollback

\`\`\`bash
railway redeploy <previous-deploy-id> --environment production
\`\`\`

Si requiere DB rollback: ver `docs/runbooks/db-rollback.md`.

### Logs y operaciones

| Tipo | Dónde |
|---|---|
| Application / access logs | dashboard del provider |
| Error tracking | Sentry: <URL> |
| Metrics | <URL> |

Operaciones comunes (restart, hotfix, scale, rotación de secretos, backup/restore): ver `docs/runbooks/`.

---

## Environment Variables Reference

| Variable | Local | Staging | Production | Notas |
|---|---|---|---|---|
| `DATABASE_URL` | local docker | provider | provider | Nunca commitear |
| `JWT_SECRET` | dev value | secrets | secrets | Rotar cada 90 días |

---

## Disaster Recovery

- **Backup policy**: DB con PITR, retención [X] días. Config en Git + secrets en provider.
- **RTO / RPO objetivos**: [completar]
- **Total loss**: ver `docs/runbooks/disaster-recovery.md`.
```

## Procedimiento de auditoría (Gate 4 / Gate 6)

1. **¿Existe `docs/EXECUTION.md`?** Si no → bloqueante.
2. **¿Tiene las 3 secciones?** Falta una sin declaración explícita de "no aplica" → bloqueante.
3. **¿El comando de start local funciona?** Ejecutar si es posible, o pedir confirmación al usuario.
4. **¿`.env.example` sincronizado con el código?** Detectar envs usadas en código que falten.
5. **¿Hay rollback en Production?** Si no → bloqueante en Gate 4.

## Mantenimiento

- El Doc Sentinel verifica este archivo en cada gate.
- Cualquier cambio en cómo se ejecuta el sistema actualiza este archivo en el mismo PR.
- **Si un dev nuevo no puede arrancar el sistema siguiendo este doc, el doc es un bug.**
