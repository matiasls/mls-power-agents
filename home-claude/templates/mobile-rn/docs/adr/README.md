# Architecture Decision Records (ADRs)

This directory holds the architectural decisions made on this project.

Naming: `NNNN-decision-in-kebab-case.md`, where `NNNN` is a 4-digit zero-padded sequence (0001, 0002, ...).

Template:

```markdown
# ADR-NNNN: <Title>

**Status**: Proposed | Accepted | Superseded by ADR-XXXX
**Date**: YYYY-MM-DD
**Deciders**: <people / agents involved>

## Context

[What problem are we facing? What constraints? What's the current state?]

## Decision

[What did we decide?]

## Rationale

[Why this decision? What tradeoffs did we evaluate?]

## Alternatives considered

- **Option A**: Rejected because ...
- **Option B**: Rejected because ...

## Consequences

### Positive
- ...

### Negative
- ...

### Risks
- ...

## References

- [Related ADRs, docs, external sources]
```

## When to write an ADR

- Any non-obvious technical decision.
- Any deviation from the global stack defaults (see `~/.claude/CLAUDE.md`).
- Any decision that future Claude/devs would otherwise need to reverse-engineer.
- Anything you'd want documented if you returned to the project in 6 months.

## When NOT to write an ADR

- Routine implementation choices.
- Decisions that are already documented in code (e.g., naming conventions).
- "Why I picked variable name X" — that's a code comment, not an ADR.

ADRs are immutable. If a decision changes, write a new ADR that supersedes the old one and update the status of the old one to "Superseded by ADR-XXXX".
