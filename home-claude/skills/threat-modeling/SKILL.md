---
name: threat-modeling
description: Apply STRIDE threat modeling to a system architecture. Use in Fase 3B by the Security Architect. Auto-invoke when user says "threat model", "STRIDE", "amenazas", "/threat-model".
---

# Threat Modeling (STRIDE)

Skill detallado de threat modeling. el Security Architect lo aplica al cierre de Fase 3B sobre la arquitectura propuesta. La filosofía: identificar amenazas TEMPRANO cuesta menos que mitigarlas después.

## Marco: STRIDE

| Letra | Categoría | Pregunta core |
|---|---|---|
| **S** | Spoofing | ¿Puede alguien hacerse pasar por otro? |
| **T** | Tampering | ¿Puede alguien modificar datos en tránsito o reposo? |
| **R** | Repudiation | ¿Puede alguien negar haber hecho una acción? |
| **I** | Information Disclosure | ¿Puede alguien ver datos que no debería? |
| **D** | Denial of Service | ¿Puede alguien tumbar el servicio? |
| **E** | Elevation of Privilege | ¿Puede alguien obtener permisos no autorizados? |

## Procedimiento

### Paso 1: Mapear assets críticos

¿Qué hay para proteger? Para cada asset:

| Asset | Descripción | Por qué importa | Worst case si se compromete |
|---|---|---|---|

Ejemplos típicos:
- Credenciales de usuarios
- Datos PII de clientes
- Tokens de API a terceros
- Modelos / IP propietaria
- Bases de datos
- Logs con info sensible
- Comunicaciones internas

### Paso 2: Mapear trust boundaries

Dibujar (en ASCII o describir) dónde están los **trust boundaries** del sistema:

```
[Internet] ──┬──> [Gateway] ──> [Backend en red privada] ──> [DB]
             │      |
             │      └── Boundary 1: gateway (auth + rate limit)
             │
             └── Boundary 2: red privada (mTLS recomendado)

[Backend] ──> [APIs externas] (Nosis, Stripe, etc.)
              Boundary 3: cada API externa es un trust boundary
```

Cada cruzar de boundary es un punto donde aplicar controles.

### Paso 3: Para cada componente + trust boundary, aplicar STRIDE

Tabla por amenaza:

| ID | Asset / Componente | STRIDE | Amenaza específica | Likelihood | Impact | Severidad | Mitigación | Mitigation owner |
|---|---|---|---|---|---|---|---|---|

Severidad = matriz Likelihood × Impact:

| | Likelihood: Low | Medium | High |
|---|---|---|---|
| **Impact: Low** | Low | Low | Medium |
| **Impact: Medium** | Low | Medium | High |
| **Impact: High** | Medium | High | Critical |

### Paso 4: Ejemplos de amenazas típicas por categoría

**Spoofing**
- Atacante usa credenciales robadas en login (mitigación: rate limit + MFA opcional)
- Atacante hace spoof de header `X-Forwarded-For` (mitigación: trust solo del gateway)
- Atacante usa JWT robado (mitigación: short TTL + refresh + httpOnly cookies)
- Phishing del usuario (mitigación: educación + DMARC en email + 2FA)

**Tampering**
- Atacante modifica request en tránsito (mitigación: TLS 1.2+)
- Atacante modifica datos en DB con acceso directo (mitigación: DB privada + auditoría)
- Atacante modifica respuestas con MITM (mitigación: TLS + cert pinning en mobile)
- Atacante modifica logs para borrar evidencia (mitigación: logs append-only, off-host)

**Repudiation**
- Usuario niega haber hecho una transacción (mitigación: audit log con auth context)
- Admin niega haber cambiado configuración (mitigación: audit log de admin actions)
- Sistema no puede probar que hubo notificación (mitigación: logs de envío con delivery receipts)

**Information Disclosure**
- Error messages exponen stack traces o internals (mitigación: sanitize en prod)
- IDs enumerables exponen datos no autorizados (mitigación: UUIDs + authz a nivel de recurso)
- Logs contienen PII / tokens (mitigación: scrubbing en pipeline de logs)
- Backups sin cifrar accesibles (mitigación: encryption + access control)
- Caché compartida entre usuarios (mitigación: keys de caché incluyen user_id)
- Headers exponen versiones / tech stack (mitigación: `-Server`, `-X-Powered-By`)

**Denial of Service**
- Endpoint costoso sin rate limit (mitigación: rate limit por endpoint)
- Upload sin tamaño máximo (mitigación: límite explícito)
- Query SQL no paginada con N gigante (mitigación: paginación obligatoria)
- Regex catastrófica (ReDoS) en input (mitigación: validar regex / no usar user input en regex)
- Recursión sin límite (mitigación: max depth)
- Connection pool saturado por slow queries (mitigación: timeouts + pool size)

**Elevation of Privilege**
- IDOR (Insecure Direct Object Reference): cambiar ID en URL accede a recurso ajeno (mitigación: authz a nivel recurso)
- Path traversal en file ops (mitigación: validate paths + use safe APIs)
- Command injection en exec (mitigación: NUNCA shell con user input; usar APIs estructuradas)
- Privilege escalation por endpoint admin sin authz (mitigación: deny by default + tests)
- Sub-domain takeover (mitigación: monitor DNS records + scope cookies a domain exacto)

### Paso 5: Priorizar y mitigar

1. Listar todas las amenazas identificadas
2. Ordenar por severidad descendente (Critical → High → Medium → Low)
3. Para cada CRITICAL: mitigación obligatoria antes de Gate 3B
4. Para cada HIGH: mitigación obligatoria antes de Gate 5
5. Para MEDIUM/LOW: roadmap de mitigación + riesgo aceptado documentado

### Paso 6: Riesgos aceptados (con justificación)

Amenazas que NO se mitigan en MVP, con justificación:

| Threat ID | Por qué se acepta | Cuándo se revisita |
|---|---|---|
| T-XXX | Costo de mitigación > impacto esperado en MVP | Fase v0.2 |

Cada uno firmado por usuario (no por el Security Architect solo).

## Output esperado

Sección dentro de `docs/context/03-security.md`:

```markdown
## Threat Model (STRIDE)

### Assets críticos
[Tabla]

### Trust boundaries
[Descripción / diagrama]

### Threats identificados
[Tabla completa con ID, severidad, mitigación, owner]

### Riesgos aceptados conscientemente
[Tabla con justificación]

### Re-evaluation triggers
Esta sección se re-evalúa cuando:
- Se agrega un nuevo trust boundary (nueva integración externa)
- Cambia el modelo de auth
- Se procesa un nuevo tipo de PII / dato sensible
- Hay un incident relacionado con seguridad
- Cambia regulación aplicable
```

## Anti-patterns

1. **Threat model genérico, no específico al proyecto**: si tu threat model sirve para cualquier app, es inútil.
2. **Severidad inflada para mostrarse riguroso**: si todo es CRITICAL, nada es CRITICAL.
3. **Mitigaciones vagas**: "implementar seguridad" no es mitigación. "Rate limit 60 req/min por IP en /api/v1/scores" sí.
4. **Solo defensa, no detección**: las mitigaciones incluyen detección + respuesta, no solo prevención.
5. **No re-evaluar nunca**: threat model es vivo. Re-revisar al menos por release mayor.

## Checklist final

- [ ] Assets identificados con worst case
- [ ] Trust boundaries explicitados
- [ ] Para cada componente, las 6 categorías STRIDE consideradas
- [ ] Severidad asignada con matriz Likelihood × Impact
- [ ] Cada Critical / High tiene mitigación + owner + plazo
- [ ] Cada Medium / Low tiene decisión (mitigar o aceptar)
- [ ] Riesgos aceptados firmados por usuario
- [ ] Triggers de re-evaluación documentados
