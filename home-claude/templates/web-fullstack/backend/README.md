# Backend (Go)

> Modular monolith. Each subdirectory under `internal/` is a domain module.

## Structure

```
backend/
├── cmd/
│   └── api/
│       └── main.go              # Application entry point
├── internal/
│   ├── platform/                # Shared infra: logger, config, DB pool
│   │   ├── config/
│   │   ├── logger/
│   │   └── postgres/
│   ├── <module-1>/              # Domain module — created in Fase 3B by el Software Architect
│   │   ├── domain/              # Entities, value objects, domain logic
│   │   ├── handlers/            # HTTP/gRPC handlers
│   │   ├── persistence/         # Repository implementations
│   │   ├── service/             # Use cases / application services
│   │   ├── contracts/           # Types exported to other modules
│   │   └── module.go            # Wiring (dependencies → service → handlers)
│   └── <module-2>/
├── migrations/                  # Database migrations (one schema per module)
├── pkg/                         # Truly reusable code (avoid; prefer internal/)
├── go.mod
├── go.sum
├── Dockerfile
├── Dockerfile.dev
└── .golangci.yml
```

## Conventions

- **No imports across module internals**. Module A can only import `module B/contracts`, never `module B/domain` or `module B/persistence`.
- **Each module owns its DB tables**. Schema in Postgres: `module_name.table_name`.
- **Tests**: `*_test.go` next to the file being tested. Table-driven tests by default.
- **No global state**. Pass dependencies explicitly.

## Adding a new module

el Software Architect (architect) decides when to add a module. Each new module:

1. Has a single, clear responsibility (one bounded context).
2. Owns its DB tables (own schema).
3. Exports types via `contracts/` only.
4. Has its own `module.go` that wires its internals.
5. Is added to `cmd/api/main.go` wiring.

## Linting

```bash
golangci-lint run ./...
```

Config in `.golangci.yml`.

## Testing

```bash
go test ./... -cover
```

Coverage target: ≥85% on business logic.
