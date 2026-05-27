---
name: enforce-rules
description: Generate or audit CI/git hooks that automatically enforce the hard rules from CLAUDE.md. Use when setting up a project's CI pipeline. Auto-invoke when user says "enforce reglas", "hooks de CI", "automatizar reglas", "/enforce-rules".
---

# Enforce Rules (CI / Git Hooks)

Skill para convertir las reglas duras del setup en checks automáticos. La filosofía: la regla que no se enforce, se va a olvidar.

## Reglas duras a enforcer

Las reglas del CLAUDE.md global que pueden enforcearse automáticamente:

| Regla | Mecanismo | Donde corre |
|---|---|---|
| Sin secrets en repo | gitleaks | CI + pre-commit |
| `.env` en .gitignore | grep check | CI + pre-commit |
| Coverage ≥85% en código de negocio | tooling de coverage | CI |
| Sin vulns HIGH+ en deps | `govulncheck` / `npm audit` | CI |
| Sin wildcards en gateway config | grep en archivos de gateway | CI |
| `docs/EXECUTION.md` existe | file existence | CI |
| ADRs para desvíos de stack default | manual review (no automatizable) | PR review |
| Tests para código nuevo | coverage delta | CI |
| `docs/context/STATE.md` actualizado | git diff against templates | manual / el Doc Sentinel |

## Procedimiento

### Paso 1: Identificar qué stack tiene el proyecto

Detectar:
- ¿Backend Go? → `go.mod` existe
- ¿Frontend Node? → `package.json` existe
- ¿Python? → `pyproject.toml` o `requirements.txt`
- ¿Mobile RN? → `app.config.ts` o `app.json` con Expo
- ¿Hay gateway config? → buscar `Caddyfile`, `krakend.json`, `traefik.yml`

### Paso 2: Generar workflows de CI

Por cada stack detectado, agregar jobs al workflow existente o crear uno nuevo.

### Paso 3: Generar pre-commit hooks (opcional pero recomendado)

Hooks locales para detectar problemas antes del push.

### Paso 4: Verificar que existen

En CI mismo, verificar que las reglas del proyecto están enforced:
- ¿El workflow incluye gitleaks?
- ¿El workflow falla con vulns HIGH+?
- ¿El workflow chequea coverage?

## Templates

### GitHub Actions completo (`.github/workflows/ci.yml`)

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  # ============================================================
  # Security checks (apply to ALL stacks)
  # ============================================================
  
  secrets-scan:
    name: Detect secrets
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Run gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  env-gitignore-check:
    name: Verify .env not tracked
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check .env is in .gitignore
        run: |
          if ! grep -qE "^\.env$|^\.env\.local$" .gitignore; then
            echo "::error::.env must be in .gitignore"
            exit 1
          fi
      - name: Check no .env files committed
        run: |
          if git ls-files | grep -E "^\.env$|^\.env\.local$"; then
            echo "::error::.env files should never be committed"
            exit 1
          fi

  gateway-no-wildcards:
    name: Gateway config has no wildcards
    runs-on: ubuntu-latest
    if: hashFiles('gateway/Caddyfile', 'gateway/krakend.json', 'gateway/traefik.yml', '**/Caddyfile') != ''
    steps:
      - uses: actions/checkout@v4
      - name: Check for wildcards in gateway configs
        run: |
          # Looking for explicit wildcards in routing rules
          # Adjust patterns based on actual gateway in use
          if grep -rE '(handle\s+/\*|path:\s*"/\*|"path":\s*"/\*")' \
             gateway/ 2>/dev/null; then
            echo "::error::Gateway config contains wildcards. See ~/.claude/skills/gateway-hardening/SKILL.md"
            exit 1
          fi

  docs-required:
    name: Required docs exist
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check docs/EXECUTION.md exists
        run: |
          if [ ! -f docs/EXECUTION.md ]; then
            echo "::error::docs/EXECUTION.md is required from Phase 4"
            exit 1
          fi
      - name: Check README.md exists
        run: |
          if [ ! -f README.md ]; then
            echo "::error::README.md is required"
            exit 1
          fi
      - name: Check STATE.md exists
        run: |
          if [ ! -f docs/context/STATE.md ]; then
            echo "::error::docs/context/STATE.md is required"
            exit 1
          fi

  # ============================================================
  # Go backend (only if go.mod exists)
  # ============================================================
  
  go-lint:
    name: Go lint
    runs-on: ubuntu-latest
    if: hashFiles('backend/go.mod') != ''
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - name: golangci-lint
        uses: golangci/golangci-lint-action@v6
        with:
          working-directory: backend

  go-test:
    name: Go test + coverage
    runs-on: ubuntu-latest
    if: hashFiles('backend/go.mod') != ''
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - name: Run tests with coverage
        working-directory: backend
        run: |
          go test -coverprofile=coverage.out ./...
          go tool cover -func=coverage.out
      - name: Enforce coverage ≥85%
        working-directory: backend
        run: |
          COVERAGE=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | sed 's/%//')
          THRESHOLD=85.0
          if [ "$(echo "$COVERAGE < $THRESHOLD" | bc)" = "1" ]; then
            echo "::warning::Coverage $COVERAGE% is below threshold $THRESHOLD%"
            # NOTE: change to 'exit 1' to make this blocking
          fi

  go-vuln:
    name: Go vulnerabilities
    runs-on: ubuntu-latest
    if: hashFiles('backend/go.mod') != ''
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - name: Run govulncheck
        working-directory: backend
        run: |
          go install golang.org/x/vuln/cmd/govulncheck@latest
          govulncheck ./...

  # ============================================================
  # Node frontend (only if package.json exists)
  # ============================================================
  
  node-lint:
    name: Node lint
    runs-on: ubuntu-latest
    if: hashFiles('frontend/package.json') != ''
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: npm
          cache-dependency-path: frontend/package-lock.json
      - run: cd frontend && npm ci && npm run lint

  node-typecheck:
    name: Node typecheck
    runs-on: ubuntu-latest
    if: hashFiles('frontend/package.json') != ''
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: cd frontend && npm ci && npx tsc --noEmit

  node-test:
    name: Node test + coverage
    runs-on: ubuntu-latest
    if: hashFiles('frontend/package.json') != ''
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - working-directory: frontend
        run: |
          npm ci
          npm test -- --coverage --run

  node-audit:
    name: Node audit
    runs-on: ubuntu-latest
    if: hashFiles('frontend/package.json') != ''
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - working-directory: frontend
        run: |
          npm ci
          npm audit --audit-level=high

  # ============================================================
  # Python (only if pyproject.toml exists)
  # ============================================================
  
  python-lint:
    name: Python lint
    runs-on: ubuntu-latest
    if: hashFiles('pyproject.toml') != ''
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: |
          pip install uv
          uv pip install --system ruff mypy
          ruff check src tests
          mypy src

  python-test:
    name: Python test
    runs-on: ubuntu-latest
    if: hashFiles('pyproject.toml') != ''
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: |
          pip install uv
          uv pip install --system -r requirements.txt -r requirements-dev.txt
          pytest --cov=src --cov-fail-under=85

  python-audit:
    name: Python audit
    runs-on: ubuntu-latest
    if: hashFiles('pyproject.toml') != ''
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: |
          pip install pip-audit
          pip-audit
```

### Pre-commit hooks (`.pre-commit-config.yaml`)

```yaml
# Install: pip install pre-commit && pre-commit install
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: check-yaml
      - id: check-json
      - id: check-added-large-files
        args: ['--maxkb=500']
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-merge-conflict

  # Go
  - repo: https://github.com/golangci/golangci-lint
    rev: v1.55.2
    hooks:
      - id: golangci-lint
        files: ^backend/

  # Python
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.6
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
```

### Custom shell hook for gateway wildcards

```bash
#!/usr/bin/env bash
# .git/hooks/pre-push (or via lefthook / pre-commit)

# Detect wildcards in gateway configs
WILDCARD_FOUND=$(grep -rE '(handle\s+/\*|path:\s*"/\*"|"path":\s*"/\*"|location\s+/\*)' \
                 gateway/ 2>/dev/null || true)

if [ -n "$WILDCARD_FOUND" ]; then
  echo "❌ Gateway configs contain wildcards (forbidden):"
  echo "$WILDCARD_FOUND"
  echo ""
  echo "See ~/.claude/skills/gateway-hardening/SKILL.md"
  exit 1
fi
```

## Output esperado

Archivos a producir / actualizar:
- `.github/workflows/ci.yml` con jobs apropiados al stack
- `.pre-commit-config.yaml` (si el equipo usa pre-commit)
- `.gitleaks.toml` con configuración custom si necesario
- Documentación en `docs/EXECUTION.md` sobre cómo correr los checks localmente

## Cómo el Doc Sentinel verifica que las reglas están enforced

En `/docs-audit`, el Doc Sentinel puede chequear:
- ¿Existe `.github/workflows/ci.yml`?
- ¿Tiene los jobs esperados (secrets-scan, deps audit, coverage)?
- ¿Está actualizado al stack actual del proyecto?

Si falta enforcement de una regla dura, el Doc Sentinel levanta finding.
