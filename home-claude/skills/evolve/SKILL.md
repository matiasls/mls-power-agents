---
name: evolve
description: Evolve an existing project (post-Fase 6) by adding a feature, fixing a hotfix, refactoring a module, or migrating technology. Lighter than greenfield kickoff. Auto-invoke when user says "evolucionar", "agregar feature", "hotfix", "refactor", "migración", "nueva funcionalidad", "/evolve". Required modes: feature | hotfix | refactor | migration.
---

# Evolve

Skill orquestador para evolucionar proyectos que ya pasaron Fase 6. **Reusa los 19 agentes existentes** invocándolos con un orden y profundidad distinta al flujo greenfield.

## Por qué este skill existe

El flujo greenfield (Fase 0 → 6) aplicado a un producto vivo es overhead masivo (¿discovery para un toggle? ¿Gate 0 para un hotfix?). Este skill provee 4 modos calibrados a 4 escenarios reales de evolución.

## Decisión de modo

El usuario invoca `/evolve` y elige uno de 4 modos:

| Modo | Cuándo usar | Tiempo típico | Riesgo si confundís |
|---|---|---|---|
| `feature` | Agregar funcionalidad nueva al producto | 1-5 días | Confundir con hotfix → bug + tests insuficientes |
| `hotfix` | Bug crítico en producción que duele | <24h | Confundir con feature → over-engineering del fix |
| `refactor` | Mejorar código sin cambios funcionales | 0.5-3 días | Confundir con feature → cambia comportamiento |
| `migration` | Cambio tecnológico mayor (DB, runtime, libs core) | 1-4 semanas | Subestimar → proyecto roto |

**El usuario elige. Si dudás, preguntás.** No asumir automáticamente "es un hotfix" porque suena urgente.

## Pre-condiciones (todas los modos)

Antes de cualquier modo:
1. Verificar que el proyecto tenga `docs/context/STATE.md` con fase ≥6 (released).
2. Leer `CLAUDE.md` para el `project_profile`.
3. Confirmar que hay commit de referencia "last known good" (idealmente último tag de release).
4. Crear branch específica: `evolve/<modo>/<descripción-corta>` (ej: `evolve/feature/multi-currency`).

Si alguna falla, frenás y resolvés antes de avanzar.

---

## Modo 1: `feature`

**Cuándo**: agregar funcionalidad nueva planeada al producto vivo.

### Procedimiento

#### 1. Mini-discovery (el Business Analyst, NO el Product Discovery agent)

el Business Analyst es la owner. el Product Discovery agent no se invoca: el problema ya está validado (existe el producto).

el Business Analyst produce `docs/context/features/F-NNN-<nombre>.md`:

```markdown
# Feature F-NNN: <nombre>

**Status**: PROPOSED | IN_PROGRESS | RELEASED
**Tipo**: new_feature
**Owner**: <nombre>
**Created**: YYYY-MM-DD

## Por qué (1-3 frases)
[Demanda de usuarios, evolución natural del producto, requisito legal, etc.]

## Spec funcional

### Nuevos UCs (numeración continua a `01-functional-spec.md`)
- UC-NNN: ...

### UCs existentes afectados
- UC-XXX: cómo cambia

### BRs nuevas / modificadas
- BR-NNN: ...

## Cómo se inserta en el sistema existente

(el Software Architect escribe esta sección, no el Business Analyst)

- Módulos afectados: <lista>
- Endpoints nuevos / modificados: <lista>
- Tablas DB nuevas / modificadas: <lista>
- Cambios visuales (UI): <lista>
- Migraciones de datos requeridas: <lista>

## Tests adicionales

- Unit nuevos / Integration / E2E: ...

## Decisiones

- ADR-NNN si hay decisión técnica no obvia
```

#### 2. Diseño liviano (el Software Architect + el agente que toque)

Según qué toca la feature:
- **Solo backend**: el Software Architect + el API Architect + el Backend Developer
- **Solo frontend**: el Frontend Developer (+ el UI Designer si hay cambios visuales)
- **Full-stack**: el Software Architect + el API Architect + el Backend Developer + el Frontend Developer
- **Mobile**: el Mobile Developer

NO se invoca el UX Designer / UI Designer para flow completo si la feature reusa patrones existentes. Sí se invocan si la feature introduce un patrón nuevo.

Cada agente actualiza el archivo `F-NNN-<nombre>.md` con su sección.

#### 3. Implementación

Devs implementan en la branch `evolve/feature/<descripción>`.

**Reglas duras**:
- Tests del código nuevo cumplen coverage ≥85%.
- No bajar coverage del módulo afectado.
- Si toca seguridad/auth/payments: el Security Architect firma antes del PR.

#### 4. Mini-gate

Hay un **mini-gate feature** (no es Gate completo) con:
- [ ] CI verde
- [ ] Coverage no bajó
- [ ] Smoke test de UCs nuevos en `docker-compose up`
- [ ] Smoke test de UCs existentes afectados (no rompimos nada)
- [ ] CHANGELOG actualizado en sección `[Unreleased]`
- [ ] Si toca DB: migración up Y down testeadas

#### 5. Release (el Release Manager)

el Release Manager aplica `release-checklist` (skill existente) en versión `MINOR` (`vX.(Y+1).0`).

### Tiempo objetivo del modo feature

Chicas (1 UC, sin DB): 1-2 días. Medianas (3-5 UCs, alguna migración): 3-5 días. Grandes (10+ UCs, cambios estructurales): romper en sub-features o aplicar modo `migration`.

---

## Modo 2: `hotfix`

**Cuándo**: bug crítico en producción que duele. Velocidad importa más que ceremonia.

### Reglas duras del modo hotfix

1. **NO hay discovery, NO hay spec funcional formal**. La spec es "el bug X mata el flujo Y".
2. **Una sola branch**: `hotfix/<descripción>` desde el tag del último release.
3. **El fix debe ser quirúrgico**: la PR no debe tocar más de lo necesario.
4. **Tests obligatorios**: test que reproduce el bug, test que demuestra que el fix lo resuelve.
5. **Post-mortem es obligatorio**, no opcional. Aunque sea 1 página.

### Procedimiento

#### 1. Disparar alarma (vos como usuario)

Vos (o el Security Architect si es security incident) escribís `docs/runbooks/incidents/INC-NNN-<fecha>.md`:

```markdown
# Incident INC-NNN

**Detectado**: <timestamp>
**Severidad**: P0 | P1 | P2
**Reportado por**: <usuario o monitoring>

## Qué pasa
[síntoma observable]

## Impacto
- Usuarios afectados: <cuantos>
- Funcionalidad afectada: <cuál>
- Pérdida estimada: <USD / reputación / regulatorio>

## Repro pasos
1. ...

## Hipótesis causa raíz
[de qué sospechás antes de investigar]
```

#### 2. el Security Architect + dev correspondiente investigan (1-4h)

- Confirmar repro
- Identificar causa raíz
- Decidir fix (mínimo posible)

Si el fix es trivial (1 línea): proceder. Si no es trivial: considerar si realmente es hotfix o requiere modo `feature` (rompiendo el flujo).

#### 3. Fix + tests

Código del fix:
- ≤50 líneas idealmente
- Test que reproduce el bug (falla antes del fix, pasa después)
- Test que evita regresión

#### 4. Mini-gate hotfix (acelerado)

- [ ] Test del bug pasa
- [ ] CI verde
- [ ] No degradan otros tests
- [ ] El fix es mínimo (revisar diff)
- [ ] el Security Architect firmó (si es security)

NO se exige: discovery, spec funcional, sign-off de panel completo, ADR (a menos que el fix introduzca una decisión técnica nueva).

#### 5. Release patch

el Release Manager aplica `release-checklist` en versión `PATCH` (`vX.Y.(Z+1)`), pero con el rollback plan de hotfix:

```markdown
## Rollback hotfix vX.Y.(Z+1)

Trigger automático si:
- Error rate de la funcionalidad fixeada empeora vs baseline
- Aparecen nuevos errors no relacionados al bug original

Procedure: `git revert <commit-fix>` + redeploy + comunicar.
```

#### 6. Post-mortem (obligatorio, dentro de 7 días)

`docs/runbooks/incidents/INC-NNN-postmortem.md`:

```markdown
# Post-mortem INC-NNN

**Duración del incidente**: <minutos/horas>
**Severidad**: P0/P1/P2
**Impacto medido**: <usuarios afectados, requests fallidos, etc.>

## Timeline
- HH:MM detectado por <quien/qué>
- HH:MM identificada causa raíz
- HH:MM fix deployado
- HH:MM verificado resuelto

## Causa raíz (5 whys)
1. Por qué pasó X? → ... (iterar hasta la causa raíz)

## Qué funcionó / qué falló
- ...

## Action items con owner y fecha
- [ ] <acción específica> — owner: <nombre> — fecha: <fecha>
```

### Tiempo objetivo del modo hotfix

Investigación + fix + tests: 1-8h. Deploy: 30 min - 2h. Post-mortem: dentro de 7 días, 1-2h.

---

## Modo 3: `refactor`

**Cuándo**: mejorar código sin cambios funcionales. Cambia el COMO, no el QUÉ.

### Reglas duras del modo refactor

1. **No hay cambios funcionales**. Si el comportamiento observable cambia, no es refactor — es feature (o bug).
2. **Tests existentes deben seguir pasando sin modificarse**. Si necesitás cambiar tests para que pasen, no es refactor — algo cambió.
3. **Coverage no baja**. Idealmente sube.
4. **Diff por sí solo debe ser explicable**: si el Software Architect no entiende por qué cambió cada cosa, el refactor está mal definido.

### Procedimiento

#### 1. el Software Architect define el refactor

`docs/context/refactors/R-NNN-<nombre>.md`:

```markdown
# Refactor R-NNN: <nombre>

**Status**: PROPOSED | IN_PROGRESS | DONE
**Motivación**: <por qué refactorizar ahora>

## Qué cambia

- [ ] <cambio 1: descripción técnica>
- [ ] <cambio 2>

## Qué NO cambia

- Comportamiento observable
- Contratos públicos (APIs)
- Performance (o si mejora, declarar cuanto)

## Métricas de calidad pre/post

| Métrica | Antes | Después esperado |
|---|---|---|
| Coverage del módulo | __% | __% |
| Líneas duplicadas | __ | __ |
| Complejidad ciclomática | __ | __ |
| Tiempo de tests | __s | __s |

## Riesgos

- ...

## Plan de rollback

Si el refactor introduce regresiones: git revert simple. Sin migraciones de datos.
```

#### 2. Implementación

el Backend Developer (o el dev correspondiente) implementa. el Software Architect revisa code.

**Práctica**: hacer commits chicos y atómicos. Un commit por "transformación", no un mega-PR.

#### 3. Mini-gate refactor

- [ ] CI verde
- [ ] **Tests existentes pasan SIN modificarse** (regla dura)
- [ ] Coverage no bajó
- [ ] el Software Architect revisó el diff
- [ ] Métricas post matchean lo declarado

#### 4. Release patch

el Release Manager aplica `release-checklist` en versión `PATCH`. Mencionar en CHANGELOG bajo `### Changed (internal)` que NO es funcional pero hubo cambio interno.

### Tiempo objetivo del modo refactor

Locales (1 archivo, 1 función): horas. De módulo: 1-3 días. Arquitectónicos (varios módulos): considerar migrar a modo `migration`.

---

## Modo 4: `migration`

**Cuándo**: cambio tecnológico mayor. Postgres 15 → 17, Node 18 → 22, cambio de framework core, provider de Railway a Fly.io.

### Reglas duras del modo migration

1. **Hay planning serio**: este modo es el más cercano a greenfield.
2. **Rollback plan documentado al inicio**, NO al final.
3. **Migración por fases si es factible**: branch by abstraction, dual-write, canary deploys.
4. **Métricas pre/post para detectar regresiones**: latencia, error rate, throughput.

### Procedimiento

#### 1. el Software Architect + el Security Architect + el DevOps & Platform agent + el Cost Estimator producen `docs/context/migrations/M-NNN-<nombre>.md`

Documento más largo. Estructura:

```markdown
# Migration M-NNN: <de X a Y>

**Status**: PROPOSED | IN_PROGRESS | DONE | ROLLED_BACK
**Owner técnico**: <agente>

## Por qué

[Por qué hay que migrar. Riesgo de NO migrar.]

## Qué se migra

- Componente / sistema: <descripción>. Versión actual <X> → target <Y>.

## Estrategia

Una de: big_bang | dual_running | blue_green | canary | branch_by_abstraction.

### Plan detallado

1. <paso 1>, 2. <paso 2>, ...

### Criterios de "go / no-go" antes del cutover

- [ ] Métricas pre-cutover capturadas: ___
- [ ] Tests de regresión pasaron en stack target
- [ ] Rollback testeado en staging
- [ ] Stakeholders notificados

### Plan de rollback

- Cuándo: trigger conditions
- Cómo: paso a paso
- Owner durante el cutover: <nombre>

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|

## Costo estimado (el Cost Estimator)

- Tiempo: <días> / USD adicionales: <USD> / Downtime esperado: <minutos / cero>

## Métricas pre / post

| Métrica | Pre-migración | Post-migración (target) |
|---|---|---|
| Latency p99 | __ms | ≤__ms |
| Error rate | __% | ≤__% |
```

#### 2. Adversarial review (obligatorio)

Devil's Advocate ataca el plan. Mínimo 2 rondas. ADRs para decisiones críticas (ADR-NNN: "Migrar a Y en lugar de Z").

#### 3. Implementación por fases

Si es factible, no big-bang. Ejemplos:
- **DB migration**: dual-write durante N días, validar consistency, cutover.
- **Stack migration**: nuevo stack corriendo en sub-set del tráfico (canary).
- **Library upgrade**: hacer en branch, correr tests en CI nightly antes de mergear.

#### 4. Gate completo (no mini-gate)

Las migraciones SÍ requieren gate completo:
- Critic revisa el plan ejecutado
- Devil's Advocate revisa post-mortem antes de cerrar
- el Doc Sentinel verifica que docs (especialmente `EXECUTION.md`) reflejan el stack nuevo
- el Security Architect firma security review post-migración

#### 5. Release (MAJOR o MINOR según impacto)

el Release Manager aplica `release-checklist`. Versión:
- MAJOR si la migración es breaking para usuarios externos (raro)
- MINOR si afecta comportamiento sutil
- PATCH si es invisible al usuario

#### 6. Post-cutover monitoring (primeros 7-30 días)

Watching activo:
- Métricas pre/post comparadas
- Errores no anticipados
- Decisión de "consolidar" (eliminar código viejo) o "rollback" en plazo definido

### Tiempo objetivo del modo migration

Simples (lib update): 1-5 días. Medias (provider de infra): 1-3 semanas. Grandes (DB engine, language version mayor): 1-3 meses.

---

## Reglas duras transversales (todos los modos)

1. **Branch dedicada por evolución**. Nunca mezclar feature + hotfix + refactor en una branch.
2. **CHANGELOG actualizado siempre**, aunque sea hotfix.
3. **Tests obligatorios**: cada modo tiene su requirement de tests.
4. **STATE.md actualizado** con la evolución en curso:
   ```markdown
   ## Active evolutions
   - feature/multi-currency — owner: el Backend Developer — branch: evolve/feature/multi-currency — start: 2026-05-13
   ```
5. **Rollback plan documentado** antes de empezar el cutover (especialmente en migration y hotfix).
6. **Si la evolución toca seguridad, datos sensibles o pagos**: el Security Architect firma. Sin excepciones.

## Anti-patterns

1. **Confundir modo con urgencia**: "es urgente, hagamos hotfix" cuando en realidad es una feature mal priorizada. Hotfix es para BUGS, no para features urgentes.
2. **Refactor que cambia comportamiento**: si tu refactor "mejora" un endpoint cambiando su output, no es refactor. Es feature (o bug del cambio).
3. **Migration sin métricas pre**: si no medís antes, no podés probar que post está bien.
4. **Feature sin tests porque "es chiquita"**: features chicas también pueden romper. Tests proporcionales.
5. **Hotfix sin post-mortem**: el incidente vuelve a pasar.
6. **No actualizar STATE.md**: el equipo no sabe qué hay en curso.

## Output esperado por modo

| Modo | Outputs principales |
|---|---|
| feature | `docs/context/features/F-NNN.md`, código + tests, CHANGELOG, tag MINOR |
| hotfix | `docs/runbooks/incidents/INC-NNN.md` + post-mortem, fix + tests, CHANGELOG, tag PATCH |
| refactor | `docs/context/refactors/R-NNN.md`, diff atómico, métricas pre/post, CHANGELOG (internal) |
| migration | `docs/context/migrations/M-NNN.md`, plan + ADRs, rollback testeado, métricas pre/post, post-cutover report |

## Trigger del skill

El usuario invoca `/evolve` con argumento o lo dice en lenguaje natural:

- "Quiero agregar multi-currency" → `feature`
- "Hay un bug en login en prod" → `hotfix`
- "El módulo de scoring está hecho un caos, hay que limpiarlo" → `refactor`
- "Vamos a migrar de Postgres 15 a 17" → `migration`

Si el modo no es claro, **preguntar explícitamente** con las 4 opciones antes de proceder.
