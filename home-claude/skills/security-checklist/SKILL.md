---
name: security-checklist
description: Apply security best practices checklist (OWASP Top 10, threat modeling STRIDE, secure-by-default patterns). Use in Fase 3B (during architecture) and Gate 5 (post-development verification). Auto-invoke when user says "security review", "revisar seguridad", "/security-review", or when the Security Architect needs to verify a posture.
---

# Security Checklist

Este skill encapsula los checklists de seguridad que el Security Architect aplica. Es la garantía de que ninguna barrera de seguridad se omite.

## Cuándo usar

- En Fase 3B (arquitectura): definir threats y mitigaciones.
- En Gate 3B: verificar que la arquitectura propuesta cubre los threats.
- En Gate 5 (post-dev): re-verificar contra el código real.
- On-demand vía `/security-review`.

## Procedure

### 1. Threat Modeling (STRIDE)

Para cada componente del sistema, identificar threats por categoría:

| Letra | Categoría | Pregunta |
|---|---|---|
| **S** | Spoofing | ¿Puede alguien hacerse pasar por otro usuario o servicio? |
| **T** | Tampering | ¿Puede alguien modificar datos en tránsito o reposo? |
| **R** | Repudiation | ¿Puede alguien negar una acción que hizo? |
| **I** | Information Disclosure | ¿Puede alguien ver datos que no debería? |
| **D** | Denial of Service | ¿Puede alguien tumbar el servicio? |
| **E** | Elevation of Privilege | ¿Puede alguien obtener permisos que no le corresponden? |

Para cada threat:
- Severidad: Critical / High / Medium / Low
- Likelihood: High / Medium / Low
- Mitigación propuesta
- Riesgo residual aceptado (si aplica)

### 2. OWASP Top 10 (2021) — Checklist aplicado al proyecto

Para cada item: aplica / no aplica / a verificar.

#### A01:2021 — Broken Access Control
- [ ] Verificación de autorización en CADA endpoint, no solo de auth
- [ ] Verificación a nivel de recurso (no solo de endpoint): `user can read order X` no solo `user can read orders`
- [ ] No hay IDs adivinables / enumerables sin verificación adicional
- [ ] CORS configurado restrictivamente (sin `*`)
- [ ] Rate limiting en endpoints sensibles

#### A02:2021 — Cryptographic Failures
- [ ] TLS 1.2+ obligatorio en todas las conexiones
- [ ] Datos sensibles cifrados en reposo
- [ ] Passwords hasheados con bcrypt/argon2/scrypt (NO SHA-256 solo)
- [ ] Tokens generados con suficiente entropía
- [ ] Secretos NO en código, NO en logs, NO en error messages

#### A03:2021 — Injection
- [ ] Queries SQL parametrizadas (no string concatenation)
- [ ] ORM o query builder usado correctamente
- [ ] Inputs validados en el server, no solo en cliente
- [ ] Templates con auto-escape (anti-XSS)
- [ ] Comandos OS evitados; si necesarios, escapar argumentos

#### A04:2021 — Insecure Design
- [ ] Threat model documentado (esta sección)
- [ ] Principios de least privilege aplicados
- [ ] Defense in depth (no confiar en una sola capa)
- [ ] Diseño revisado por alguien con perspectiva de ataque

#### A05:2021 — Security Misconfiguration
- [ ] Imágenes Docker actualizadas
- [ ] Dependencies escaneadas (npm audit, govulncheck)
- [ ] Configs default cambiadas
- [ ] Errors no exponen stack traces en prod
- [ ] Endpoints de debug deshabilitados en prod
- [ ] Headers de seguridad configurados (HSTS, CSP, etc.)

#### A06:2021 — Vulnerable & Outdated Components
- [ ] CI corre `npm audit` / `govulncheck` / equivalente
- [ ] Política de actualización de deps definida
- [ ] No usás packages abandonados
- [ ] Lock files commiteados

#### A07:2021 — Identification & Authentication Failures
- [ ] Rate limiting en login y password recovery
- [ ] Password policy razonable (longitud, no en blacklist)
- [ ] Brute force protection
- [ ] Session management: tokens expiran, refresh seguro
- [ ] No hay credenciales por default

#### A08:2021 — Software & Data Integrity Failures
- [ ] CI verifica integridad de dependencies (lock files, checksums)
- [ ] Pipelines de deploy validan source
- [ ] Auto-update sin verificación NO se usa
- [ ] Serialization segura (no `pickle` con input no confiable, etc.)

#### A09:2021 — Security Logging & Monitoring
- [ ] Eventos de seguridad loggeados (login, fail, perms changes)
- [ ] Logs NO contienen secrets, tokens, PII completa
- [ ] Logs centralizados y retenidos
- [ ] Alertas sobre patrones sospechosos

#### A10:2021 — SSRF (Server-Side Request Forgery)
- [ ] URLs en inputs de usuario validadas contra allowlist
- [ ] Requests a internal IPs bloqueados desde paths user-controlled
- [ ] DNS rebinding protection si aplica

### 3. Checklist específicos por tipo de aplicación

#### Si es web app con login
- [ ] Cookies con flags: `HttpOnly`, `Secure`, `SameSite=Lax` o `Strict`
- [ ] CSRF protection en formularios (si usás cookies)
- [ ] Logout limpia sesión server-side
- [ ] Password reset con token de un solo uso, expiry corto

#### Si es API pública
- [ ] Documentación de endpoints (OpenAPI) sin info sensible
- [ ] Versionado de API
- [ ] Endpoints públicos vs autenticados claramente separados
- [ ] Backend en red privada, gateway al frente (ver skill `gateway-hardening`)

#### Si maneja PII / datos personales
- [ ] Inventario de PII (qué se recolecta, dónde, por qué)
- [ ] Consentimiento informado capturado y versionado
- [ ] Derechos ARCO implementados (acceso, rectificación, cancelación, oposición)
- [ ] DPO (Data Protection Officer) designado si aplica jurisdicción
- [ ] Política de retención y deletion
- [ ] Anonimización/pseudonimización donde sea posible

#### Si maneja pagos
- [ ] NO almacenás números de tarjeta (PCI-DSS)
- [ ] Tokenización vía provider (Stripe, MercadoPago)
- [ ] Webhooks de pago validados criptográficamente
- [ ] Idempotencia en operaciones de pago

#### Si tiene mobile app
- [ ] Tokens en secure storage (Keychain/Keystore), NO en AsyncStorage
- [ ] Certificate pinning si aplica
- [ ] Deep links validados
- [ ] No code obfuscation no es solución, es protección parcial
- [ ] App signing keys protegidas

### 4. Verificación de secretos

Ejecutar (o pedir al usuario):

```bash
# gitleaks contra el repo
gitleaks detect --source . --verbose

# Verificar que .env está en .gitignore
grep -q "^.env$" .gitignore && echo "OK" || echo "MISSING"

# Verificar que no hay env vars hardcodeadas en código
grep -rE "(api[_-]?key|secret|token|password)\s*=\s*['\"][a-zA-Z0-9]{20,}" \
  --include="*.go" --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules --exclude-dir=.git
```

### 5. Verificación de dependencias

```bash
# Go
govulncheck ./...

# Node
npm audit --production
# o
yarn audit --groups dependencies

# Python
pip-audit
```

### 6. Reporte

Producir o actualizar `docs/context/03-security.md` con:
- Threat model completo
- Checklist OWASP con estado por item
- Riesgos aceptados con justificación
- Mitigaciones implementadas
- Plan de mejora continua

## Severity guide

| Severidad | Definición | Acción |
|---|---|---|
| 🔴 CRITICAL | Exposición de datos sensibles, RCE, auth bypass | Bloquea gate. Resolver YA. |
| 🟠 HIGH | Vuln explotable con impacto serio | Bloquea gate. Resolver en sprint. |
| 🟡 MEDIUM | Vuln con impacto limitado o requiere condiciones | No bloquea pero documentar plan |
| 🟢 LOW | Hardening adicional | Sugerencia |

## Output esperado al usuario

```markdown
# Security Review — <fase / fecha>

## Resumen
- Threats identificados: N
- 🔴 CRITICAL: X (bloquean si no se resuelven)
- 🟠 HIGH: Y
- 🟡 MEDIUM: Z
- 🟢 LOW: W

## Findings críticos
[Detalle de cada CRITICAL/HIGH]

## OWASP Top 10 — estado
[Tabla con cada item]

## Recomendación
- [ ] Listo para avanzar
- [ ] Requiere resolver: ___
```
