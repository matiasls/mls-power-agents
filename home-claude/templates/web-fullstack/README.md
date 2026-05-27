# <PROJECT_NAME>

> <One-line description of what this project does>

## What it does

[2-3 sentences explaining the purpose and target users]

## Quick start

```bash
# First time
make setup

# Daily
make dev
```

The app will be available at:
- Frontend: http://localhost:3000
- API: http://localhost:8080

See [docs/EXECUTION.md](docs/EXECUTION.md) for the full execution guide (local, staging, production).

## Architecture

Modular monolith with clear domain boundaries. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full picture.

```
modules/
├── <module-1>/    # <responsibility>
├── <module-2>/    # <responsibility>
└── platform/      # shared infrastructure (logger, config, DB pool)
```

## Tech stack

- **Frontend**: React + TypeScript + Vite + TailwindCSS
- **Backend**: Go
- **Database**: PostgreSQL
- **Gateway**: Caddy
- **Infra**: [Railway / AWS / GCP — TBD]

For stack rationale and deviations from defaults, see ADRs in [docs/adr/](docs/adr/).

## Documentation map

| Document | What it contains |
|---|---|
| [docs/EXECUTION.md](docs/EXECUTION.md) | How to run local/staging/prod |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | High-level architecture |
| [docs/SECURITY.md](docs/SECURITY.md) | Threat model and security decisions |
| [docs/adr/](docs/adr/) | Architecture Decision Records |
| [docs/context/](docs/context/) | Phase-by-phase context (Discovery → Operations) |
| [docs/api/](docs/api/) | OpenAPI specs |
| [docs/runbooks/](docs/runbooks/) | Operational procedures |
| [CHANGELOG.md](CHANGELOG.md) | Release history |

## Development

### Common commands

```bash
make dev              # Start everything
make test             # Run all tests
make lint             # Run linters
make migrate-up       # Apply DB migrations
make logs             # Tail logs
make down             # Stop everything
```

Full list: `make help`

### Project conventions

- Branch naming: `<type>/<short-description>` where type ∈ {feat, fix, chore, docs, refactor}
- Commit messages: imperative mood, in English
- PRs: include description of WHY, not just WHAT
- ADRs: any non-obvious technical decision gets an ADR

## License

[License — TBD]
