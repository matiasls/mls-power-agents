---
name: phase-gate
description: Execute a formal phase gate review at the end of any project phase. Includes the relevance filter (MVP alignment per artifact), Plan B addendums (applying Devil's Advocate recortes), and cross-review coordination between parallel phases (3A↔3B). Invokes Critic and (for major gates) Devil's Advocate, produces a gate report, and asks for user approval. Auto-invoke when user says "/phase-gate", "cerrar fase", "revisar lo hecho", "cross review", "compatibilidad UX arquitectura", "filtro de relevancia", "está calibrado al MVP", "aplicar plan B", "addendum plan B".
---

# Phase Gate Execution

Este skill ejecuta un phase gate formal. Es el mecanismo de cierre/avance entre fases del proyecto. Incluye tres mecanismos anti-patrones integrados: **filtro de relevancia** (contra sobre-entrega), **Plan B por addendum** (contra relanzamiento de agentes) y **cross-review** (contra integración "en papel" entre fases paralelas).

## Cuándo usar

- Al final de cada fase (0, 1, 2, 3A, 3B, 4, 5, 6).
- Cuando el usuario invoca `/phase-gate N` o `/phase-gate`.
- Cuando un agente declara una fase completa.
- El cross-review (sección abajo) se usa DURANTE las fases paralelas, no solo al cierre.

## Procedimiento

### Paso 1: Identificar la fase actual

Leer `docs/context/` y determinar cuál es la última fase con entregables completos y si ya existe gate report. Si el usuario no especificó número, asumir la fase más reciente sin gate cerrado.

### Paso 2: Invocar al Critic

Delegar al subagente `critic` con la lista de archivos de la fase y el número de gate. El Critic produce `docs/context/gates/gate-N-<nombre>.md` siguiendo su template.

### Paso 3: Invocar Devil's Advocate (solo en gates mayores)

Para Gates 1, 2, 3B, 5: invocar al subagente `devils-advocate`. Su output se inserta como sección dentro del gate report del Critic. Si el DA produce un **Plan B con recortes**, aplicarlo vía la sección "Plan B por addendum" de abajo.

### Paso 4: El Doc Sentinel revisa documentación

Invocar a `doc-sentinel` para asegurar que la documentación obligatoria de esa fase está completa y fresca.

### Paso 4a: Cross-check con inputs heredados del gate previo (OBLIGATORIO en todos los gates ≥ 1)

El output principal de la fase debe incluir una sección **"Inputs heredados de gates previos"** como tabla:

```markdown
## Inputs heredados de gates previos

| Input ID | Descripción | Origen (gate) | Owner asignado | Estado |
|---|---|---|---|---|
| W-SEC-04 | `frontend/public/_headers` para security headers | Gate 3B (Security Architect) | DevOps (Fase 4) | ✅ ENTREGADO / ⏸️ DIFERIDO + ADR-NNNN |
```

**Reglas duras**:
- Si la tabla **falta** → gate falla con bloqueante "missing-inherited-inputs-table".
- Input `⏸️ DIFERIDO` **sin ADR asociado** → gate falla con bloqueante "deferred-without-adr".
- Input `✅ ENTREGADO` que el Critic no puede verificar (no hay commit/archivo/test) → bloqueante "false-completion-claim".

**El Critic usa esta tabla como matriz de verificación obligatoria.** Evita que los agentes técnicos se salteen compromisos del gate previo para "no sobre-entregar".

### Paso 4b: Checks específicos por fase

Si alguno falla, **marcarlo como bloqueante**:

#### Gate 0 (Discovery)
- [ ] `docs/context/00-discovery.md` existe
- [ ] `project_profile` declarado en `CLAUDE.md` (si no: warning, no bloqueante)
- [ ] Hipótesis listadas si `primary_goal != build_solution`

#### Gate 1 (Problem Definition)
- [ ] `docs/context/01-functional-spec.md` con UCs y BRs numerados
- [ ] Glosario presente
- [ ] Cada UC tiene actor + flow + pre/post conditions

#### Gate 2 (Product Decisions)
- [ ] `docs/context/02-mvp-scope.md` con features dentro/fuera explícitas
- [ ] `docs/context/02-cost-estimate.md` (si el Cost Estimator se activó)
- [ ] Kill criteria definidos si `type != personal`

#### Gate 3A (UX/UI)
- [ ] `docs/context/03-ux-spec.md` con flows mapeados
- [ ] `docs/context/03-ui-spec.md` con tokens
- [ ] **`mocks/` con `index.html` navegable** (si el proyecto tiene UI)
- [ ] **Estados loading/empty/error mockeados** para pantallas críticas
- [ ] Usuario aprobó visualmente los mocks

#### Gate 3B (Architecture)
- [ ] `docs/context/03-architecture.md` con monolito modular definido
- [ ] `docs/context/03-api-design.md` con OpenAPI specs
- [ ] `docs/context/03-security.md` con threat model
- [ ] `docs/context/03-cross-review-notes.md` existe como single source of truth (ver sección Cross-review)
- [ ] Todos los items de cross-review en `resolved` o `risk_accepted` con ADR
- [ ] Sign-off con iniciales de cada agente afectado
- [ ] ADRs presentes para desvíos del stack default

#### Gate 4 (DevOps)
- [ ] `docs/EXECUTION.md` actualizado con secciones local/staging/prod
- [ ] `.github/workflows/ci.yml` con secrets-scan + coverage check
- [ ] `docs/context/04-infra.md` con provider elegido y topología

#### Gate 5 (Development)
- [ ] Coverage ≥85% en código de negocio
- [ ] CI verde
- [ ] Security Architect aprobó security review
- [ ] Tests E2E del happy path crítico

#### Gate 6 (Release)
- [ ] CHANGELOG.md actualizado
- [ ] Tag firmado
- [ ] Rollback plan documentado
- [ ] Release checklist ejecutado

### Paso 4c: Modelo de findings con enforcement (CRÍTICO)

Cada finding del Critic debe tener un **enforcement_status**. Solo estos estados permiten cerrar el gate:

| Estado | Significado | Permite cerrar |
|---|---|---|
| `RESOLVED` | Commit cierra el problema + hay tool que lo previene a futuro | ✅ |
| `BLOCKED_BY_TOOL` | El problema sigue, pero un tool (CI fail, test fail, Makefile abort) falla mientras siga abierto | ✅ |
| `BLOCKED_BY_PROCESS` | Depende de que alguien "lo recuerde" en una fase futura | ❌ |

**Regla dura**: con findings en `BLOCKED_BY_PROCESS`, el gate **no cierra**. Los warnings "con owner y ETA" se evaporan entre fases y reaparecen como bloqueantes ~4× más caros; el enforcement mecánico mantiene el costo en 1×.

Formato del finding:

```yaml
- id: F-001
  finding: "Slog sin redactor de PII"
  severity: blocker | major | minor
  detected_by: Critic | DA | Doc Sentinel | Security Architect
  enforcement_status:
    state: RESOLVED | BLOCKED_BY_TOOL | BLOCKED_BY_PROCESS
    tool: "go test ./internal/platform/log/..."  # comando que falla si reaparece
    commit: "abc1234"  # si RESOLVED
  closing_at: "iter-2 mismo gate" | "RESOLVED en commit abc1234"  # NUNCA "fase siguiente"
```

**Excepción — findings genuinamente no-automatizables** (ej: "revalidar con usuarios", "consultar legal externo"):

```yaml
  enforcement_status:
    state: RISK_ACCEPTED
    adr: ADR-NNNN     # ADR explícito de riesgo aceptado
    review_at: "Gate 6"
```

`RISK_ACCEPTED` permite cerrar **solo si** hay ADR escrito (riesgo + por qué se acepta + cuándo se revisa) y el próximo gate lo revisa.

### Paso 5: Presentar al usuario

1. Resumen de findings ordenado por severidad
2. Devil's Advocate position (si aplicó)
3. Estado de docs según el Doc Sentinel
4. Pregunta concreta:

```
El Gate N cerró con:
- 🔴 BLOQUEANTES: X | 🟡 WARNINGS: Y | 🟢 SUGERENCIAS: Z

¿Querés: 1. Aprobar y avanzar | 2. Iterar | 3. Cambiar de dirección?
```

### Paso 6: Esperar decisión del usuario

NO avanzar automáticamente. La decisión se registra en el gate report.

### Paso 7: Si se aprueba

Marcar el gate report como APROBADO con fecha. Sugerir el siguiente paso (cuál fase, qué agente primero).

### Paso 8: Si se itera

Listar los bloqueantes con owner sugerido. No cerrar el gate. Ver "Loop de iteración" abajo.

---

## Filtro de relevancia (obligatorio para artefactos de Fase 3 y 4)

En fases con ≥2 agentes paralelos, cada especialista tiende a sobre-entregar en su dominio (22 amenazas cuando 5 son reales, 8 módulos cuando 4 son boundaries reales). El filtro obliga a justificar la **conexión al MVP**, no la rigurosidad del rigor.

Cada agente especialista agrega al final de su artefacto principal:

```markdown
## Filtro de relevancia

### MVP declarado (cita LITERAL de `02-mvp-scope.md`)
- Métrica primaria de éxito / Volumen esperado / Kill criteria / Out of scope: <copias exactas>

### Cómo este entregable se conecta al MVP
| Elemento del artefacto | Cómo soporta al MVP declarado |
|---|---|

### Excluí explícitamente (considerado y descartado)
| Item descartado | Razón | Cuándo se revisita |
|---|---|---|

### Sobre-entrega declarada
- <Item en zona gris>: incluido por defensividad. Si no aplica, eliminalo y firmá.
```

**Reglas duras**:
- **Sin filtro de relevancia, el artefacto no se acepta en el gate.** Bloqueante automático.
- **Debe citar literalmente** del `02-mvp-scope.md`. "Es necesario para el sistema" no califica.
- **"Excluí explícitamente" no puede estar vacía**: si no se descartó nada, hay sobre-entrega oculta.
- Items en zona gris se marcan, no se ocultan.
- No se usan caps numéricos ("máx 5 amenazas"): el problema real es output desconectado del MVP, no "demasiado output".

El Critic valida el filtro en el gate; el DA lo ataca preguntando: *"de lo INCLUIDO, ¿qué pertenece en realidad a 'Excluí explícitamente'? ¿Hay defensividad disfrazada de rigor?"*

---

## Plan B por addendum (cuando el DA propone recortes)

Cuando el Devil's Advocate produce un Plan B con recortes, los agentes originales **NO se relanzan desde cero**. Cada recorte lo revisa **el agente original** y lo aplica como addendum firmado sobre su artefacto. Esto preserva la voz del especialista, evita el ciclo de re-sobre-entrega y deja trazabilidad.

El agente agrega al final de su artefacto:

```markdown
## Addendum: Recortes post-DA Plan B
**Fecha**: YYYY-MM-DD | **Gate**: N | **Plan B**: `docs/context/gate-N-da-plan-b.md`

### Recortes aplicados
| ID | Item recortado | Razón DA | Acción aplicada | Firmado |
|---|---|---|---|---|

### Recortes RECHAZADOS por el agente original
| ID | Item | Por qué NO acepta | Próximo paso |
|---|---|---|---|

### Items en zona gris (decisión del usuario)
| ID | Item | Pro-recorte | Contra-recorte |
|---|---|---|---|
```

**Reglas duras**:
- **NO relanzar agentes** para aplicar Plan B. Solo addendum sobre el artefacto original.
- **El agente original puede RECHAZAR un recorte** con argumento escrito. El DA no tiene decisión final.
- **El usuario resuelve discrepancias** (no existe un "coordinator" entre pares).
- **Trazabilidad obligatoria**: cada recorte con ID, razón del DA, acción, firma.

El Critic verifica en el gate: cada recorte revisado por su agente, addendums firmados, discrepancias resueltas por el usuario, ningún item del Plan B sin tratar.

---

## Cross-review entre fases paralelas (3A ↔ 3B)

Cuando agentes trabajan en paralelo (típicamente UX/UI en 3A y arquitectura en 3B), la integración NO se delega al gate: se coordina continuamente en **UN SOLO archivo**: `docs/context/03-cross-review-notes.md`. No se permite que cada agente firme su parte en su propio doc y "delegue al Gate la integración" — así la cross-review pasa en papel, no en realidad.

**Conflictos típicos a detectar**:
- UX → Arquitectura: real-time updates (¿WebSockets/SSE?), búsqueda con autocompletado (¿índice dedicado?), offline-first (¿sync strategy?), notificaciones push, upload de archivos grandes.
- Arquitectura → UX: operaciones asíncronas (necesitan loading states + notificación), rate limits (feedback de throttling), eventual consistency (datos stale visibles).
- Buscar en los artefactos menciones de: "real-time", "offline", "search", "upload", "notifications", "sync", "async", "rate limit", "consistency", "multi-tenant".

**Estructura obligatoria del archivo**:

```markdown
# Cross-Review Notes — Fase 3A ↔ 3B
**Participantes**: [agentes] | **Status**: in_progress | closed

### CR-001
- **Description**: Real-time updates en dashboard
- **Proposed by**: UX Designer (3A)
- **Affects**: Software Architect (3B), API Architect (3B)
- **Status**: open | resolved | risk_accepted
- **Resolution**: [qué se decidió y dónde (ADR-NNNN)]
- **Signed off by**: [iniciales de cada agente afectado]

## Sign-off final
- [ ] <cada agente> — confirmo que todos los CR de mi dominio están resolved
```

**Resolución de cada conflicto**: presentar el conflicto con datos → listar opciones (A favorece UX, B favorece arquitectura, C híbrida) → decisión del usuario con tradeoffs → actualizar AMBOS artefactos → si no es trivial, ADR.

**Reglas duras**:
- **Sin cross-review no se cierra Gate 3B** si 3A produjo algo no trivial.
- Conflicto detectado bloquea hasta resolverse o documentarse como riesgo aceptado.
- Las decisiones se materializan en ADRs, no quedan en chat.
- Cross-review continuo (barato), no solo al cierre (caro). Si no quedó escrito, no pasó.
- Si el conflicto toca seguridad o costo, incluir al Security Architect o Cost Estimator.

---

## Reglas duras del gate

- **NUNCA aprobar gate con bloqueantes abiertos** sin decisión explícita del usuario.
- **Gate 3B**: verificar con el Security Architect que el gateway no tiene wildcards. Wildcards → bloqueante automático.
- **Gate 4**: verificar con el Doc Sentinel que `docs/EXECUTION.md` existe con local + staging + prod.
- **Gate 5**: verificar coverage ≥85% (ejecutar el comando de coverage si hay tests).

## Output esperado

Al usuario: resumen ejecutivo (3-5 bullets), tabla compacta de findings, pregunta de decisión.
En archivo: `docs/context/gates/gate-N-<nombre>.md` con el reporte completo.

## Loop de iteración del Gate

### Si el usuario elige "Iterar"

1. **Listar acciones concretas con owner**: cada bloqueante → acción con responsable y entregable verificable.
2. **Marcar el gate como ABIERTO PARA ITERACIÓN** en el frontmatter del reporte:
   ```yaml
   status: ITERATING
   blockers_open:
     - id: B1
       description: <texto>
       owner: <usuario | agente>
       evidence_required: <qué archivo o respuesta cierra esto>
   ```
3. **No reescribir los entregables de la fase**: si el bloqueante requiere reescritura, eso es "cambiar de dirección". Info nueva va en `docs/context/inputs/<topic>.md` o `docs/context/0X-<doc>-addendum.md`.

### Cómo se reabre

El usuario invoca `/phase-gate N --reopen` (o "verificá si los bloqueantes están resueltos"):

1. Leer el gate report previo y los `blockers_open`.
2. Por cada bloqueante: verificar si `evidence_required` existe en el repo → `resolved` con fecha y referencia, o sigue `open`.
3. Re-ejecutar el checklist específico de la fase.
4. Producir `gate-N-<nombre>-iter-2.md` (iter-3, ...), NO sobreescribir el original.
5. Todos resueltos → APROBADO. Bloqueantes nuevos descubiertos → documentar como descubrimiento, no como falla.

### Cierre definitivo

Solo cuando: todos los bloqueantes `resolved` con evidencia verificable + Critic emite APROBADO + el usuario aprueba explícitamente. El reporte pasa a `status: CLOSED`.

### Escape hatch: avanzar SIN resolver bloqueantes

Válido pero con reglas:
1. El gate cierra como **APROBADO CON RIESGO ACEPTADO**.
2. Los bloqueantes pendientes se inyectan como **input #1 de la siguiente fase**, que debe abordarlos antes de cualquier otro entregable.
3. El gate report registra textualmente la decisión del usuario para auditabilidad.

### Quién dispara qué

| Acción | Quién |
|---|---|
| Detectar gate "abierto" ≥7 días sin actividad | Doc Sentinel en su próximo `/docs-audit` |
| Reabrir gate con nueva evidencia | Usuario, vía `/phase-gate N --reopen` |
| Verificar bloqueantes resueltos | Critic (delegado por el skill) |
| Decidir cierre final | Usuario |
| Inyectar bloqueantes a la fase siguiente | Skill `phase-gate` al cierre con escape hatch |
