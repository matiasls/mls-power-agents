---
name: release-checklist
description: Execute a structured release checklist before deploying to production. Use when the Release Manager prepares a release. Auto-invoke when user says "release", "deploy a prod", "publicar versión", "/release-check".
---

# Release Checklist

Procedimiento canónico de release que el Release Manager aplica. La filosofía: el release ideal es aburrido y reversible.

## Trigger del skill

Cuando el equipo decide hacer un release a producción, el Release Manager invoca este skill. NO debe ejecutarse "para probar".

## Pre-requisito desde Sesión 6: Smoke test manual del founder

**Antes de iniciar la Fase 1 de este checklist**, debe existir `docs/runbooks/smoke-test.md` con checklist firmable por el founder. Sin este checklist firmado, **Gate 6 no abre**.

Por qué: tests automáticos validan que el código hace lo que el dev cree. Smoke test manual valida que **el sistema funciona** desde la perspectiva del usuario real — irremplazable.

### Estructura del `docs/runbooks/smoke-test.md`

```markdown
# Smoke Test — Pre-release vX.Y.Z

**Ejecutado por**: <nombre del founder>
**Fecha**: YYYY-MM-DD
**Stack levantado**: `docker-compose up` o equivalente

## Checklist firmable

Para cada UC crítico del MVP, ejecutar manualmente y firmar:

- [ ] UC-001: <descripción del flujo>
  - [ ] Setup: <pasos previos>
  - [ ] Ejecución: <pasos>
  - [ ] Resultado esperado: <output>
  - [ ] Resultado real: <pegar evidencia>
  - **Firmado**: __________

- [ ] UC-002: ...

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
- [ ] Customer-facing release notes drafted (si user-facing)
- [ ] Internal release notes drafted (Slack/email)
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

- [ ] Health endpoint OK
- [ ] Version endpoint devuelve `vX.Y.Z`
- [ ] Smoke test de flujo crítico ejecutado y pasó
- [ ] Logs muestran no error spike
- [ ] Métricas: error rate dentro de baseline ±10%
- [ ] Métricas: p99 dentro de baseline ±20%
- [ ] Sentry / error tracker: no new error patterns
- [ ] DB connection pool no saturado
- [ ] Memory / CPU no anómalos

### Fase 5: Cierre del release

- [ ] Release notes publicadas (si applica)
- [ ] Stakeholders notificados
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

Algunos checks pueden saltarse, otros no:

**Sí se pueden saltar (documentando deuda)**:
- CHANGELOG actualizado en mismo PR (puede esperar 24hs)
- Smoke tests de staging completos (puede ser parcial)
- Release notes públicas

**No se pueden saltar**:
- Tests del cambio específico
- Rollback plan
- Security review del cambio
- On-call notificado
- Backup verificado

Después de un hotfix, post-mortem obligatorio en 7 días.

## Output

Archivo `docs/releases/vX.Y.Z-checklist.md` con la lista completada y firmada.
