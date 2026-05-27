---
name: testing-strategy
description: Define a project's testing strategy (unit/integration/E2E pyramid), coverage targets, CI gates, and stack-specific patterns. Use in Fase 4-5. Auto-invoke when user says "estrategia de testing", "qué tests", "coverage", "/testing-strategy".
---

# Testing Strategy

Skill para definir y enforcer la estrategia de testing de un proyecto. La filosofía: tests son inversión, no impuesto. Mal balanceados, son carga; bien balanceados, te dejan moverte rápido.

## Pirámide de tests (default del setup)

```
            ┌──────────────┐
            │   E2E (5%)   │   <- caros, lentos, frágiles. Solo flujos críticos.
            ├──────────────┤
            │ Integration  │   <- boundaries entre módulos. Medianos en cost.
            │    (20%)     │
            ├──────────────┤
            │   Unit       │   <- la mayoría. Rápidos, deterministas.
            │   (75%)      │
            └──────────────┘
```

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
- Funciones puras del dominio: tests directos con table-driven
- Services: mocks de repos vía interface
- Handlers: `httptest.NewRecorder` + `httptest.NewRequest`

```go
func TestComputeScore(t *testing.T) {
    cases := []struct {
        name    string
        input   *Productor
        want    float64
        wantErr error
    }{
        {name: "happy path", input: validProductor(), want: 0.75},
        {name: "missing data", input: incompleteProductor(), wantErr: ErrIncompleteData},
    }
    for _, tc := range cases {
        t.Run(tc.name, func(t *testing.T) { /* ... */ })
    }
}
```

**Integration tests (en `tests/integration/`)**:
- Postgres real (testcontainers o DB local de test)
- Migraciones aplicadas
- Tests del flujo completo handler → service → repo → DB
- Setup y teardown limpio entre tests

### Regla dura desde Sesión 6: testcontainers obligatorios para proyectos con DB

Para cualquier proyecto que use Postgres/MySQL/MariaDB, los integration tests con **testcontainers** son **obligatorios antes de cerrar Gate 5**.

**Por qué**: en splitwise-mini, la query real de balances (con JOINs y posibles N+1) nunca se probó hasta Gate 5 iter-2. Tests con mocks validan que el código hace lo que el dev cree — NO que la DB devuelve lo que se espera. Las queries complejas necesitan ejecutarse contra Postgres real, no mock.

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

**Unit tests (Vitest + RTL)**:
- Hooks personalizados
- Lib functions y utils
- Componentes en isolation (Storybook + tests interaction)

```typescript
test('useScoreBadge formats score correctly', () => {
  const { result } = renderHook(() => useScoreBadge(0.85))
  expect(result.current.label).toBe('High')
  expect(result.current.color).toBe('green')
})
```

**Integration tests**:
- Componentes con sus hooks reales contra MSW (mock service worker)
- Form flows: render → fill → submit → verify

**E2E (Playwright)**:
- Login flow
- Critical user journey (1-2 max para MVP)
- Run on CI contra staging deploy

### Mobile (React Native)

**Unit + integration (Jest + RNTL)**:
- Igual que frontend pero con RNTL en lugar de RTL
- Mock de native modules cuando aplica

**E2E (Detox o Maestro)**:
- Critical journey en iOS y Android
- Lento, correr solo en CI o pre-release

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

1. **Mockear lo que estás testeando**: si testeás `UserService.create()` mockeando `userRepo.save()`, no estás testeando `create`, estás testeando que llamás a `save`. Use integration tests.

2. **Tests que dependen de orden**: cada test debe ser independiente. Si dependen, hay estado compartido = bug futuro.

3. **Tests con sleeps fijos**: `time.Sleep(2s)` no es esperar, es rezar. Usar polling con timeout o waits explícitos.

4. **Snapshot testing sin revisión**: snapshots auto-aprobados son tests que no testean nada.

5. **Tests de implementación, no de comportamiento**: testear "el componente llama a tal función" en lugar de "el componente muestra X cuando hago Y" es fragilidad.

6. **Coverage como métrica única**: 100% coverage con tests débiles es peor que 70% con tests fuertes.

7. **Skipear tests "por ahora"**: si está skipeado, eliminar el test o arreglarlo. `xtest`/`skip` permanente es deuda.

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
