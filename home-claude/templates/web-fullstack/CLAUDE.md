# CLAUDE.md — <PROJECT_NAME>

> Project-specific instructions. Extends the global `~/.claude/CLAUDE.md`.

## Project context

- **Name**: <PROJECT_NAME>
- **Nature**: [Personal / MVP / Commercial product]
- **Started**: YYYY-MM-DD
- **Owner**: <user name>

## Project profile (CRITICAL — los agentes modulan su rigor según esto)

```yaml
project_profile:
  type: personal | mvp | commercial               # default si no se especifica: commercial
  stakeholders: solo | small_team | external_parties
  timeline: flexible | soft_deadline | hard_external
  regulatory: none | medium | high
  data_sensitivity: none | personal | sensitive | regulated
  primary_goal: validate_problem | build_solution | both
```

**Llená esto al inicio del proyecto.** Define cuánta fricción aplican los agentes. Ver `~/.claude/CLAUDE.md` sección 1.1 para la tabla de modulación.

## Phase tracking

- [ ] Fase 0 — Discovery
- [ ] Fase 1 — Problem Definition
- [ ] Fase 2 — Product Decisions
- [ ] Fase 3A — UX/UI Design
- [ ] Fase 3B — Architecture
- [ ] Fase 4 — DevOps & Infra Setup
- [ ] Fase 5 — Development
- [ ] Fase 6 — Docs & Release
- [ ] Fase 7 — Operations

Current phase: `0 - Discovery`

## Stack (filled by el Software Architect in Fase 3B)

- Frontend: TBD
- Backend: TBD
- Database: TBD
- Infra: TBD
- Gateway: TBD

## Project-specific overrides

[Override global rules here if needed for this project. Justify each override.]

## Notes for agents

- [Special context the user wants every agent to know]

## References

- Global setup: `~/.claude/CLAUDE.md`
- Context per phase: `docs/context/`
- ADRs: `docs/adr/`
- Execution guide: `docs/EXECUTION.md`
