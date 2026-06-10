# Runbooks

Operational procedures with exact commands, one file per task.

Required from Fase 6 onwards: `oncall.md`, `rollback.md`, `db-rollback.md`, `secret-rotation.md`, `backup-restore.md`, `disaster-recovery.md`.

Structure of each runbook: When to use / Prerequisites / Procedure (steps with exact commands) / Verification / Rollback if applicable.

Principles:
- **Exact commands**, not vague descriptions.
- **Assume the operator is stressed**: clarity over elegance.
- **Test runbooks periodically** and note when last verified. A runbook that doesn't work is worse than no runbook.
