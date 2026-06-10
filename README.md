# Personal Claude Code Setup

> Un setup personal de Claude Code con agentes especializados, skills procedurales y templates para no repetir las mismas preguntas en cada proyecto.

---

## Tabla de contenidos

1. [Qué es esto](#qué-es-esto)
2. [Instalación](#instalación)
3. [**Cómo abordar cada tipo de proyecto**](#cómo-abordar-cada-tipo-de-proyecto) ⭐ — leer primero
4. [Flujo greenfield completo (referencia visual)](#flujo-greenfield-completo-referencia-visual)
5. [Agentes incluidos](#agentes-incluidos)
6. [Skills y slash commands](#skills-y-slash-commands)
7. [Cuándo usar Claude.ai web vs Claude Code](#cuándo-usar-claudeai-web-vs-claude-code)
8. [Reglas duras del setup](#reglas-duras-del-setup)
9. [Las 5 preguntas que esto elimina](#las-5-preguntas-que-esto-elimina)
10. [Extender el setup](#extender-el-setup)
11. [Troubleshooting](#troubleshooting)
12. [Glosario](#glosario)

---

## Qué es esto

Este setup vive en `~/.claude/` y le da a Claude Code:

- **19 agentes especializados** con roles, opiniones fuertes y tensiones productivas entre sí (el Software Architect discute con el Security Architect; el Devil's Advocate cuestiona a todos).
- **21 skills procedurales** que también son slash commands (`/kickoff`, `/phase-gate`, `/architecture-panel`, `/security-review`, `/evolve`, etc.).
- **CLAUDE.md global** con reglas duras: stack default, defaults de seguridad, fases de proyecto, project_profile, política de documentación, patrones anti-falla.
- **4 templates de proyecto** (web-fullstack, mobile-rn, python-ml-service, static-site).

El objetivo: no repetir las cinco preguntas que aparecen en cada proyecto (cómo correr el sistema, qué stack, seguridad, docs, gateway) y darle estructura calibrada al rigor que cada proyecto necesita.

**Doctrina Propose-first** (CLAUDE.md global §8): la IA hace el trabajo. Los agentes producen sus artefactos COMPLETOS siempre, recomiendan la mejor opción con fundamentos, declaran supuestos en tabla, y le presentan al usuario máximo 3 decisiones con default ("sin respuesta, avanzo con la recomendada"). Nunca interrogan ni esperan. El usuario decide en los gates (con recomendación del Critic) y antes de gastar dinero, deployar a prod o publicar. Todo claim se ancla en evidencia: HECHO (con cita) / INFERENCIA (razonamiento visible) / SUPUESTO (declarado) — proponer no es inventar.

---

## Instalación

```bash
cd <directorio donde descomprimiste el setup>
./install.sh
```

El script:
- Detecta si ya tenés `~/.claude/` y lo respalda en `~/.claude.backup.<timestamp>/`
- Copia agentes, skills, templates y el CLAUDE.md global
- Verifica que todo quedó bien

Opciones:
- `./install.sh --dry-run` — mostrá qué haría sin tocar nada
- `./install.sh --yes` — no preguntar, asumí "sí" en todo
- `./install.sh --no-backup` — sin respaldar (no recomendado)

Después de instalar, reiniciá Claude Code (`/exit` y `claude` de nuevo) para que tome los cambios.

Verificá:
```bash
ls ~/.claude/agents/    # 19 archivos .md
ls ~/.claude/skills/    # 21 directorios
ls ~/.claude/templates/ # 4 directorios
```

O dentro de Claude Code: `/agents` debería listar los 19 agentes.

---

## Cómo abordar cada tipo de proyecto

> **Importante**: el setup tiene 19 agentes y 21 skills, pero **NO todo proyecto requiere todo**. Esta sección es la guía operativa de qué usar según el tipo de proyecto y el momento.

### Decidir el approach: 3 preguntas

Antes de invocar nada, contestate:

1. **¿Es greenfield o evolución?** Greenfield = empezar de cero. Evolución = el proyecto ya está en producción (Fase 6+).
2. **¿Cuál es el `project_profile`?** Personal vs MVP vs comercial. Solo vs equipo. Sin regulación vs alta regulación.
3. **¿Cuál es la naturaleza del cambio?** Feature nueva, hotfix urgente, refactor interno, migración tecnológica.

Las respuestas a esas 3 te dan el flujo concreto. Las matrices siguientes son la cartilla.

---

### ¿Dónde se declara el `project_profile`?

**No es un archivo aparte.** Es un bloque YAML que va en el `CLAUDE.md` **local del proyecto** (en la raíz del repo, no en `~/.claude/CLAUDE.md`).

Cuando arrancás un proyecto nuevo, creá `./CLAUDE.md` con el bloque al inicio:

```yaml
project_profile:
  type: personal | mvp | commercial
  stakeholders: solo | small_team | external_parties
  timeline: flexible | soft_deadline | hard_external
  regulatory: none | medium | high
  data_sensitivity: none | personal | sensitive | regulated
  primary_goal: validate_problem | build_solution | both
```

Los agentes leen ese bloque al iniciar sesión y modulan su rigor (ver `~/.claude/CLAUDE.md` sección 1.1 para la tabla completa de efectos).

**Si no lo declarás**, los agentes asumen el perfil más conservador (todo `commercial` / `medium` / `both`) — o sea, rigor máximo por default. Para bajar el rigor, declaralo explícitamente.

**Si cambia a mitad del proyecto** (ej: pasa de personal a comercial), actualizalo con un addendum en `docs/context/STATE.md`, no implícitamente.

---

### Matriz 1: Greenfield según `project_profile`

#### Greenfield personal — exploratorio (script, side-project, herramienta interna)

**Profile típico**:
```yaml
project_profile:
  type: personal
  stakeholders: solo
  timeline: flexible
  regulatory: none
  data_sensitivity: none | personal
  primary_goal: build_solution
```

**Flujo recomendado**:
- **NO uses `/kickoff`** si es algo de <1 día de trabajo. Abrí Claude Code y construí directo.
- Si es algo de 1-5 días: usá `/kickoff` con el profile arriba. Discovery va a tomar 15-30 min con doc de 1 página. Después seguís construyendo.
- **Saltá fases sin culpa**: el Devil's Advocate no interviene (es opcional en personales), Legal/Compliance no se activa, Cost Estimator solo si tenés interés.

**Agentes que vas a usar**: Product Discovery (corta), Business Analyst (light), Software Architect (light), Backend/Frontend/Mobile Developer según stack. **Aproximadamente 5-7 agentes**.

**Tiempo objetivo end-to-end**: horas a 3-5 días.

#### Greenfield MVP — producto que vas a usar/mostrar

**Profile típico**:
```yaml
project_profile:
  type: mvp
  stakeholders: solo | small_team
  timeline: soft_deadline
  regulatory: none | medium
  data_sensitivity: personal
  primary_goal: validate_problem | both
```

**Flujo recomendado**:
- Usá el flujo completo Fase 0 → 6 con rigor estándar.
- Devil's Advocate activo en Gates 1, 2, 3B.
- Cost Estimator se activa para verificar viabilidad.
- Si hay datos personales: Legal/Compliance hace check mínimo.

**Agentes que vas a usar**: ~12-15 agentes activos. **Aproximadamente todos menos los específicos de stack que no usás** (ej: si es web, no se invoca Mobile Developer).

**Tiempo objetivo end-to-end**: 2-6 semanas.

#### Greenfield comercial — producto con clientes pagando

**Profile típico**:
```yaml
project_profile:
  type: commercial
  stakeholders: small_team | external_parties
  timeline: hard_external | soft_deadline
  regulatory: medium | high
  data_sensitivity: sensitive | regulated
  primary_goal: both
```

**Flujo recomendado**:
- Flujo completo con **rigor máximo**.
- Devil's Advocate **obligatorio** en Gates 1, 2, 3B (activación automática con ≥3 agentes paralelos).
- Legal/Compliance activo desde Fase 2.
- Threat Modeling completo en Fase 3B.
- Smoke test manual del founder antes de Gate 6 (regla dura).
- Testcontainers obligatorios antes de Gate 5 (regla dura).

**Agentes que vas a usar**: los 19. AgroScore cae acá.

**Tiempo objetivo end-to-end**: 2-6 meses para MVP, evolución continua después.

---

### Matriz 2: Evolución post-Fase 6 — usar `/evolve`

Cuando el proyecto ya está en producción, **NO se vuelve a Fase 0**. Usá `/evolve` con el modo correcto.

#### `/evolve feature` — agregar funcionalidad nueva

**Cuándo**: agregar funcionalidad planeada. Ej: "agregar multi-currency a splitwise", "agregar exportación PDF a AgroScore", "agregar 2FA".

**Flujo**:
1. `/evolve feature` → invoca al Business Analyst (Discovery NO se invoca: el producto ya está validado).
2. Business Analyst produce `docs/context/features/F-NNN.md` con spec funcional + cómo se inserta en el sistema.
3. Software Architect + agentes técnicos que aplican (Backend, Frontend, Mobile, API) revisan inserción y definen impacto.
4. Implementación en branch `evolve/feature/<nombre>`.
5. Mini-gate feature: CI verde, coverage no baja, smoke test de UCs nuevos + UCs afectados.
6. Release Manager aplica `release-checklist` con versión `MINOR`.

**Agentes que vas a usar**: 4-8 según el alcance. NO se invoca Product Discovery ni Mateo si la feature es chica.

**Tiempo objetivo**: 1-5 días según tamaño.

#### `/evolve hotfix` — bug crítico en producción

**Cuándo**: bug que duele en producción ya. Tiempo es lo más importante.

**Flujo**:
1. Vos o el Security Architect (si es security incident) escribís `docs/runbooks/incidents/INC-NNN-<fecha>.md` con repro + impacto + severidad.
2. El agente técnico correspondiente investiga (1-4h max).
3. Fix mínimo (≤50 líneas idealmente) + test que reproduce el bug + test que demuestra fix.
4. Mini-gate hotfix acelerado: test del bug pasa, CI verde, no degradan otros tests, Security Architect firmó si es security.
5. Release Manager aplica `release-checklist` con versión `PATCH` y rollback plan de hotfix.
6. **Post-mortem obligatorio dentro de 7 días** (`INC-NNN-postmortem.md`).

**Lo que NO se invoca**: Product Discovery, Business Analyst (no hay spec, la spec es "el bug X mata Y"), panel completo, Devil's Advocate.

**Agentes que vas a usar**: 2-3 (Security Architect si aplica + dev correspondiente + Release Manager).

**Tiempo objetivo**: <24h end-to-end.

#### `/evolve refactor` — mejorar código sin cambios funcionales

**Cuándo**: "el módulo X está hecho un caos", "hay duplicación en Y", "necesito limpiar este código antes de extenderlo".

**Flujo**:
1. Software Architect produce `docs/context/refactors/R-NNN.md`: qué cambia, qué NO cambia, métricas pre/post.
2. Implementación en branch `evolve/refactor/<nombre>`.
3. **Regla dura**: tests existentes pasan SIN modificarse (si necesitás cambiarlos, no es refactor).
4. Mini-gate refactor: CI verde, coverage no bajó, métricas post matchean lo declarado.
5. Release Manager aplica `release-checklist` con versión `PATCH` (mencionar en CHANGELOG bajo "Changed (internal)").

**Agentes que vas a usar**: 2-3 (Software Architect + dev correspondiente + Release Manager).

**Tiempo objetivo**: 0.5-3 días.

#### `/evolve migration` — cambio tecnológico mayor

**Cuándo**: Postgres 15 → 17, Node 18 → 22, migrar de Railway a Fly.io, cambiar de chi a echo.

**Flujo**:
1. Software Architect + Security Architect + DevOps + Cost Estimator producen `docs/context/migrations/M-NNN.md` con plan + rollback + ADRs.
2. Devil's Advocate **obligatorio**: ataca el plan, mínimo 2 rondas.
3. Implementación por fases si es factible (dual-running, blue-green, canary).
4. **Gate completo** (no mini-gate): Critic + Devil's Advocate revisan post-mortem.
5. Release con versión MAJOR/MINOR según impacto.
6. Post-cutover monitoring 7-30 días.

**Agentes que vas a usar**: 6-10 según naturaleza de la migración.

**Tiempo objetivo**: 1-4 semanas según alcance.

---

### Matriz 3: Cuándo NO usar el setup

Sé honesto sobre cuándo el setup es over-engineering:

| Situación | Recomendación |
|---|---|
| Script de 50 líneas para procesar un CSV | Claude Code pelado, sin setup |
| Prototipo exploratorio: "¿es factible X?" | Claude Code pelado o `/kickoff` con profile personal |
| Side-project de fin de semana | `/kickoff` con profile personal + saltar fases sin culpa |
| Aprender una tecnología nueva | Claude Code pelado, vos sos el aprendiz |
| Documentación, slide deck, blog post | Claude Code pelado (no necesita agentes técnicos) |
| Bug fix en script personal | Edit directo, no `/evolve hotfix` |

**Regla práctica**: si el costo de la ceremonia es mayor al costo de un error, no uses el setup. Si el costo de un error supera el costo de la ceremonia (data loss, breach de seguridad, dinero perdido, reputación), usá el setup.

---

### Resumen de qué invocar y cuándo

| Situación | Comando inicial | Flujo |
|---|---|---|
| Greenfield personal corto | (nada, usá Claude Code directo) | Construir |
| Greenfield personal 1-5 días | `/kickoff` con `type: personal` | Fase 0 light → construir |
| Greenfield MVP | `/kickoff` con `type: mvp` | Fase 0 → 6 estándar |
| Greenfield comercial | `/kickoff` con `type: commercial` | Fase 0 → 6 rigor máximo |
| Agregar feature | `/evolve feature` | Mini-flujo Business Analyst → devs → mini-gate |
| Bug crítico en prod | `/evolve hotfix` | Incident → fix → mini-gate → post-mortem |
| Limpiar código sin cambios | `/evolve refactor` | Plan refactor → diff atómico → mini-gate |
| Cambio tecnológico mayor | `/evolve migration` | Plan + ADRs → adversarial review → cutover → monitoring |

---

## Flujo greenfield completo (referencia visual)

Cuando arrancás un greenfield con `/kickoff`, el proyecto pasa por 7 fases con phase gates formales. La profundidad de cada fase se modula según `project_profile`.

```
Fase 0 → Discovery               (Product Discovery agent)
   ↓ /phase-gate 0
Fase 1 → Problem Definition      (Business Analyst)
   ↓ /phase-gate 1 + Devil's Advocate
Fase 2 → Product Decisions       (Product Strategy + Cost Estimator + Legal/Compliance si aplica)
   ↓ /phase-gate 2 + Devil's Advocate
Fase 3A → UX/UI Design           (UX Designer + UI Designer + mockups HTML)  ─┐
Fase 3B → Architecture           (Software Architect + Security Architect    ─┤
                                  + API Architect)                            ├─► cross-review
   ↓ /phase-gate 3A & 3B + Devil's Advocate                                   ┘
Fase 4 → DevOps & Infra          (DevOps & Platform agent)
   ↓ /phase-gate 4
Fase 5 → Development             (Backend/Frontend/Mobile Developer en paralelo + Security Architect review)
   ↓ /phase-gate 5 + Devil's Advocate
Fase 6 → Docs & Release          (Doc Sentinel + Release Manager + smoke test del founder)
   ↓ /phase-gate 6
─────────────────────────────────────────────────────────
Después de Fase 6: el proyecto vive en CICLO DE EVOLUCIÓN
─────────────────────────────────────────────────────────
   /evolve feature   → agregar funcionalidad   (versión MINOR)
   /evolve hotfix    → bug crítico en prod     (versión PATCH, <24h)
   /evolve refactor  → mejora interna          (versión PATCH internal)
   /evolve migration → cambio tecnológico      (versión MAJOR/MINOR)
```

**Phase gate** significa: al cierre de cada fase, el **Critic** revisa los entregables y emite un reporte. En gates mayores (1, 2, 3B, 5), también interviene el **Devil's Advocate** defendiendo la posición contraria. Tu decisión: aprobar y avanzar, iterar, o cambiar dirección.

**Findings con enforcement mecánico**: cada bloqueante debe tener un comando que falle si el problema reaparece. Sin enforcement, el gate no cierra.

**Contexto compartido**: cada fase produce uno o más MDs versionados en `docs/context/`. Los agentes de fases siguientes los leen. NO hay memoria mágica — todo es explícito y auditable.

---

## Agentes incluidos

| Slug (filename) | Rol | Modelo | Fase | Cuándo |
|---|---|---|---|---|
| `product-discovery` | Product Discovery | opus | 0 | Clarifica problema. Modula rigor según `project_profile` del proyecto. |
| `business-analyst` | Business Analysis | opus | 1 | Convierte problema en spec funcional con UCs y BRs numerados. |
| `product-strategy` | Product Strategy | opus | 2 | Prioriza MVP brutalmente. En proyectos personales recorta sin exigir validación comercial. |
| `legal-compliance` | Legal & Compliance | opus | 2/3B | Data protection (GDPR, Ley 25.326), regulación, consentimiento. NO reemplaza abogado. |
| `cost-estimator` | Cost Estimation | opus | 2/3B | Estima MVP y 1 año (optimista/realista/pesimista), compara contra budget. |
| `research-analyst` | Research | opus | Cualquiera | Investiga web (WebSearch + WebFetch), trae findings con citas + URL + fecha. |
| `ux-designer` | UX Design | opus | 3A | User flows, information architecture, accesibilidad WCAG AA. |
| `ui-designer` | UI Design | sonnet | 3A | Design system, tokens, componentes reutilizables, mockups HTML. |
| `software-architect` | Software Architecture | opus | 3B | Monolito modular, stack, ADRs, división por dominio. |
| `security-architect` | Security Architecture | opus | 3B/5 | Threat modeling STRIDE, OWASP, gateway hardening. |
| `api-architect` | API & Gateway Architecture | opus | 3B | Contratos OpenAPI, BFF, gateway sin wildcards. |
| `devops-platform` | DevOps & Platform | sonnet | 4 | Infra, CI/CD, observabilidad, secrets, backups. |
| `backend-developer` | Backend Development (Go) | sonnet | 5 | Implementación backend en Go idiomático, table-driven tests. |
| `frontend-developer` | Frontend Development | sonnet | 5 | React + TS + Vite + Tailwind + React Query. |
| `mobile-developer` | Mobile Development | sonnet | 5 | React Native + Expo, secure storage, offline-first. |
| `release-manager` | Release Management | sonnet | 6 | SemVer, CHANGELOG, rollback plans, release checklist. |
| `doc-sentinel` | Doc Sentinel | sonnet | Todas | Audit de docs, detecta drift, bloquea si falta EXECUTION.md. |
| `critic` | Phase Gate Reviewer | opus | Gates | Findings priorizados. Severidad modulada por `project_profile`. |
| `devils-advocate` | Adversarial Reviewer | opus | Gates 1,2,3B,5 | Defiende posición contraria. Opcional en proyectos personales. |

Cómo invocar:
- **Por rol**: "Que el Software Architect revise la arquitectura" → Claude Code delega al agente correspondiente.
- **Por slug**: "Invocá a `software-architect`" → invocación directa.
- **Por slash command**: ver siguiente sección.
- **Auto-delegación**: Claude Code elige el agente según el contexto y la descripción de cada uno.

> **Nota sobre nombres**: en versiones previas (v1-v8) los agentes tenían nombres propios (Sofía, Diego, Iván, etc.). Desde Sesión 8 (v9) los agentes son **roles puros** sin nombres propios. Esto reduce roleplay innecesario y hace el output más profesional. Si seguís usando nombres propios al invocar ("que Sofía revise"), Claude Code va a entender pero la auto-delegación funciona mejor con los slugs/roles actuales.

---

## Skills y slash commands

En Claude Code 2.1+, los skills y slash commands están unificados: cada skill expone un `/slash-command` automáticamente.

### Comandos principales (de orquestación)

| Slash command | Qué hace | Cuándo usar |
|---|---|---|
| `/kickoff` | Arranca proyecto nuevo: el Product Discovery agent produce el discovery completo de una pasada. Acepta un doc funcional existente como fuente primaria: `/kickoff "<desc> — spec en <path>"` | Al empezar cualquier proyecto |
| `/phase-gate [N]` | Cierre formal de fase: Critic + Devil's Advocate revisan. Incluye filtro de relevancia, Plan B por addendum y cross-review 3A↔3B | Al final de cada fase (cross-review: durante fases paralelas) |
| `/architecture-panel` | Convoca panel: el Software Architect + el Security Architect + el API Architect + el Cost Estimator + Devil's Advocate | Fase 3B, diseño técnico |
| `/retroactive` | Maneja actualización retroactiva cuando fase posterior revela un hueco | Cuando se descubre un gap |
| `/docs-audit` | el Doc Sentinel verifica docs obligatorias y drift con código | Cualquier momento |
| `/how-to-run` | Genera o actualiza `docs/EXECUTION.md` | Fase 4, mantenimiento |

### Comandos especializados por dominio

| Slash command | Qué hace | Cuándo usar |
|---|---|---|
| `/mvp-scope` | Aplica framework de priorización brutal de MVP | Fase 2, el Product Strategist lo invoca |
| `/cost-estimate` | Estimación de costos en 3 escenarios (optimista/realista/pesimista) | el Cost Estimator, Gate 2 y 3B |
| `/legal-check` | Checklist legal + compliance + brief para estudio externo | el Legal & Compliance agent, Fase 2/3B |
| `/ux-flow` | Mapea UCs funcionales a user flows con edge cases | el UX Designer, Fase 3A |
| `/api-design` | Diseño de contratos REST/GraphQL con OpenAPI | el API Architect, Fase 3B |
| `/security-review` | el Security Architect aplica threat modeling STRIDE + checklist OWASP + gateway hardening | Fase 3B (threat model), Gate 5, on-demand |
| `/testing-strategy` | Define pirámide de tests + coverage targets + CI gates | Fase 4-5 |
| `/release-check` | Checklist completo de release a producción | el Release Manager, antes de cada release |
| `/enforce-rules` | Genera workflows de CI que enforcearon las reglas duras | Fase 4, el DevOps & Platform agent |
| `/adr` | Escribe o audita un Architecture Decision Record | Cualquier momento que se tome decisión |

### Skills procedurales (invocadas por agentes, no comandos directos)

| Skill | Qué encapsula |
|---|---|
| `gateway-hardening` | Matriz de decisión de gateway + checklist anti-wildcard + configs de ejemplo (Caddy/KrakenD/Traefik) en `resources/` |
| `modular-monolith` | Patrones de boundaries, anti-patterns, cuándo extraer a microservicio |
| `adversarial-review` | Procedimiento de panel adversarial multi-agente |
| `phase-gate` | Cierre de fase con checklists por fase + filtro de relevancia + Plan B por addendum + cross-review 3A↔3B |

> Varios skills llevan archivos de recursos junto al `SKILL.md` (`resources/`): templates de configs, HTML de mockups, workflows de CI, template de ADR. Se cargan solo cuando el skill los necesita.

---

## Cuándo usar Claude.ai web vs Claude Code

| Fase | Recomendado | Por qué |
|---|---|---|
| 0, 1, 2 | **Claude.ai web** (Project) | Conversacional, iterativo, sin tocar archivos |
| 3A (UX) | Claude.ai web + Claude Code | UX se conversa, prototipos en código |
| 3B (Arquitectura) | **Claude Code** | Necesita ver y escribir archivos del repo |
| 4, 5, 6, 7 | **Claude Code** | Operación sobre el código |

Para traspasar contexto de Claude.ai a Claude Code: exportá los MDs (copy/paste a `docs/context/`) y commiteá. El setup está diseñado para que todo el contexto crítico viva en MDs versionados.

---

## Reglas duras del setup

Estas reglas están en el `CLAUDE.md` global y se aplican siempre:

1. **Stack default** (ver `~/.claude/CLAUDE.md` sección 3): React+TS+Vite frontend, Go backend, Postgres default, Railway infra. Desvíos requieren ADR escrito.
2. **Monolito modular, no microservicios prematuros**. Microservicios solo con justificación contundente.
3. **Backend siempre en red privada**, gateway al frente.
4. **Gateway sin wildcards**, jamás. el Security Architect tiene veto.
5. **Secretos nunca en repo**. `.env` en `.gitignore`, `.env.example` siempre presente.
6. **`docs/EXECUTION.md` obligatorio desde Fase 4**, con secciones de local + staging + prod.
7. **Toda decisión no obvia → ADR** en `docs/adr/`.
8. **Phase gates flexibles pero formales**: el usuario decide, pero el Critic dispara la revisión.
9. **Devil's Advocate en gates mayores**: estresa la decisión central.
10. **Coverage objetivo ≥85%** en código de negocio.
11. **Propose-first**: los agentes producen completo, recomiendan y declaran supuestos; nunca bloquean con preguntas. Control humano solo en gates + dinero + deploy + publicación (CLAUDE.md global §8).

---

## Las 5 preguntas que esto elimina

| Pregunta vieja | Resolución en el setup |
|---|---|
| "¿Cómo ejecuto el sistema?" | Skill `how-to-run` + `docs/EXECUTION.md` obligatorio desde Fase 4. Bloqueante en Gate 4. |
| "¿Qué stack uso?" | Defaults en CLAUDE.md global. el Software Architect justifica desvíos por escrito (ADR). |
| "¿Están todas las barreras de seguridad?" | el Security Architect + skill `security-review` en Gate 3B y Gate 5. OWASP Top 10 verificado item por item. |
| "¿Está todo documentado?" | el Doc Sentinel (Doc Sentinel) en cada gate. Lista de docs obligatorias por fase. |
| "¿Qué gateway y está bien configurado sin wildcards?" | Skill `gateway-hardening` con matriz de decisión + checklist anti-wildcard + configs de ejemplo. |

Si alguna de estas preguntas vuelve a surgir, algo del setup falló. Marcalo y reportalo.

---

## Extender el setup

### Agregar un agente nuevo

1. Crear `~/.claude/agents/<nombre>.md` con frontmatter YAML:
   ```yaml
   ---
   name: nombre-del-agente
   description: Qué hace y cuándo usarlo. Esta descripción es lo que Claude Code matches contra prompts.
   tools: Read, Write, Edit, Glob, Grep, Bash
   model: opus  # opus | sonnet | haiku
   color: blue  # opcional
   ---
   ```
2. Después del frontmatter, escribir el system prompt del agente con su personalidad, protocolo, outputs esperados, reglas.
3. Reiniciar Claude Code.
4. Probar: "Que <nombre> haga X".

### Agregar un skill / slash command

1. Crear directorio `~/.claude/skills/<nombre>/`.
2. Adentro, crear `SKILL.md` con frontmatter:
   ```yaml
   ---
   name: nombre
   description: Descripción precisa de cuándo invocar este skill. La descripción es el trigger.
   ---
   ```
3. Después del frontmatter, el contenido del skill (instrucciones, plantillas, etc.).
4. Reiniciar Claude Code.
5. Probar: `/nombre`.

### Agregar un template de proyecto

1. Crear directorio `~/.claude/templates/<tipo>/` con la estructura completa.
2. Asegurarse que el `CLAUDE.md` del template referencie correctamente el global.
3. Documentar en este README en qué casos usarlo.

### Modificar el CLAUDE.md global

Cualquier cambio en `~/.claude/CLAUDE.md` afecta a TODOS tus proyectos. Pensar antes de tocar.

Para override a nivel de proyecto: en el `./CLAUDE.md` del proyecto, declarar el override y justificarlo.

---

## Troubleshooting

### "Los agentes no aparecen en /agents"

- Reiniciá Claude Code (`/exit` y `claude` de nuevo).
- Verificá los archivos: `ls ~/.claude/agents/`.
- Verificá que el frontmatter YAML es válido. Errores comunes: `---` con espacios, comillas mal cerradas en `description`.

### "Un slash command no funciona"

- Verificá que existe: `ls ~/.claude/skills/<nombre>/SKILL.md`.
- Verificá frontmatter: `name` debe coincidir con el nombre del directorio.
- Reiniciá Claude Code.

### "El agente no toma el rol que espero"

- Releé su `description` en el frontmatter. Ese campo es el trigger.
- Si el agente A se confunde con el agente B, refiná las `description` para que sean distintivas.
- Probá invocar explícitamente: "Que <nombre-exacto-del-agente> haga X".

### "Conflicto entre opiniones de agentes"

- **Eso es by design**. el Software Architect y el Security Architect DEBEN discutir. El Devil's Advocate DEBE cuestionar.
- Si el conflicto es improductivo (loop infinito), invocá al Critic: "Critic, sintetizá".
- Si la disonancia es real, el usuario decide y se captura en un ADR.

### "No quiero que el Devil's Advocate me cuestione TODO"

- El Devil's Advocate solo se invoca en gates 1, 2, 3B, 5.
- Si querés un proyecto rápido sin tanta fricción, podés saltar gates menores (3A, 4, 6) — pero los mayores se mantienen.
- Aprobar gates con "Aprobar y avanzar" cierra el ciclo rápido.

### "Tengo un proyecto corporativo y no quiero que esto aplique"

- Este setup es PERSONAL. En tu máquina corporativa, instalá un setup distinto en `~/.claude/`, o usá `--add-dir` con un directorio específico para overridear.

---

## Glosario

- **Agente / Subagent**: Instancia aislada de Claude con system prompt propio, tools propios, context window propio. Roles especializados.
- **Skill**: Procedimiento reutilizable empaquetado en una carpeta con `SKILL.md`. También expone un `/slash-command`.
- **CLAUDE.md**: Archivo de instrucciones globales (en `~/.claude/`) o de proyecto (en la raíz del repo).
- **Phase Gate**: Revisión formal al cierre de una fase del proyecto.
- **ADR (Architecture Decision Record)**: Registro inmutable de una decisión arquitectónica, con contexto, alternativas y consecuencias.
- **Monolito modular**: Arquitectura de un solo deployable con módulos internos bien separados por dominio.
- **Bounded Context**: Concepto de DDD; cada módulo tiene su propio lenguaje y modelo.
- **Devil's Advocate**: Agente que defiende la posición contraria a la decisión tomada, para estresar su robustez.
- **Critic**: Agente que revisa entregables de una fase contra checklists específicos.
- **Threat Modeling (STRIDE)**: Framework para identificar amenazas: Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege.

---

## Versionado

El historial completo de iteraciones y sesiones está en [CHANGELOG.md](CHANGELOG.md).

---

