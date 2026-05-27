---
name: phase-gate
description: Execute a formal phase gate review at the end of any project phase. Use when the user says "/phase-gate", "cerrar fase", "revisar lo hecho", or when an agent declares a phase complete. Invokes Critic and (for major gates) Devil's Advocate, produces a gate report, and asks for user approval.
---

# Phase Gate Execution

Este skill ejecuta un phase gate formal. Es el mecanismo de cierre/avance entre fases del proyecto.

## Cuándo usar

- Al final de cada fase (0, 1, 2, 3A, 3B, 4, 5, 6).
- Cuando el usuario invoca `/phase-gate N` o `/phase-gate`.
- Cuando un agente declara una fase completa.

## Procedimiento

### Paso 1: Identificar la fase actual

Leer `docs/context/` y determinar:
- ¿Cuál es la última fase con entregables completos?
- ¿Existe ya un gate report para esa fase?

Si el usuario no especificó número, asumir la fase más reciente sin gate cerrado.

### Paso 2: Invocar al Critic

Delegar al subagente `critic`:
- Pasarle la lista de archivos de la fase
- Pasarle el número de gate

El Critic produce `docs/context/gates/gate-N-<nombre>.md` siguiendo su template.

### Paso 3: Invocar Devil's Advocate (solo en gates mayores)

Para Gates 1, 2, 3B, 5: invocar al subagente `devils-advocate`.

Su output se inserta como sección dentro del gate report del Critic.

### Paso 4: el Doc Sentinel revisa documentación

Invocar a `sara-doc-sentinel` para asegurar que la documentación obligatoria de esa fase está completa y fresca.

### Paso 4a: Cross-check con inputs heredados del gate previo (OBLIGATORIO en todos los gates ≥ 1)

Para cada gate ≥ 1, el output principal de la fase debe incluir una sección **"Inputs heredados de gates previos"** como tabla:

```markdown
## Inputs heredados de gates previos

| Input ID | Descripción | Origen (gate) | Owner asignado | Estado |
|---|---|---|---|---|
| W-SEC-04 | `frontend/public/_headers` para security headers | Gate 3B (el Security Architect) | el DevOps & Platform agent (Fase 4) | ✅ ENTREGADO / ⏸️ DIFERIDO + ADR-NNNN |
| W-INFRA-02 | Backup PITR habilitado | Gate 4 (el DevOps & Platform agent) | el DevOps & Platform agent (Fase 4) | ✅ ENTREGADO |
| ... | ... | ... | ... | ... |
```

**Reglas duras**:
- Si la tabla **falta** → gate falla automáticamente con bloqueante "missing-inherited-inputs-table".
- Si un input está en estado `⏸️ DIFERIDO` **sin ADR asociado** → gate falla con bloqueante "deferred-without-adr".
- Si un input está marcado `✅ ENTREGADO` pero el Critic no puede verificarlo (no hay commit/archivo/test) → gate falla con bloqueante "false-completion-claim".

**El Critic usa esta tabla como matriz de verificación obligatoria.** No es opcional ni se autoasume completa.

#### Por qué este cambio

En splitwise-mini Gate 4, el DevOps & Platform agent declaró "sin sobre-entrega" pero **escondió 3-4h de trabajo heredado** (W-SEC-04, W-SEC-01 reasignado unilateralmente, CI con `continue-on-error`). El Critic lo detectó tarde. La tabla obligatoria fuerza el cross-check explícito.

### Paso 4b: Checks específicos por fase

Antes de presentar al usuario, validá los checks específicos de cada fase. Si alguno falla, **marcalo como bloqueante**:

#### Gate 0 (Discovery)
- [ ] `docs/context/00-discovery.md` existe
- [ ] `project_profile` está declarado en `CLAUDE.md` (si no, levantar warning, no bloqueante)
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
- [ ] **`mocks/` directorio existe con `index.html` navegable** (si el proyecto tiene UI)
- [ ] **Estados loading/empty/error mockeados** para pantallas críticas
- [ ] Usuario aprobó visualmente los mocks (no solo leyó el UX spec)

#### Gate 3B (Architecture)
- [ ] `docs/context/03-architecture.md` con monolito modular definido
- [ ] `docs/context/03-api-design.md` con OpenAPI specs
- [ ] `docs/context/03-security.md` con threat model
- [ ] `docs/context/03-cross-review-notes.md` existe como **single source of truth** de cross-review entre 3A y 3B
- [ ] Todos los items de `cross-review-notes.md` están en estado `resolved` o `risk_accepted` con ADR
- [ ] Sign-off al final del doc con iniciales de cada agente afectado
- [ ] ADRs presentes para desvíos del stack default

#### Gate 4 (DevOps)
- [ ] `docs/EXECUTION.md` actualizado con secciones local/staging/prod
- [ ] `.github/workflows/ci.yml` con secrets-scan + coverage check
- [ ] `docs/context/04-infra.md` con provider elegido y topología

#### Gate 5 (Development)
- [ ] Coverage ≥85% en código de negocio
- [ ] CI verde
- [ ] el Security Architect aprobó security review
- [ ] Tests E2E del happy path crítico

#### Gate 6 (Release)
- [ ] CHANGELOG.md actualizado
- [ ] Tag firmado
- [ ] Rollback plan documentado
- [ ] Release checklist ejecutado

### Paso 4c: Modelo de findings con enforcement (CRÍTICO)

**Cambio estructural desde Sesión 6**: cada finding del Critic debe tener un **enforcement_status**. Solo dos estados permiten cerrar el gate:

| Estado | Significado | Permite cerrar el gate |
|---|---|---|
| `RESOLVED` | Commit cierra el problema + hay tool que lo previene en el futuro | ✅ SÍ |
| `BLOCKED_BY_TOOL` | El problema sigue, pero hay un tool (CI fail, test fail, Makefile abort) que va a fallar mientras siga abierto | ✅ SÍ |
| `BLOCKED_BY_PROCESS` | Depende de que alguien "lo recuerde" o lo haga en una fase futura | ❌ NO |

**Regla dura**: si hay findings en `BLOCKED_BY_PROCESS`, el gate **no cierra**. Esto reemplaza el modelo viejo de "warnings con owner asignado y ETA", que en evidencia (splitwise-mini Gates 4→5) se demostró que los warnings se evaporan entre fases y reaparecen como bloqueantes más caros.

#### Formato del finding (template)

Cada finding del Critic se escribe así:

```yaml
- id: F-001
  finding: "Slog sin redactor de PII"
  severity: blocker | major | minor
  detected_by: Critic | DA | el Doc Sentinel | el Security Architect
  enforcement_status:
    state: RESOLVED | BLOCKED_BY_TOOL | BLOCKED_BY_PROCESS
    tool: "go test ./internal/platform/log/..."  # comando que falla si el problema reaparece
    commit: "abc1234"  # si state=RESOLVED, commit que lo cerró
    notes: "..."
  closing_at: "iter-2 mismo gate" | "RESOLVED en commit abc1234"  # NUNCA "fase siguiente"
```

#### Excepción: warnings genuinamente no-automatizables

Hay findings que **no** pueden tener tool (ej: "revalidar con usuarios", "consultar con legal externo", "verificar narrativa con stakeholder"). Para esos, se usa:

```yaml
- id: F-XXX
  finding: "Revalidar UCs con 3 usuarios reales"
  severity: minor
  enforcement_status:
    state: RISK_ACCEPTED
    adr: ADR-NNNN  # ADR explícito de "riesgo aceptado conscientemente"
    review_at: "Gate 6"  # gate donde se revisa
```

`RISK_ACCEPTED` permite cerrar el gate **solo si**:
- Hay un ADR escrito (no solo una promesa)
- El ADR identifica el riesgo + por qué se acepta + cuándo se revisa
- El próximo gate revisa el riesgo (si sigue abierto, escala)

#### Por qué este cambio importa

En splitwise-mini, el costo de un warning según donde se resuelve fue:

| Donde se resuelve | Multiplicador de costo |
|---|---|
| Mismo gate (donde se detectó) | 1× |
| Gate siguiente (escalado a bloqueante) | 4× |
| Producción (incidente real) | 10-15× + daño reputacional |

El enforcement mecánico hace que el costo siempre caiga en 1×.

### Paso 5: Presentar al usuario

Mostrar al usuario:
1. Resumen de findings ordenado por severidad
2. Devil's Advocate position (si aplicó)
3. Estado de docs según el Doc Sentinel
4. Pregunta concreta: 

```
El Gate N cerró con:
- 🔴 BLOQUEANTES: X
- 🟡 WARNINGS: Y
- 🟢 SUGERENCIAS: Z

¿Querés:
1. Aprobar y avanzar a Fase N+1?
2. Iterar para resolver bloqueantes?
3. Cambiar de dirección?
```

### Paso 6: Esperar decisión del usuario

NO avanzar automáticamente. El usuario decide. La decisión se registra en el gate report.

### Paso 7: Si se aprueba

- Marcar el gate report como APROBADO con fecha de decisión.
- Sugerir al usuario el siguiente paso (cuál fase, qué agente invocar primero).

### Paso 8: Si se itera

- Listar los bloqueantes con owner sugerido (qué agente debería resolverlos).
- No cerrar el gate.

## Reglas duras

- **NUNCA aprobar gate con bloqueantes abiertos** sin decisión explícita del usuario.
- **Si el gate es 3B (arquitectura)**: verificar explícitamente con el Security Architect que el gateway no tiene wildcards. Si tiene wildcards, agregar bloqueante automático.
- **Si el gate es 4 (DevOps)**: verificar con el Doc Sentinel que `docs/EXECUTION.md` existe con secciones de local + staging + prod.
- **Si el gate es 5 (dev)**: verificar coverage ≥85% (ejecutar comando de coverage si hay tests).

## Output esperado

Al usuario en chat:
1. Resumen ejecutivo del gate (3-5 bullets)
2. Tabla compacta de findings
3. Pregunta de decisión

En archivo:
- `docs/context/gates/gate-N-<nombre>.md` con el reporte completo

## Loop de iteración del Gate

Cuando un Gate cierra como "Iterar" (APROBADO CON OBSERVACIONES condicional, o BLOQUEADO), hay reglas claras de cómo se reabre:

### Si el usuario elige "Iterar"

1. **Listar acciones concretas con owner**: cada bloqueante se traduce en una acción con responsable (agente o usuario) y entregable verificable.

2. **Marcar el gate como ABIERTO PARA ITERACIÓN** en el frontmatter del reporte:
   ```yaml
   status: ITERATING
   blockers_open:
     - id: B1
       description: <texto del bloqueante>
       owner: <usuario | agente>
       evidence_required: <qué archivo o respuesta cierra esto>
       opened_at: YYYY-MM-DD
   blockers_resolved: []
   ```

3. **No reescribir los entregables de la fase anterior**: si el bloqueante requiere reescribir, eso es Camino B (cambiar de dirección). Si solo requiere agregar info, esa info va en archivos nuevos o anexos:
   - `docs/context/inputs/<topic>.md` para info externa recolectada
   - `docs/context/0X-discovery-addendum.md` para anexos al doc original
   - Updates inline solo si son correcciones obvias, no decisiones nuevas

### Cómo se reabre el Gate

El usuario invoca `/phase-gate N --reopen` (o equivalente conversacional: "reabrí Gate N", "verificá si los bloqueantes están resueltos"). El procedimiento es:

1. **Leer el gate report previo** y identificar la lista de `blockers_open`.

2. **Para cada bloqueante**:
   - Verificar si el `evidence_required` existe en el repo.
   - Si existe: marcar como `resolved` con fecha y referencia al archivo.
   - Si no existe: mantener `open`.

3. **Re-ejecutar checklist específico de la fase**: las cosas pueden haber cambiado más allá de los bloqueantes.

4. **Producir reporte de iteración**: `docs/context/gates/gate-N-<nombre>-iter-2.md` (iter-3, iter-4 si hace falta), NO sobreescribir el original.

5. **Decidir**:
   - Si TODOS los bloqueantes están resueltos: gate cierra como APROBADO.
   - Si algunos resueltos y otros no: actualizar el reporte, seguir iterando.
   - Si aparecieron bloqueantes NUEVOS durante la resolución: documentarlos como descubrimiento, no como falla.

### Cuándo se considera el Gate definitivamente cerrado

Solo cuando:
- Todos los bloqueantes están marcados como `resolved` con evidencia verificable.
- El Critic emite veredicto final APROBADO (no APROBADO CON OBSERVACIONES).
- El usuario aprueba explícitamente el avance.

A partir de ese momento, el reporte se marca como `status: CLOSED` y la siguiente fase puede arrancar.

### Si el usuario elige avanzar SIN resolver bloqueantes (escape hatch)

A veces el usuario decide saltar bloqueantes conscientemente. Eso es válido pero tiene reglas:

1. El gate se cierra como **APROBADO CON RIESGO ACEPTADO**, no como APROBADO limpio.
2. Los bloqueantes pendientes se inyectan como **input #1 de la siguiente fase**.
3. La siguiente fase debe abrir su trabajo abordando estos bloqueantes explícitamente antes de cualquier otro entregable.
4. El gate report registra textualmente: "Usuario decidió avanzar a Fase N+1 sin resolver bloqueantes B1, B2. Estos pasan como input crítico a Fase N+1. Critic deja registrado para auditabilidad futura."

### Quién dispara qué

| Acción | Quién |
|---|---|
| Detectar que un Gate quedó "abierto" mucho tiempo (≥7 días sin actividad) | el Doc Sentinel (doc-sentinel) en su próximo `/docs-audit` |
| Reabrir Gate cuando hay nueva evidencia | Usuario, vía `/phase-gate N --reopen` |
| Verificar bloqueantes resueltos | Critic (delegado por el skill) |
| Decidir cierre final | Usuario, basado en el reporte del Critic |
| Inyectar bloqueantes pendientes a la fase siguiente como input #1 | Skill `phase-gate` al cierre con escape hatch |
