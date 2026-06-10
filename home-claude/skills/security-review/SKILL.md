---
name: security-review
description: Run a security review on the current project (architecture or code), including STRIDE threat modeling and the security checklist. Delegates to the Security Architect. Use in Fase 3B (threat model sobre arquitectura), Gate 5 (verificación post-desarrollo), or any time. Auto-invoke when user says "security review", "revisar seguridad", "threat model", "STRIDE", "amenazas", "OWASP", "/security-review", "/threat-model", "están las barreras de seguridad aplicadas".
---

# Security Review

Revisión de seguridad del proyecto en su estado actual, ejecutada por el Security Architect. Incluye threat modeling STRIDE (Fase 3B) y verificación contra código real (Gate 5). La filosofía: identificar amenazas TEMPRANO cuesta menos que mitigarlas después.

## Procedimiento

### Paso 1: Identificar contexto

- ¿Fase 3B? → threat model sobre la arquitectura propuesta (código no escrito).
- ¿Gate 5? → verificar código + arquitectura contra el `03-security.md` previo. Identificar drift.
- ¿Ad-hoc? → alcance según pedido.

### Paso 2: Invocar al Security Architect

- Si Fase 3B: aplicar el threat modeling (abajo) sobre `03-architecture.md` y `03-api-design.md`. Producir `03-security.md`.
- Si Gate 5: re-aplicar el checklist sobre el código real. Comparar con `03-security.md`. Identificar drift.

### Paso 3: Threat Modeling (STRIDE)

**3a. Mapear assets críticos** — ¿qué hay para proteger?

| Asset | Descripción | Por qué importa | Worst case si se compromete |
|---|---|---|---|

**3b. Mapear trust boundaries** — cada cruce de boundary es un punto de control:

```
[Internet] ──> [Gateway] ──> [Backend en red privada] ──> [DB]
[Backend] ──> [APIs externas]   ← cada API externa es un boundary
```

**3c. Para cada componente × boundary, aplicar las 6 categorías STRIDE** (Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation of Privilege):

| ID | Asset / Componente | STRIDE | Amenaza específica | Likelihood | Impact | Severidad | Mitigación | Owner |
|---|---|---|---|---|---|---|---|---|

Severidad = matriz Likelihood × Impact:

| | Likelihood: Low | Medium | High |
|---|---|---|---|
| **Impact: Low** | Low | Low | Medium |
| **Impact: Medium** | Low | Medium | High |
| **Impact: High** | Medium | High | Critical |

**3d. Priorizar**: cada CRITICAL se mitiga antes de Gate 3B; cada HIGH antes de Gate 5; MEDIUM/LOW → mitigar en roadmap o aceptar documentado.

**3e. Riesgos aceptados** — amenazas NO mitigadas en MVP, con justificación y fecha de revisita. **Cada uno firmado por el usuario**, no por el Security Architect solo:

| Threat ID | Por qué se acepta | Cuándo se revisita |
|---|---|---|

### Paso 4: Checklist por tipo de aplicación

Verificar OWASP Top 10 item por item (estado: aplica / no aplica / a verificar) y además:

**Web app con login**
- [ ] Cookies `HttpOnly`, `Secure`, `SameSite`; CSRF protection si usás cookies
- [ ] Passwords con bcrypt/argon2; rate limit en login y password recovery
- [ ] Logout limpia sesión server-side; reset token de un solo uso con expiry corto

**API pública**
- [ ] Backend en red privada, gateway al frente (ver skill `gateway-hardening`)
- [ ] Authz a nivel de RECURSO, no solo de endpoint (`user can read order X`)
- [ ] CORS restrictivo (sin `*`); versionado; errors sin stack traces en prod

**PII / datos personales**
- [ ] Inventario de PII (qué, dónde, por qué); consentimiento capturado y versionado
- [ ] Derechos ARCO implementados; política de retención y deletion
- [ ] Logs sin PII completa ni tokens

**Pagos**
- [ ] NO almacenar números de tarjeta (tokenización vía Stripe/MercadoPago)
- [ ] Webhooks validados criptográficamente; idempotencia en operaciones de pago

**Mobile**
- [ ] Tokens en secure storage (Keychain/Keystore), NUNCA AsyncStorage
- [ ] Deep links validados; app signing keys protegidas

### Paso 5: Si hay gateway

Aplicar skill `gateway-hardening`:
- Audit de la config actual
- Verificar **cero wildcards**
- Verificar rate limiting por endpoint
- Verificar security headers y CORS restrictivo

### Paso 6: Verificar secretos

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

### Paso 7: Verificar dependencias

```bash
[ -f go.mod ] && govulncheck ./... 2>&1 || true
[ -f package.json ] && npm audit --production 2>&1 || true
[ -f requirements.txt ] || [ -f pyproject.toml ] && pip-audit 2>&1 || true
```

### Paso 8: Producir reporte y actualizar `03-security.md`

```markdown
# Security Review — <fase / fecha>

## Resumen
- Threats identificados: N
- 🔴 CRITICAL: X | 🟠 HIGH: Y | 🟡 MEDIUM: Z | 🟢 LOW: W

## Hallazgos críticos
[Detalle de cada CRITICAL/HIGH con paso a resolución]

## Threat Model (STRIDE)
### Assets críticos / Trust boundaries / Threats identificados / Riesgos aceptados
[Tablas del Paso 3]

## OWASP Top 10 — estado por item
[Tabla]

## Gateway (si aplica)
- ✅/❌ Cero wildcards | rate limiting por endpoint | security headers

## Secretos y dependencias
- Estado de scans

## Recomendación
- [ ] Listo para avanzar
- [ ] Requiere resolver bloqueantes (listados arriba)
```

El threat model en `docs/context/03-security.md` incluye además **triggers de re-evaluación**: nueva integración externa, cambio en modelo de auth, nuevo tipo de PII, incident de seguridad, cambio regulatorio.

## Severity guide

| Severidad | Definición | Acción |
|---|---|---|
| 🔴 CRITICAL | Exposición de datos sensibles, RCE, auth bypass | Bloquea gate. Resolver YA. |
| 🟠 HIGH | Vuln explotable con impacto serio | Bloquea gate. Resolver en sprint. |
| 🟡 MEDIUM | Impacto limitado o requiere condiciones | No bloquea, documentar plan |
| 🟢 LOW | Hardening adicional | Sugerencia |

## Reglas duras

- **CUALQUIER finding CRITICAL bloquea**.
- **Wildcards en gateway → CRITICAL automático**.
- **Secrets detectados en repo → CRITICAL automático**.
- **Dependencias con vuln HIGH/CRITICAL conocida → bloqueante**.
- **PII sin consentimiento documentado → HIGH al menos**.
- **Threat modeling se hace en Fase 3B (arquitectura), no después.**

## Anti-patterns

1. **Threat model genérico**: si sirve para cualquier app, es inútil. Amenazas específicas a ESTE sistema.
2. **Severidad inflada**: si todo es CRITICAL, nada es CRITICAL.
3. **Mitigaciones vagas**: "implementar seguridad" no es mitigación. "Rate limit 60 req/min por IP en /api/v1/scores" sí.
4. **Solo prevención, no detección**: las mitigaciones incluyen detección + respuesta.
5. **No re-evaluar nunca**: threat model es vivo. Re-revisar al menos por release mayor.

## Output esperado

- Reporte resumido al usuario con findings priorizados
- Actualización de `docs/context/03-security.md`
- Si hay bloqueantes: lista clara de qué resolver
