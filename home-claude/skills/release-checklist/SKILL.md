---
name: release-checklist
description: Execute a structured release checklist before deploying to production. Use when the Release Manager prepares a release. Auto-invoke when user says "release", "deploy a prod", "publicar versión", "/release-check".
---

# Release Checklist

Procedimiento canónico de release que el Release Manager aplica. La filosofía: el release ideal es aburrido y reversible. Se invoca cuando el equipo decide hacer un release a producción; NO debe ejecutarse "para probar".

## Pre-requisito: Smoke test manual del founder

**Antes de iniciar la Fase 1 de este checklist**, debe existir `docs/runbooks/smoke-test.md` con checklist firmable por el founder. Sin este checklist firmado, **Gate 6 no abre**. Tests automáticos validan que el código hace lo que el dev cree; el smoke test manual valida que el sistema funciona desde la perspectiva del usuario real.

### Estructura del `docs/runbooks/smoke-test.md`

```markdown
# Smoke Test — Pre-release vX.Y.Z

**Ejecutado por**: <nombre del founder>
**Fecha**: YYYY-MM-DD
**Stack levantado**: `docker-compose up` o equivalente

## Checklist firmable

Para cada UC crítico del MVP, ejecutar manualmente y firmar:

- [ ] UC-NNN: <descripción del flujo>
  - [ ] Setup / Ejecución: <pasos>
  - [ ] Resultado esperado vs real: <pegar evidencia>
  - **Firmado**: __________

## Issues encontrados
[Si hay diferencias entre esperado y real]

## Veredicto final
- [ ] APROBADO para release
- [ ] BLOQUEAR release (motivos: ____)

**Firmado**: __________ Fecha: __________
```

## Inputs requeridos

- Versión target (SemVer: `vX.Y.Z`)
- Tipo de release: MAJOR / MINOR / PATCH / HOTFIX
- Lista de cambios incluidos (de CHANGELOG `[Unreleased]`)

## Procedimiento (en orden)

### Fase 1: Pre-deploy validation (1-2 horas antes)

#### Code & Tests
- [ ] All target features merged to `main`
- [ ] CI green on `main` (todos los jobs)
- [ ] Coverage ≥85% on changed modules (verificar con tooling)
- [ ] No commits sin tests asociados (revisión manual o lint hook)
- [ ] No `TODO`/`FIXME` críticos sin issue asociado en código nuevo

#### Security
- [ ] el Security Architect aprobó: no hay CRITICAL ni HIGH abiertos
- [ ] `gitleaks` corrió y limpio
- [ ] `govulncheck` / `npm audit` sin vulns HIGH+
- [ ] Si toca auth/permissions: review extra del Security Architect

#### Docs
- [ ] CHANGELOG.md actualizado con esta versión (mover `[Unreleased]` → `[X.Y.Z]`)
- [ ] README actualizado si hay user-facing changes
- [ ] `docs/EXECUTION.md` actualizado si cambian comandos o procedimientos
- [ ] OpenAPI specs regenerados si cambian APIs
- [ ] ADRs creados para decisiones de esta versión
- [ ] el Doc Sentinel aprobó (vía `/docs-audit`)

#### Data & Migrations
- [ ] DB migrations revisadas para zero-downtime
- [ ] Migrations testeadas en staging idénticamente
- [ ] Si hay migrations destructivas: plan especial documentado
- [ ] Backup pre-deploy verificado (puede restaurar = SI, no "existe")

#### Infrastructure
- [ ] Capacidad / quotas revisadas: ¿el deploy va a saturar algo?
- [ ] Healthchecks funcionando en staging
- [ ] Smoke tests de staging pasaron
- [ ] Provider status page sin incidents activos

#### Communication
- [ ] On-call notificado y disponible
- [ ] Release notes drafted (customer-facing si aplica + internas)
- [ ] Horario: NO viernes tarde, NO víspera de feriado, NO durante peak traffic conocido

### Fase 2: Rollback plan (filled BEFORE deploy)

Esta sección DEBE existir y estar firmada antes del deploy. Sin esto, NO se deploya.

```markdown
## Rollback plan vX.Y.Z

### Trigger conditions
Rollback automático si dentro de 30 min del deploy:
- Error rate >Y% (baseline: ___%)
- p99 latency >Yms (baseline: ___ms)
- Healthchecks failing >2 min consecutivos
- Alerts CRITICAL del monitoring

### Procedure
1. Stop traffic at gateway: <comando exacto>
2. Rollback deployment: <comando exacto>
3. Rollback DB migration (si aplica): <comando exacto>
4. Verify rollback: <comando exacto>
5. Restore traffic

### Communications during rollback
- Slack: #incidents
- Status page: update if user-facing
- Post-mortem: agendado en 48hs

### Owner
<persona on-call durante el deploy>
```

### Fase 3: Deploy execution

- [ ] Tag firmado creado: `git tag -s vX.Y.Z -m "Release vX.Y.Z"`
- [ ] Tag pushed: `git push origin vX.Y.Z`
- [ ] Pipeline de deploy iniciado
- [ ] Deploy monitoreado en tiempo real por el DevOps & Platform agent o equivalente

### Fase 4: Post-deploy verification (primeros 30 min)

- [ ] Health endpoint OK y version endpoint devuelve `vX.Y.Z`
- [ ] Smoke test de flujo crítico ejecutado y pasó
- [ ] Logs muestran no error spike
- [ ] Métricas: error rate dentro de baseline ±10%; p99 dentro de baseline ±20%
- [ ] Sentry / error tracker: no new error patterns
- [ ] DB connection pool no saturado; memory / CPU no anómalos

### Fase 5: Cierre del release

- [ ] Release notes publicadas (si aplica) y stakeholders notificados
- [ ] Issue tracker actualizado: features marked as released
- [ ] CHANGELOG.md committed con la versión publicada
- [ ] Próximo `[Unreleased]` section iniciada

### Fase 6: Monitoreo extendido (24-72 hs)

- [ ] Métricas revisadas a 24hs: comparar con baseline previo
- [ ] Sentry revisado: errors nuevos analizados
- [ ] Feedback de usuarios (si aplica): canal de soporte revisado
- [ ] Si hay anomalías: decidir hotfix vs aceptar y agendar fix

## Reglas duras

1. **Sin rollback plan, no hay deploy a prod**. Cualquier excepción se documenta y firma el CTO.
2. **Sin CHANGELOG, no hay release**. Aunque sea PATCH, el changelog se actualiza.
3. **Sin tests verdes, no hay tag**. CI rojo + intención de deploy = STOP.
4. **Sin on-call disponible, no hay deploy**. Periodos sin on-call: maintenance only.
5. **Sin staging testing, no hay deploy**. Salvo hotfix urgente firmado.

## Para HOTFIX urgente

**Sí se pueden saltar (documentando deuda)**: CHANGELOG en el mismo PR (puede esperar 24hs), smoke tests de staging completos (puede ser parcial), release notes públicas.

**No se pueden saltar**: tests del cambio específico, rollback plan, security review del cambio, on-call notificado, backup verificado.

Después de un hotfix, post-mortem obligatorio en 7 días.

## Output

Archivo `docs/releases/vX.Y.Z-checklist.md` con la lista completada y firmada.
