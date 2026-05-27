# Runbooks

Operational procedures. Each runbook describes how to perform a specific operational task.

## Required runbooks (from Fase 6 onwards)

- `oncall.md` — Incident response procedures
- `rollback.md` — How to roll back a deploy
- `db-rollback.md` — How to roll back a DB migration
- `secret-rotation.md` — How to rotate secrets
- `backup-restore.md` — Backup and restore procedures
- `disaster-recovery.md` — Total loss recovery

## Template for a runbook

```markdown
# Runbook: <Task Name>

## When to use

[Trigger conditions]

## Prerequisites

- [Access required]
- [Tools required]

## Procedure

### Step 1: ...
\`\`\`bash
# Exact commands
\`\`\`

### Step 2: ...

## Verification

How to confirm the operation succeeded.

## Rollback (if applicable)

How to undo if something goes wrong mid-procedure.

## Related

- Other runbooks
- Relevant ADRs
```

## Principles

- **Exact commands**, not vague descriptions.
- **Assume the operator is stressed**. Clarity matters more than elegance.
- **Test runbooks periodically**. A runbook that doesn't work is worse than no runbook.
- **Date stamps**: note when last verified.
