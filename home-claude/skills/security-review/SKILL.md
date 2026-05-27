---
name: security-review
description: Run a security review on the current project (architecture or code). Delegates to the Security Architect who applies the security-checklist skill. Use any time, especially in Gate 3B and Gate 5. Auto-invoke when user says "security review", "revisar seguridad", "/security-review", "están las barreras de seguridad aplicadas".
---

# Security Review

Delegar a el Security Architect (security) la revisión de seguridad del proyecto en su estado actual.

## Procedimiento

### Paso 1: Identificar contexto

- ¿Estamos en Fase 3B (arquitectura propuesta, código no escrito)?
- ¿Estamos en Gate 5 (código escrito, hay que verificar contra realidad)?
- ¿Es ad-hoc en otra fase?

### Paso 2: Invocar a el Security Architect

Invocar a `ivan-security` con instrucción específica:
- Si Fase 3B: aplicar skill `security-checklist` sobre `03-architecture.md` y `03-api-design.md`. Producir `03-security.md`.
- Si Gate 5: aplicar skill `security-checklist` sobre el código + arquitectura. Comparar con `03-security.md` previo. Identificar drift.

### Paso 3: Si hay gateway

Aplicar también skill `gateway-hardening`:
- Audit de la config actual
- Verificar cero wildcards
- Verificar rate limiting por endpoint
- Verificar security headers
- Verificar CORS restrictivo

### Paso 4: Verificar secretos

Ejecutar (o pedirle al usuario):

```bash
# Detectar secrets en el repo
gitleaks detect --source . --verbose 2>&1 || true

# Verificar .env en gitignore
grep -E "^\.env$|^\.env\.local$" .gitignore || echo "WARNING: .env not in .gitignore"

# Buscar secrets hardcodeados
grep -rE "(api[_-]?key|secret|token|password)\s*[:=]\s*['\"][a-zA-Z0-9/_+-]{20,}" \
  --include="*.go" --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules --exclude-dir=.git . 2>/dev/null || true
```

### Paso 5: Verificar dependencias

```bash
# Go
[ -f go.mod ] && govulncheck ./... 2>&1 || true

# Node
[ -f package.json ] && npm audit --production 2>&1 || true
```

### Paso 6: Producir reporte

el Security Architect produce un reporte estructurado:

```markdown
# Security Review — <fecha>

## Resumen
- Threats identificados: N
- 🔴 CRITICAL: X
- 🟠 HIGH: Y  
- 🟡 MEDIUM: Z
- 🟢 LOW: W

## Hallazgos críticos
[Detalle de cada CRITICAL/HIGH con paso a resolución]

## OWASP Top 10 — estado por item
[Tabla]

## Gateway (si aplica)
- ✅ Cero wildcards
- ✅ Rate limiting por endpoint
- ❌ Falta CSP header

## Secretos
- ✅ No detectados secrets en repo
- ✅ .env en .gitignore

## Dependencias
- N vulns conocidas, M con fix disponible

## Recomendaciones priorizadas
1. ...
2. ...

## Recommendation
- [ ] Listo para avanzar
- [ ] Requiere resolver bloqueantes (listados arriba)
```

### Paso 7: Actualizar `03-security.md`

Actualizar el documento de seguridad del proyecto con los hallazgos.

## Reglas duras

- **CUALQUIER finding CRITICAL bloquea**.
- **Wildcards en gateway → CRITICAL automático**.
- **Secrets detectados en repo → CRITICAL automático**.
- **Dependencias con vuln HIGH/CRITICAL conocida → bloqueante**.
- **PII sin consentimiento documentado → HIGH al menos**.

## Output esperado

- Reporte resumido al usuario con findings priorizados
- Actualización de `docs/context/03-security.md`
- Si hay bloqueantes: lista clara de qué resolver
