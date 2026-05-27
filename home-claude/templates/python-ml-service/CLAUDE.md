# CLAUDE.md — <PROJECT_NAME> (Python ML Service)

> Python service for ML/data-science workloads. Extends `~/.claude/CLAUDE.md` global.

## Project context

- **Name**: <PROJECT_NAME>
- **Type**: Python service (ML / data processing / scoring engine)
- **Nature**: [Internal service / MVP / Commercial]
- **Started**: YYYY-MM-DD


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

**Llená esto al inicio del proyecto.** Define cuánta fricción aplican los agentes. Ver `~/.claude/CLAUDE.md` sección 1.1 para detalles.

## When to use this template

Para servicios donde el corazón es modelo de ML, procesamiento de datos, o lógica científica que se beneficia del ecosistema Python (pandas, scikit-learn, XGBoost, PyTorch, etc.).

**NO usar para**:
- Backends generales: usar `web-fullstack` (Go).
- APIs simples sin ML: usar `web-fullstack` (Go).

## Stack

- **Python 3.11+**
- **uv** o **poetry** para gestión de dependencias (default: uv, más rápido)
- **FastAPI** para servir endpoints (si aplica)
- **Pydantic v2** para validación
- **scikit-learn / XGBoost / etc.** según el caso
- **pandas / polars** para data wrangling
- **ruff** + **mypy** para lint y type check
- **pytest** + **pytest-cov** para tests

## Stack overrides (vs global default)

- Backend en Python en lugar de Go: justificado porque el core es ML
- Esto típicamente NO es el único servicio del sistema. Suele coexistir con un backend en Go (para la API pública / plataforma) y este servicio en Python (para inference / training)

## Estructura sugerida

```
src/
├── domain/             # Tipos del dominio (Pydantic models)
├── features/           # Feature engineering pipelines
├── models/             # Wrappers de modelos (load, predict, train)
├── api/                # FastAPI routes (si aplica)
├── batch/              # Jobs batch (training, retraining)
├── data/               # Data loaders y conexiones
└── utils/
tests/
├── unit/
├── integration/
└── fixtures/
notebooks/              # Solo para exploración; NO se usan en producción
artifacts/              # Modelos serializados, métricas (gitignored, en MLflow/S3)
```

## Reglas duras adicionales

1. **Notebooks no van a producción**. Toda lógica de notebook usable se refactoriza a `src/`.
2. **Modelos versionados**: cada modelo entrenado tiene versión + metadata (training data, hyperparams, métricas) reproducible.
3. **Reproducibilidad**: random seeds fijos en training. Datos de entrenamiento snapshot-eados.
4. **Feature store o equivalente**: si hay >1 modelo o features compartidas entre modelos, separar feature pipeline.
5. **Model serving via API HTTP**, NO loading el modelo en cada request del backend principal.
6. **Métricas de modelo monitoreadas en prod**: drift detection, performance over time.

## References

- Global setup: `~/.claude/CLAUDE.md`
- Backend Go agent: el Backend Developer (para servicios complementarios)
- DevOps: el DevOps & Platform agent
