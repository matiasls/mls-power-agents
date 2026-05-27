# Execution Guide (Python ML Service)

> How to run this ML service in every environment.

## Overview

FastAPI service exposing prediction endpoints. Optionally runs scheduled training jobs.

Components:
- **API server** (FastAPI) → port 8001
- **Training jobs** (CLI / cron)
- **Model registry** (local in dev, S3/MLflow in prod)

---

## Local Development

### Prerequisites

- Python 3.11+
- uv (`pip install uv`) — faster than pip/poetry
- Make
- Docker (for integration with other services if needed)

### First-time setup

```bash
git clone <repo-url>
cd <project>
make setup
source .venv/bin/activate
```

### Daily development

```bash
make dev          # Start FastAPI on :8001
# In another terminal:
curl http://localhost:8001/health
```

### Available commands

| Command | What it does |
|---|---|
| `make dev` | Start FastAPI with auto-reload |
| `make test` | Run pytest + coverage |
| `make lint` | ruff + mypy |
| `make format` | Auto-format |
| `make train` | Run training pipeline |
| `make predict` | CLI smoke test prediction |
| `make clean` | Remove venv + caches |

### Troubleshooting

**uv not found**
```bash
pip install uv
```

**Module import errors**
- Verify activated venv: `which python` should show `.venv/bin/python`
- Re-run `make setup`

---

## Staging

> ⚠️ **STATUS**: [Not yet configured | Configured]

### Where it runs

[Railway / AWS Lambda / Cloud Run / etc.]

### Model loading

Models loaded from `MODEL_REGISTRY_URI` at startup. Hot-reload requires restart (or implement model version checking endpoint).

### How to deploy

[TBD specific to provider]

---

## Production

### Pre-deploy checklist

- [ ] Model validated in staging with prod-like data
- [ ] Model version tagged and stored in registry
- [ ] Metrics baseline captured (latency, accuracy on validation set)
- [ ] CHANGELOG.md updated
- [ ] Tests passing
- [ ] Rollback plan: previous model version still in registry

### Deploy

```bash
# 1. Tag
git tag -s vX.Y.Z

# 2. Push tag (CI auto-deploys, or manual)
git push origin vX.Y.Z

# 3. Update MODEL_VERSION env var if applicable
```

### Verify

```bash
curl https://ml-api.prod/health
curl https://ml-api.prod/version  # Should return service version + model version
```

### Rollback

#### Service rollback
[Provider-specific]

#### Model rollback (more common)
```bash
# Just update env var to previous model version, no redeploy needed
MODEL_VERSION=v1.2.3
```

This is why model registry + env var pattern is preferred over baked-in models.

---

## Environment Variables Reference

| Variable | Local | Staging | Production | Notes |
|---|---|---|---|---|
| `MODEL_REGISTRY_URI` | `./artifacts` | `s3://staging-models/` | `s3://prod-models/` | Where to load models from |
| `MODEL_VERSION` | `latest` | specific | specific | Pin to specific version in prod |
| `DATABASE_URL` | local | provider | provider | If service reads from DB |

---

## ML-specific operations

### Retraining

Scheduled or manual:

```bash
make train  # local
# Production: scheduled via cron / Airflow / similar
```

Output: new model version pushed to registry + metadata (training metrics, data hash).

### Model monitoring in production

Track in observability stack:
- Prediction latency p50/p95/p99
- Prediction volume per endpoint
- Distribution of predictions (alert on drift)
- Input data drift (compare distributions to training data)
- Model accuracy (if ground truth available, often delayed)

### A/B testing models

If running multiple model versions:
- Route X% of traffic to new model
- Compare metrics in real time
- Promote new model if outperforms over N days
- Roll back if underperforms

---

## Disaster Recovery

### Lost model artifacts
- Registry should be backed up. If using S3, enable versioning.
- Reproducibility: training pipeline should be deterministic given same data + seed.

### Data corruption
- Model trained on bad data: revert to previous version + retrain when data clean.

### Service down
- Health checks should trigger restart. If persistent: rollback to previous service version.
