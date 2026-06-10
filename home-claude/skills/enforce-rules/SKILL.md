---
name: enforce-rules
description: Generate or audit CI/git hooks that automatically enforce the hard rules from CLAUDE.md. Use when setting up a project's CI pipeline. Auto-invoke when user says "enforce reglas", "hooks de CI", "automatizar reglas", "/enforce-rules".
---

# Enforce Rules (CI / Git Hooks)

Skill para convertir las reglas duras del setup en checks automáticos. La filosofía: la regla que no se enforce, se va a olvidar.

## Reglas duras a enforcer

Las reglas del CLAUDE.md global que pueden enforcearse automáticamente:

| Regla | Mecanismo | Donde corre |
|---|---|---|
| Sin secrets en repo | gitleaks | CI + pre-commit |
| `.env` en .gitignore | grep check | CI + pre-commit |
| Coverage ≥85% en código de negocio | tooling de coverage | CI |
| Sin vulns HIGH+ en deps | `govulncheck` / `npm audit` | CI |
| Sin wildcards en gateway config | grep en archivos de gateway | CI |
| `docs/EXECUTION.md` existe | file existence | CI |
| ADRs para desvíos de stack default | manual review (no automatizable) | PR review |
| Tests para código nuevo | coverage delta | CI |
| `docs/context/STATE.md` actualizado | git diff against templates | manual / el Doc Sentinel |

## Procedimiento

### Paso 1: Identificar qué stack tiene el proyecto

Detectar:
- ¿Backend Go? → `go.mod` existe
- ¿Frontend Node? → `package.json` existe
- ¿Python? → `pyproject.toml` o `requirements.txt`
- ¿Mobile RN? → `app.config.ts` o `app.json` con Expo
- ¿Hay gateway config? → buscar `Caddyfile`, `krakend.json`, `traefik.yml`

### Paso 2: Generar workflows de CI

Por cada stack detectado, agregar jobs al workflow existente o crear uno nuevo.

Usar `resources/ci-workflow.yml` como base (leer el archivo de recurso cuando lo necesites). Contiene:
- Jobs de seguridad que aplican a TODOS los stacks: `secrets-scan` (gitleaks), `env-gitignore-check`, `gateway-no-wildcards`, `docs-required`.
- Jobs por stack condicionados con `hashFiles()`: Go (lint, test+coverage, govulncheck), Node (lint, typecheck, test+coverage, audit), Python (lint, test, pip-audit).

Adaptar al copiarlo:
- Los working directories (`backend/`, `frontend/`) al layout real del repo.
- Las condiciones `hashFiles()` a donde realmente viven `go.mod` / `package.json` / `pyproject.toml`.
- Eliminar los jobs de stacks que el proyecto no tiene.
- El check de coverage Go viene como warning; cambiarlo a `exit 1` para hacerlo bloqueante cuando el proyecto pase Fase 5.

### Paso 3: Generar pre-commit hooks (opcional pero recomendado)

Hooks locales para detectar problemas antes del push:

- Usar `resources/pre-commit-config.yaml` como base para `.pre-commit-config.yaml` (gitleaks + checks genéricos + golangci-lint + ruff). Quitar las secciones de stacks que no apliquen.
- Usar `resources/pre-push-gateway-check.sh` como hook custom de pre-push que detecta wildcards en configs de gateway. Ajustar los patrones de grep y el path `gateway/` al gateway real del proyecto.

### Paso 4: Verificar que existen

En CI mismo, verificar que las reglas del proyecto están enforced:
- ¿El workflow incluye gitleaks?
- ¿El workflow falla con vulns HIGH+?
- ¿El workflow chequea coverage?

## Output esperado

Archivos a producir / actualizar:
- `.github/workflows/ci.yml` con jobs apropiados al stack
- `.pre-commit-config.yaml` (si el equipo usa pre-commit)
- `.gitleaks.toml` con configuración custom si necesario
- Documentación en `docs/EXECUTION.md` sobre cómo correr los checks localmente

## Cómo el Doc Sentinel verifica que las reglas están enforced

En `/docs-audit`, el Doc Sentinel puede chequear:
- ¿Existe `.github/workflows/ci.yml`?
- ¿Tiene los jobs esperados (secrets-scan, deps audit, coverage)?
- ¿Está actualizado al stack actual del proyecto?

Si falta enforcement de una regla dura, el Doc Sentinel levanta finding.
