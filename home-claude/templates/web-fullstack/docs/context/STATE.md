# Project State

> Single source of truth para el estado actual del proyecto.
> Cualquier agente que abra una sesión nueva DEBE leer este archivo primero.
> Cualquier cambio de fase o gate ACTUALIZA este archivo.

## Current phase

**Phase**: `0 - Discovery`
**Status**: `IN_PROGRESS`  <!-- one of: NOT_STARTED, IN_PROGRESS, GATE_PENDING, GATE_OPEN_FOR_ITERATION, GATE_CLOSED -->
**Owner**: <agent or user>
**Started**: YYYY-MM-DD
**Last update**: YYYY-MM-DD

## Phase history

| Phase | Status | Gate report | Closed at | Notes |
|---|---|---|---|---|
| 0 - Discovery | IN_PROGRESS | — | — | — |
| 1 - Problem Definition | NOT_STARTED | — | — | — |
| 2 - Product Decisions | NOT_STARTED | — | — | — |
| 3A - UX/UI | NOT_STARTED | — | — | — |
| 3B - Architecture | NOT_STARTED | — | — | — |
| 4 - DevOps & Infra | NOT_STARTED | — | — | — |
| 5 - Development | NOT_STARTED | — | — | — |
| 6 - Docs & Release | NOT_STARTED | — | — | — |
| 7 - Operations | NOT_STARTED | — | — | — |

## Open blockers (carry-over from previous phases)

<!-- List blockers that previous gates left open and are being carried into current/future phases.
     Empty if no carry-over. -->

- [ ] None

## Open questions

<!-- Strategic questions across phases that need user decision -->

- None

## Active agent

<!-- Which agent the user is currently working with, if any. Helps resume sessions. -->

None active.

## Active evolutions (post-Fase 6)

<!-- Lista de evolves en curso después de Fase 6. 
     Cuando se cierra Fase 6 y el proyecto vive, las nuevas features/hotfixes/refactors/migrations se trackean acá.
     Empty si el proyecto no llegó a Fase 6 todavía. -->

- None

<!-- Ejemplo cuando hay evolves activos:
- `feature/multi-currency` — owner: el Backend Developer — branch: `evolve/feature/multi-currency` — start: 2026-06-01 — status: in_progress
- `hotfix/login-500` — owner: el Security Architect — branch: `hotfix/login-500` — start: 2026-06-05 — status: in_review
-->

## Last meaningful change

<!-- One-line description of what happened most recently. Helps new sessions get up to speed. -->

Project initialized from template.

---

## How to update this file

This file is updated by:
- The `kickoff` skill (when project starts)
- The `phase-gate` skill (at gate transitions)
- The Critic (when gates open/close)
- el Doc Sentinel (doc-sentinel) when auditing
- The user manually if needed

If you (an agent) modify this file, update `Last update` timestamp and `Last meaningful change` description.

## Why this file exists

Without a single source of truth for project state, agents starting a fresh session don't know:
- Which phase we're in
- What's pending
- Which gate is open
- What the user is currently working on

This breaks the multi-agent flow. STATE.md is the anchor.
