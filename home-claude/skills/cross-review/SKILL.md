---
name: cross-review
description: Coordinate cross-review between agents working in parallel (specially UX/UI in Fase 3A and Architecture in Fase 3B). Detect conflicts before Gate. Auto-invoke when user says "cross review", "revisar entre fases", "compatibilidad UX arquitectura", "/cross-review".
---

# Cross-Review Coordination

Skill para coordinar trabajo paralelo entre fases (típicamente 3A y 3B) y detectar conflictos antes del gate.

## Cuándo usar

- Cuando el UX Designer y el Software Architect están trabajando en simultáneo (3A y 3B).
- Antes de cerrar Gate 3B si 3A todavía no cerró.
- Cuando una decisión de un agente tiene implicancias en el otro.
- En cualquier punto donde dos agentes trabajan sobre el mismo problema desde ángulos distintos.

## Conflictos típicos a detectar

### 3A (UX) ↔ 3B (Arquitectura)

| Decisión UX | Implicancia arquitectónica | Riesgo si no se coordinan |
|---|---|---|
| Updates en tiempo real en dashboard | WebSockets, polling, o SSE | Backend no soporta, tiene que reimplementarse |
| Búsqueda con autocompletado fluida | Índice especializado, endpoint dedicado | Latencia inaceptable |
| Offline-first mobile | Local storage strategy + sync | Sync conflicts no diseñados |
| Multi-tab consistency | Broadcast channel / shared state | Estado desincronizado |
| Notificaciones push | Push service, tokens, backend infra | Feature prometida sin soporte |
| Upload de archivos grandes | Multipart, presigned URLs, S3-style | Backend timeout |
| Edición colaborativa real-time | CRDT u OT, infraestructura específica | Tech debt enorme si se subestima |

### 3B (Arquitectura) ↔ 3A (UX)

| Decisión arquitectónica | Implicancia UX | Riesgo |
|---|---|---|
| Backend asíncrono para operación X | UX necesita loading states + notificación cuando termina | Frustración del usuario |
| Rate limit estricto en endpoint | UX no puede asumir submit rápido | Throttling sin feedback |
| Eventual consistency en lecturas | UX puede mostrar datos stale brevemente | Confusión del usuario |
| Multi-tenancy con isolation | UX necesita selector de workspace claro | UX colapsa entre tenants |

### 3A/3B ↔ 5 (Dev)

Cuando devs (el Backend Developer, el Frontend Developer, el Mobile Developer) empiezan a implementar, pueden encontrar problemas que ni el Software Architect ni el UX Designer vieron:
- Performance real diferente al esperado
- Componente UI imposible de implementar con stack elegido
- Endpoint mal diseñado descubierto al consumirlo
- Edge cases que solo emergen al construir

## Procedimiento

### Regla dura desde Sesión 6: SINGLE SOURCE OF TRUTH

**Toda la cross-review entre agentes paralelos vive en UN SOLO archivo**: `docs/context/03-cross-review-notes.md`.

NO se permite que:
- el UX Designer escriba items de cross-review en su `03-ux-spec.md` y el Software Architect responda en su `03-architecture.md`.
- Cada agente firme su parte por separado y "delegue al Gate la integración".
- Los items de cross-review se transfieran por mención cruzada en docs separados.

**Por qué**: en splitwise-mini Fase 3, el UX Designer y el Software Architect firmaron cross-review pero **nunca sincronizaron en un artefacto único**. El DA Gate 3 lo articuló: *"cada uno firmó su parte y delegó al Gate la integración"*. Resultado: la cross-review pasó "en papel", no en realidad.

### Estructura obligatoria de `03-cross-review-notes.md`

```markdown
# Cross-Review Notes — Fase 3A ↔ 3B

**Created**: YYYY-MM-DD
**Participantes**: el UX Designer, el UI Designer, el Software Architect, el Security Architect, el API Architect
**Status**: in_progress | closed

## Items de cross-review

### CR-001
- **Description**: Real-time updates en dashboard
- **Proposed by**: el UX Designer (3A)
- **Affects**: el Software Architect (3B), el API Architect (3B)
- **Status**: open | resolved | risk_accepted
- **Resolution**: [Si resolved: qué se decidió y dónde se documentó (ADR-NNNN)]
- **Signed off by**: [Iniciales de cada agente afectado cuando esté resolved]

### CR-002
...

## Sign-off final

- [ ] el UX Designer — confirmo que todos los CR de mi dominio están resolved
- [ ] el Software Architect — idem
- [ ] el UI Designer — idem
- [ ] el Security Architect — idem
- [ ] el API Architect — idem
```

### Paso 1: Identificar puntos de cruce

Listar los artifacts de cada fase relevante:
- 3A: `docs/context/03-ux-spec.md`, `docs/context/03-ui-spec.md`
- 3B: `docs/context/03-architecture.md`, `docs/context/03-api-design.md`, `docs/context/03-tech-stack.md`

Buscar **menciones** de decisiones que tocan al otro lado:
- En 3A: cualquier mención de "real-time", "offline", "search", "upload", "notifications", "sync"
- En 3B: cualquier mención de "async", "rate limit", "consistency", "BFF", "multi-tenant"

### Paso 2: Cada item al `03-cross-review-notes.md`

**TODOS los items detectados van al doc único**. Cada agente edita el mismo archivo, no anexos en sus propios docs.

### Paso 3: Resolución

Para cada conflicto:

1. **Convocar a ambos agentes** afectados.
2. **Presentar el conflicto** con datos: qué dice uno, qué dice el otro.
3. **Listar opciones de resolución**: opción A favorece UX, opción B favorece arquitectura, opción C es híbrida.
4. **Decisión del usuario** (con tradeoffs explícitos).
5. **Actualizar ambos artifacts** para que reflejen la decisión.
6. **Si la decisión es no trivial → crear ADR** en `docs/adr/`.

### Paso 4: Re-verificación post-resolución

Después de actualizar artifacts:
- ¿Las decisiones en `03-ux-spec.md` referencian las decisiones técnicas correctas?
- ¿Las decisiones en `03-architecture.md` soportan los flows propuestos?
- ¿No quedó información obsoleta o contradictoria?

### Paso 5: Sign-off

Cada agente involucrado firma explícitamente que su artifact está alineado con el otro:

```markdown
## Cross-review sign-off (3A ↔ 3B)

- [x] el UX Designer reviewed `03-architecture.md` and confirms no conflicts as of YYYY-MM-DD
- [x] el Software Architect reviewed `03-ux-spec.md` and confirms no conflicts as of YYYY-MM-DD
- [x] Resolved cross-issues documented in `docs/adr/`
```

## Output esperado

Archivo `docs/context/03-cross-review.md`:

```markdown
# 03 — Cross-Review (3A ↔ 3B)

**Date**: YYYY-MM-DD
**Participants**: el UX Designer, el UI Designer, el Software Architect, el Security Architect, el API Architect

## Issues detected and resolved

[Matriz de la Paso 2]

## ADRs created from this review

- ADR-NNNN: <decisión>
- ADR-NNNN: <decisión>

## Open issues (carry to Gate 3B)

- ...

## Sign-off

[Sign-off del Paso 5]
```

## Reglas duras

1. **Sin cross-review NO se cierra Gate 3B** si 3A produjo algo no trivial.
2. **Cualquier conflicto detectado bloquea hasta resolverse** o documentarse como riesgo aceptado.
3. **Las decisiones de cross-review se materializan en ADRs**, no quedan en chat.
4. **Si el conflicto requiere cambiar un artifact mayor**, hay que re-firmar.

## Anti-patterns

- **Cross-review "tardío"**: hacerlo solo al cierre = el cambio es caro. Hacerlo continuo = barato.
- **Cross-review verbal**: si no quedó escrito, no pasó.
- **Asumir que el otro agente ya pensó X**: explicitalo.
- **Cross-review entre 2 agentes solos**: si toca seguridad o costo, incluir a el Security Architect o el Cost Estimator.
