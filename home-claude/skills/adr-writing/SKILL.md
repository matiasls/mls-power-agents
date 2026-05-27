---
name: adr-writing
description: Write or audit an Architecture Decision Record (ADR). Use when the Software Architect (or any agent) needs to capture a non-obvious technical decision, or to audit if existing ADRs follow the standard. Auto-invoke when user says "ADR", "decisión arquitectónica", "/adr", "documentar decisión".
---

# ADR Writing

Skill para producir Architecture Decision Records de calidad consistente. La filosofía: si dentro de 6 meses no recordás por qué tomaste una decisión, el ADR falló.

## Cuándo escribir un ADR

**Escribir ADR para:**
- Cualquier desvío del stack default del setup
- Decisión técnica con tradeoffs explícitos (no obvia)
- Decisión que un dev nuevo necesitaría entender el "por qué"
- Decisión que sospechás vas a revisitar
- Decisión con consecuencias a largo plazo

**NO escribir ADR para:**
- Convenciones de naming (van en CONTRIBUTING.md o style guides)
- Decisiones triviales ("usamos camelCase en variables")
- Decisiones que están en docs oficiales del framework

## Estructura obligatoria

Cada ADR debe estar en `docs/adr/NNNN-titulo-en-kebab-case.md` donde NNNN es un secuencial 4-digit zero-padded.

```markdown
# ADR-NNNN: <Título corto y descriptivo>

**Status**: Proposed | Accepted | Deprecated | Superseded by ADR-XXXX
**Date**: YYYY-MM-DD
**Deciders**: <nombres o agentes>
**Tags**: <tags relevantes para búsqueda: stack, security, performance, etc.>

## Context

[2-4 párrafos describiendo:]
- ¿Qué problema enfrentamos?
- ¿Qué restricciones aplican (técnicas, de negocio, de tiempo)?
- ¿Qué intentamos antes (si aplica)?
- ¿Por qué este momento es el correcto para decidir?

## Decision

[1-2 párrafos describiendo:]
- ¿Qué decidimos hacer?
- Acción concreta, no aspiracional.

Si la decisión es "vamos a usar X", explicitar la versión / variant.

## Rationale

[Por qué esta decisión es la mejor para nuestro contexto:]
- ¿Qué beneficios esperamos?
- ¿Qué tradeoffs aceptamos conscientemente?
- ¿Por qué supera a las alternativas?

## Alternatives Considered

Lista de al menos 2 alternativas serias. Para cada una:

### Alternativa A: <Nombre>
- **Descripción**: [breve]
- **Pros**: [bullets]
- **Cons**: [bullets]
- **Por qué descartada**: [razón concreta]

### Alternativa B: <Nombre>
- ...

## Consequences

### Positivas
- ...

### Negativas
- ...

### Riesgos
- ...

### Reversibilidad
- ¿Qué tan costoso es revertir? <Bajo / Medio / Alto>
- ¿Bajo qué circunstancias revisitaríamos esta decisión?

## Implementation Notes (opcional)

[Si la decisión requiere pasos concretos para implementar:]
- Cambios en código
- Migraciones de datos
- Updates de docs
- Training del equipo

## References

- Link a ADRs relacionados
- Link a issues / PRs
- Link a documentación externa relevante
```

## Reglas de calidad

1. **El status es honesto**: no marques Accepted hasta que se haya implementado o se vaya a implementar inmediatamente.
2. **El contexto es específico**: "necesitamos buena performance" no es contexto. "Necesitamos servir 1000 RPS con p95 < 100ms" sí.
3. **Las alternativas son reales**: si propusiste 3 alternativas pero 2 son strawmen, el ADR es débil. Buscá la versión más fuerte de cada alternativa.
4. **Las consecuencias son honestas**: incluí las negativas, no solo las positivas. Si todo es positivo, sospechá del análisis.
5. **Los ADRs son inmutables**: si la decisión cambia, NUEVO ADR que supersedes al anterior. NO editar el anterior.

## Cómo auditar ADRs existentes

Para `/docs-audit` o cuando el Doc Sentinel revisa:

- [ ] ¿Todos los archivos siguen el naming `NNNN-titulo.md`?
- [ ] ¿Los NNNN son secuenciales sin gaps?
- [ ] ¿Cada ADR tiene todas las secciones obligatorias?
- [ ] ¿Status es válido?
- [ ] ¿Hay decisiones tomadas en código que NO tienen ADR? (drift)
- [ ] ¿Hay ADRs con status "Proposed" hace >2 semanas? (resolver o eliminar)
- [ ] ¿Hay ADRs supersedidos sin marca de superseded by?

## Ejemplos de buenos ADRs

### ADR-0003: Use sqlc instead of GORM for database access

**Status**: Accepted  
**Date**: 2026-05-13

#### Context
The team needs a database access layer for the scoring module. We process ~500 reads/sec at peak with complex JOIN queries against the productors+scores tables. Compile-time type safety is critical because our domain model has 40+ fields and we cannot afford runtime type errors in production. Our team has strong SQL knowledge; nobody has deep GORM experience.

#### Decision
We will use sqlc with pgx as the driver for all database access in Go services. SQL queries live in `.sql` files; sqlc generates type-safe Go code.

#### Rationale
- Type safety at compile-time eliminates a class of bugs
- SQL is the lingua franca of the team; everyone reads it fluently
- pgx is the most performant Postgres driver for Go
- Generated code is auditable and explicit

#### Alternatives Considered

**GORM**: ORM with auto-migrations and good docs.
- Pros: Familiar pattern for devs from Rails/Django background
- Cons: Performance overhead, magic that hides SQL, weak type safety on complex queries
- Why rejected: Performance concerns and the team values SQL transparency

**database/sql + handwritten code**: stdlib only.
- Pros: Zero dependencies, full control
- Cons: Boilerplate, manual type assertions, error-prone for 40+ field structs
- Why rejected: sqlc gives 90% of the control with 10% of the boilerplate

#### Consequences

**Positive**:
- Type-safe queries at compile time
- SQL stays in dedicated files, easy to review
- Performance characteristic predictable

**Negative**:
- Adds sqlc to build tooling (one more thing to install)
- Generated code requires regeneration after schema changes (mitigated by Makefile target)

**Risks**:
- If sqlc maintenance falters, we have a dependency to migrate. Low likelihood (active project), low cost to migrate (queries are plain SQL).

**Reversibility**: Medium. The SQL queries are portable; only the generated code wrapper would need replacement.

#### References
- ADR-0001: Use Go for backend
- ADR-0002: Use Postgres as primary database
- https://sqlc.dev
