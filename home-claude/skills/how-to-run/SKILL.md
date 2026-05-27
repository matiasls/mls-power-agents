---
name: how-to-run
description: Generate or update the docs/EXECUTION.md document with full instructions for running local, staging, and production. Use in Fase 4 (DevOps setup) or when the document drifts. Auto-invoke when user says "cómo ejecuto", "cómo se levanta el sistema", "/how-to-run", "actualizar EXECUTION".
---

# How To Run

Asegura que el proyecto tiene un `docs/EXECUTION.md` completo y actualizado.

## Procedimiento

### Paso 1: Verificar existencia

```bash
ls docs/EXECUTION.md
```

- Si no existe: crear desde el template del skill `execution-runbook`.
- Si existe: leer y validar completitud.

### Paso 2: Recolectar info del proyecto

Leer:
- `package.json`, `go.mod`, `Cargo.toml`, etc. (qué runtime y deps)
- `Makefile` (qué comandos hay)
- `docker-compose.yml` (qué services)
- `.env.example` (qué env vars necesita)
- `docs/context/03-architecture.md` (módulos y servicios)
- `docs/context/04-infra.md` (si existe, dónde corre staging/prod)

### Paso 3: Aplicar el skill `execution-runbook`

Ejecutar el template completo del skill `execution-runbook`. El doc resultante debe tener:

1. **Overview**: qué componentes corren
2. **Local Development**: prereqs, setup, comandos
3. **Staging**: dónde, cómo deploy, cómo acceder, cómo ver logs
4. **Production**: dónde, cómo deploy, rollback, observabilidad
5. **Env vars reference**: tabla con local/staging/prod
6. **Disaster recovery**: backup policy, RTO/RPO

### Paso 4: Validar comandos

Si es posible (en entorno seguro):
- Probar `make dev` o el comando equivalente
- Verificar que los URLs locales responden
- Marcar pasos que fallan o quedan poco claros

### Paso 5: Generar Makefile estándar si falta

Si el proyecto no tiene `Makefile`, ofrecer crearlo:

```makefile
.PHONY: setup dev test lint down clean help

help:
	@echo "Available commands:"
	@echo "  make setup   - First-time setup"
	@echo "  make dev     - Start all services for local development"
	@echo "  make test    - Run all tests"
	@echo "  make lint    - Run linters"
	@echo "  make down    - Stop all services"
	@echo "  make clean   - Stop and remove volumes (destructive)"

setup: ## First-time setup
	cp -n .env.example .env || true
	docker compose pull
	docker compose build
	@echo "Setup complete. Run 'make dev' to start."

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

clean: ## Stop and remove volumes
	docker compose down -v
```

### Paso 6: Generar `.env.example` si falta

Si no existe, generar uno basándose en uso de envs en código:

```bash
# Backend
DATABASE_URL=postgres://user:pass@localhost:5432/dbname
JWT_SECRET=replace-with-random-256-bit
API_PORT=8080

# Frontend
VITE_API_URL=http://localhost:8080

# External services
NOSIS_API_KEY=
SENTRY_DSN=
```

### Paso 7: Output al usuario

```markdown
# EXECUTION.md actualizado

## Cambios
- ✅ Sección Local Development: completa
- ⚠️ Sección Staging: no aplica todavía (declarado)
- ⚠️ Sección Production: incompleta — falta info de provider y URL de prod
- ✅ Makefile creado

## Lo que falta del usuario
- [ ] Definir provider de prod (Railway/AWS/GCP)
- [ ] Configurar URL de prod
- [ ] Crear runbook de rollback en `docs/runbooks/rollback.md`
```

## Reglas duras

- **`docs/EXECUTION.md` con secciones Local + Staging + Prod desde Fase 4**.
- **Si una sección no aplica, declararlo explícito**: "Staging: no configurado aún. Pendiente en Fase X."
- **Local debe arrancar con 1 comando**.
- **Production debe incluir rollback** explícito.
- **`.env.example` siempre presente**, `.env` siempre en `.gitignore`.
