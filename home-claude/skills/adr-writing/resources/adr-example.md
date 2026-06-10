# Ejemplo de buen ADR

Ejemplo de referencia del nivel de especificidad esperado en cada sección.

---

## ADR-0003: Use sqlc instead of GORM for database access

**Status**: Accepted
**Date**: 2026-05-13

### Context
The team needs a database access layer for the scoring module. We process ~500 reads/sec at peak with complex JOIN queries against the productors+scores tables. Compile-time type safety is critical because our domain model has 40+ fields and we cannot afford runtime type errors in production. Our team has strong SQL knowledge; nobody has deep GORM experience.

### Decision
We will use sqlc with pgx as the driver for all database access in Go services. SQL queries live in `.sql` files; sqlc generates type-safe Go code.

### Rationale
- Type safety at compile-time eliminates a class of bugs
- SQL is the lingua franca of the team; everyone reads it fluently
- pgx is the most performant Postgres driver for Go
- Generated code is auditable and explicit

### Alternatives Considered

**GORM**: ORM with auto-migrations and good docs.
- Pros: Familiar pattern for devs from Rails/Django background
- Cons: Performance overhead, magic that hides SQL, weak type safety on complex queries
- Why rejected: Performance concerns and the team values SQL transparency

**database/sql + handwritten code**: stdlib only.
- Pros: Zero dependencies, full control
- Cons: Boilerplate, manual type assertions, error-prone for 40+ field structs
- Why rejected: sqlc gives 90% of the control with 10% of the boilerplate

### Consequences

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

### References
- ADR-0001: Use Go for backend
- ADR-0002: Use Postgres as primary database
- https://sqlc.dev
