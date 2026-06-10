---
name: testing-strategy
description: Define a project's testing strategy (unit/integration/E2E pyramid), coverage targets, CI gates, and stack-specific patterns. Use in Fase 4-5. Auto-invoke when user says "estrategia de testing", "qué tests", "coverage", "/testing-strategy".
---

# Testing Strategy

Skill para definir y enforcer la estrategia de testing de un proyecto. La filosofía: tests son inversión, no impuesto. Mal balanceados, son carga; bien balanceados, te dejan moverte rápido.

## Distribución de la pirámide (default del setup)

- **Unit: 75%** — la mayoría. Rápidos, deterministas.
- **Integration: 20%** — boundaries entre módulos.
- **E2E: 5%** — caros, lentos, frágiles. Solo flujos críticos.

## Coverage targets

| Capa | Target | Justificación |
|---|---|---|
| Domain logic | ≥90% | El corazón del negocio. No negociable. |
| Services / use cases | ≥85% | La lógica de aplicación. |
| Handlers / controllers | ≥70% | Más auxiliar; tests integration cubren mucho. |
| Persistence (repos) | Integration tests | No unit tests con mocks de DB que mienten. |
| UI components | ≥60% | Comportamiento, no estilos. |
| Utilities / lib | ≥85% | Reusables, deben funcionar siempre. |
| **Total código de negocio** | **≥85%** | Default del setup. |

**Lo que NO cuenta para coverage**:
- Generated code (sqlc, protobuf, etc.)
- Boilerplate wiring (main.go, module.go)
- Constants y simple DTOs sin lógica
- Tests mismos

## Tipos de tests por stack

### Backend (Go)

**Unit tests (`*_test.go` junto al archivo testeado)**:
- Table-driven tests como default (regla de CLAUDE.md)
- Funciones puras del dominio: tests directos
- Services: mocks de repos vía interface
- Handlers: `httptest.NewRecorder` + `httptest.NewRequest`

**Integration tests (en `tests/integration/`)**:
- Postgres real (testcontainers o DB local de test)
- Migraciones aplicadas
- Tests del flujo completo handler → service → repo → DB
- Setup y teardown limpio entre tests

### Regla dura: testcontainers obligatorios para proyectos con DB

Para cualquier proyecto que use Postgres/MySQL/MariaDB, los integration tests con **testcontainers** son **obligatorios antes de cerrar Gate 5**. Tests con mocks validan que el código hace lo que el dev cree — NO que la DB devuelve lo que se espera. Las queries complejas necesitan ejecutarse contra la DB real.

**Verificación en Gate 5**:
- [ ] `tests/integration/` existe y tiene tests con testcontainers
- [ ] Las queries críticas (JOINs, agregaciones, filtros complejos) tienen test integration
- [ ] CI ejecuta los integration tests (no solo unit)
- [ ] Cobertura de queries críticas ≥80%

Sin esto, Gate 5 no cierra para proyectos con DB. Es regla dura.

**E2E (en `tests/e2e/`)**:
- HTTP cliente contra el servicio levantado
- Solo flujos críticos del usuario
- Idealmente ejecutados en CI contra el binary final

### Frontend (React)

**Unit tests (Vitest + RTL)**: hooks personalizados, lib functions y utils, componentes en isolation (Storybook + tests interaction).

**Integration tests**: componentes con sus hooks reales contra MSW; form flows: render → fill → submit → verify.

**E2E (Playwright)**: login flow + critical user journey (1-2 max para MVP), corridos en CI contra staging deploy.

### Mobile (React Native)

**Unit + integration (Jest + RNTL)**: igual que frontend pero con RNTL; mock de native modules cuando aplica.

**E2E (Detox o Maestro)**: critical journey en iOS y Android. Lento, correr solo en CI o pre-release.

## CI gates

El CI debe enforcer estos checks. Sin ellos, los targets son aspiracionales:

```yaml
# Pseudocódigo del pipeline
on_pr:
  - lint                    # block on warnings
  - unit_tests              # block on failures
  - coverage_check          # block if <85% on changed files
  - integration_tests       # block on failures
  - e2e_smoke               # block on failures
  - security_scan           # block on CRITICAL/HIGH
```

## Anti-patterns a rechazar

1. **Mockear lo que estás testeando**: mockear `userRepo.save()` para testear `UserService.create()` solo testea que llamás a `save`. Usar integration tests.
2. **Tests que dependen de orden**: estado compartido = bug futuro.
3. **Tests con sleeps fijos**: usar polling con timeout o waits explícitos.
4. **Snapshot testing sin revisión**: snapshots auto-aprobados no testean nada.
5. **Tests de implementación, no de comportamiento**: fragilidad.
6. **Coverage como métrica única**: 100% con tests débiles es peor que 70% con tests fuertes.
7. **Skipear tests "por ahora"**: `skip` permanente es deuda. Eliminar o arreglar.

## Output esperado

`docs/context/04-testing-strategy.md`:

```markdown
# 04 — Testing Strategy

## Pyramid distribution
- Unit: 75% (target)
- Integration: 20%
- E2E: 5%

## Coverage targets
| Capa | Target | Tooling |
|---|---|---|
| Domain | 90% | Go test |
| ... | | |

## CI gates
[Definidos en .github/workflows/ci.yml — ver el DevOps & Platform agent]

## Critical flows for E2E
1. Signup → onboarding → first action
2. ...

## Test data strategy
- Fixtures en `tests/fixtures/`
- Factory pattern para datos de test
- Seed data deterministic

## Mocks vs real dependencies
- DB: real (testcontainers)
- External APIs: MSW / wiremock
- Time: inyectable (Clock interface)
- Random: inyectable (seed fijo en tests)
```

## Para cada PR / change

Coordinarse con el Backend Developer/el Frontend Developer/el Mobile Developer:
- Tests escritos para código nuevo
- Coverage del módulo modificado no baja
- Si baja, justificar o rechazar PR

Coordinarse con el Security Architect:
- Tests específicos de seguridad para changes sensibles (auth, queries, uploads)
