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
- **27 skills procedurales** que también son slash commands (`/kickoff`, `/phase-gate`, `/architecture-panel`, `/threat-model`, `/evolve`, etc.).
- **CLAUDE.md global** con reglas duras: stack default, defaults de seguridad, fases de proyecto, project_profile, política de documentación, patrones detectados.
- **4 templates de proyecto** (web-fullstack, mobile-rn, python-ml-service, static-site).

El objetivo: no repetir las cinco preguntas que aparecen en cada proyecto (cómo correr el sistema, qué stack, seguridad, docs, gateway) y darle estructura calibrada al rigor que cada proyecto necesita.

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
ls ~/.claude/skills/    # 27 directorios
ls ~/.claude/templates/ # 4 directorios
```

O dentro de Claude Code: `/agents` debería listar los 19 agentes.

---

## Cómo abordar cada tipo de proyecto

> **Importante**: el setup tiene 19 agentes y 27 skills, pero **NO todo proyecto requiere todo**. Esta sección es la guía operativa de qué usar según el tipo de proyecto y el momento.

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

**Findings con enforcement mecánico** (desde Sesión 6): cada bloqueante debe tener un comando que falle si el problema reaparece. Sin enforcement, el gate no cierra.

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
| `ui-designer` | UI Design | opus | 3A | Design system, tokens, componentes reutilizables, mockups HTML. |
| `software-architect` | Software Architecture | opus | 3B | Monolito modular, stack, ADRs, división por dominio. |
| `security-architect` | Security Architecture | opus | 3B/5 | Threat modeling STRIDE, OWASP, gateway hardening. |
| `api-architect` | API & Gateway Architecture | opus | 3B | Contratos OpenAPI, BFF, gateway sin wildcards. |
| `devops-platform` | DevOps & Platform | opus | 4 | Infra, CI/CD, observabilidad, secrets, backups. |
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
| `/kickoff` | Arranca proyecto nuevo: el Product Discovery agent toma el control | Al empezar cualquier proyecto |
| `/phase-gate [N]` | Cierre formal de fase: Critic + Devil's Advocate revisan | Al final de cada fase |
| `/architecture-panel` | Convoca panel: el Software Architect + el Security Architect + el API Architect + el Cost Estimator + Devil's Advocate | Fase 3B, diseño técnico |
| `/cross-review` | Coordina trabajo paralelo 3A↔3B y detecta conflictos | Antes de Gate 3B |
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
| `/threat-model` | STRIDE threat modeling sobre arquitectura propuesta | el Security Architect, Fase 3B |
| `/security-review` | el Security Architect aplica checklist OWASP + gateway hardening | Fase 3B, Gate 5, on-demand |
| `/testing-strategy` | Define pirámide de tests + coverage targets + CI gates | Fase 4-5 |
| `/release-check` | Checklist completo de release a producción | el Release Manager, antes de cada release |
| `/enforce-rules` | Genera workflows de CI que enforcearon las reglas duras | Fase 4, el DevOps & Platform agent |
| `/adr` | Escribe o audita un Architecture Decision Record | Cualquier momento que se tome decisión |

### Skills procedurales (invocadas por agentes, no comandos directos)

| Skill | Qué encapsula |
|---|---|
| `gateway-hardening` | Matriz de decisión de gateway + checklist anti-wildcard + templates Caddy/KrakenD/Traefik |
| `security-checklist` | OWASP Top 10 + STRIDE + checklists específicos por tipo de app |
| `modular-monolith` | Patrones de boundaries, anti-patterns, cuándo extraer a microservicio |
| `execution-runbook` | Template completo de `docs/EXECUTION.md` para local + staging + prod |
| `adversarial-review` | Procedimiento de panel adversarial multi-agente |
| `phase-gate` | Procedimiento de cierre de fase con checklists por fase |

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

---

## Las 5 preguntas que esto elimina

| Pregunta vieja | Resolución en el setup |
|---|---|
| "¿Cómo ejecuto el sistema?" | Skill `execution-runbook` + `docs/EXECUTION.md` obligatorio desde Fase 4. Bloqueante en Gate 4. |
| "¿Qué stack uso?" | Defaults en CLAUDE.md global. el Software Architect justifica desvíos por escrito (ADR). |
| "¿Están todas las barreras de seguridad?" | el Security Architect + skill `security-checklist` en Gate 3B y Gate 5. OWASP Top 10 verificado item por item. |
| "¿Está todo documentado?" | el Doc Sentinel (Doc Sentinel) en cada gate. Lista de docs obligatorias por fase. |
| "¿Qué gateway y está bien configurado sin wildcards?" | Skill `gateway-hardening` con matriz de decisión + checklist anti-wildcard + templates listos. |

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

- **Iteración 1**: 9 agentes, 11 skills, 1 template (web-fullstack), install.sh. Agentes con nombres propios (Sofía, Diego, etc.).
- **Iteración 2 — Sesión 1**: 12 agentes (+Product Strategist, +Legal & Compliance agent, +Release Manager), ajustes al Product Discovery agent y phase-gate, STATE.md introducido.
- **Iteración 2 — Sesión 2**: 18 agentes — todos los principales completos. Colores únicos por agente.
- **Iteración 2 — Sesión 3**: 23 skills (+12 nuevos), 4 templates (+3 nuevos: mobile-rn, python-ml-service, static-site), mecánicas operativas. **Iteración 2 cerrada**.
- **Iteración 3 — Sesión 4**: re-calibración del rigor por contexto (`project_profile`), agente Research Analyst.
- **Iteración 3 — Sesión 5**: mockups HTML+Tailwind como entregable de Fase 3A.
- **Iteración 3 — Sesión 6**: correcciones estructurales por aprendizaje real (relevance-filter, plan-b-addendum, inputs heredados, enforcement mecánico, cross-review single source).
- **Iteración 3 — Sesión 7**: prototipos interactivos con JS de simulación + ciclo de evolución post-Fase 6 (`/evolve` con 4 modos).
- **Iteración 3 — Sesión 8** (actual): **renombrado de agentes**. Eliminados nombres propios (Sofía, Diego, Iván, etc.) en favor de roles puros (product-discovery, software-architect, security-architect, etc.). Tono profesional preservando carácter funcional.

## Changelog del setup

### Iteración 3 — Sesión 8 (2026-05-13) — eliminación de nombres propios

**Trigger**: el usuario observó que los nombres propios (Sofía, Lucía, Mateo, Ana, Renata, Romi, Tomás, Valentina, Diego, Iván, Pablo, Ema, Nico, Cami, Bruno, Leo, Sara) introducían tono de roleplay innecesario. Output con tinte de RPG cuando se busca output técnico profesional.

**Changed — 17 agentes renombrados (los 2 meta — critic, devils-advocate — sin cambio)**

| Antes (filename) | Después (filename) |
|---|---|
| `sofia-discovery` | `product-discovery` |
| `lucia-ba` | `business-analyst` |
| `mateo-product` | `product-strategy` |
| `ana-legal` | `legal-compliance` |
| `renata-cost` | `cost-estimator` |
| `romi-research` | `research-analyst` |
| `tomas-ux` | `ux-designer` |
| `valentina-ui` | `ui-designer` |
| `diego-architect` | `software-architect` |
| `ivan-security` | `security-architect` |
| `pablo-api` | `api-architect` |
| `ema-devops` | `devops-platform` |
| `nico-backend` | `backend-developer` |
| `cami-frontend` | `frontend-developer` |
| `bruno-mobile` | `mobile-developer` |
| `leo-release` | `release-manager` |
| `sara-doc-sentinel` | `doc-sentinel` |

**Changed — contenido interno de cada agente**
- Intro reescrita: "Eres el agente de **<Rol>**" en lugar de "Eres <Nombre>, especialista en X con N años de experiencia".
- "Tu personalidad" → "Tu enfoque".
- "Tu obsesión" → "Tu principio rector".
- Removidos años de experiencia ficticios y biografías ("Diseñaste seguridad para fintechs...").
- Referencias cruzadas: "coordinás con el Security Architect" en lugar de "coordinás con Iván".

**Preservado intencionalmente — el carácter funcional de cada agente**
- "Brutal MVP prioritization" (Product Strategy)
- "Defense in depth, zero trust" (Security Architecture)
- "Componentes pequeños, composables, accesibles" (Frontend Development)
- "Mobile no es web responsive" (Mobile Development)
- "Si necesitás explicarle al usuario cómo usarlo, fallé" (UX Design)

El tono sigue siendo directo, opinionado, no aburrido — pero sin nombres propios.

**Changed — skills, CLAUDE.md global, README, templates**
- 25 skills actualizados con referencias al rol en lugar del nombre.
- README con nueva tabla de agentes (slug + rol + cuándo) y nota explicativa del cambio.
- CLAUDE.md global actualizado.
- 4 templates con referencias actualizadas.
- Splitwise-mini también actualizado (proyecto de validación).

**Compatibilidad hacia atrás**
- **Los slugs cambiaron**: `sofia-discovery.md` ya no existe. Si tenías referencias hardcoded a los nombres viejos en proyectos propios, las tenés que actualizar.
- **Claude Code usa el campo `name:` del frontmatter** para auto-delegación. Ese campo también cambió. Si decís "que Sofía revise X", Claude Code probablemente entienda por contexto, pero la auto-delegación funciona mejor diciendo "que el Product Discovery agent revise X" o usando slash commands.

**Insight estructural**
- La personalidad ficticia (nombres + biografías) **no aporta a la calidad del output**. Lo que aporta es la **especialización del rol** (qué cuestiona, qué prioriza, qué decisiones toma).
- Los nombres propios eran decoración de Iteración 1 que ya cumplió su función. En Iteración 3, el framework está maduro y el roleplay es costo neto.

### Iteración 3 — Sesión 7 (2026-05-13) — prototipos interactivos + ciclo de evolución

**Trigger**: el usuario pidió (1) prototipos que sean entregables iterables antes de arquitectura/desarrollo, y (2) un flujo para evolucionar proyectos después de Fase 6 (agregar features, hotfixes, refactors, migraciones).

**Added — 1 skill nuevo (total 27)**
- `evolve`: orquesta los 19 agentes existentes en 4 modos calibrados a escenarios reales post-release: `feature` (agregar funcionalidad), `hotfix` (bug crítico en prod), `refactor` (mejora interna sin cambios funcionales), `migration` (cambio tecnológico mayor). Cada modo tiene procedimiento + outputs + tiempo objetivo distintos.

**Changed — `mockup-generation` skill (Bloque B)**
- Nuevo Paso 0: decidir modo estático vs interactivo al inicio.
- Nueva sección "Modo interactivo": stack permitido (Alpine.js, petite-vue, localStorage), reglas duras, template completo con ejemplos de código.
- Nueva carpeta `prototype/` dentro de `mocks/` con `state.js`, `seed-data.js`, `reset.js`.
- Botón "Reset prototipo" obligatorio en cada pantalla interactiva.
- Template `mocks/feedback.md` para capturar iteración del usuario.
- Anti-pattern actualizado: "JavaScript de producción NO" pero "JS de simulación SÍ".

**Changed — `CLAUDE.md` global**
- Sección 6 (flujo de fases): agregada visualización del ciclo de evolución post-Fase 6 con los 4 modos de `/evolve`.
- Nueva nota: "El ciclo de evolución reusa los 19 agentes existentes, no se vuelve a Fase 0/1 para cada feature."

**Changed — templates `STATE.md` (4 templates)**
- Nueva sección "Active evolutions (post-Fase 6)" para trackear features/hotfixes/refactors/migrations en curso después del primer release.

**Decisiones de diseño tomadas**

*Bloque B*: se eligió **B1 (extender el UI Designer con JS de simulación)** sobre alternativas:
- B2 (el Frontend Developer en modo throwaway) → riesgo de premature coding antes de Gate 3B.
- B3 (agente nuevo "Bianca") → over-engineering. 19 agentes ya son muchos; el problema se resuelve sin agente nuevo.

*Bloque C*: se eligió **C1 (un comando `/evolve` con modos)** sobre alternativas:
- C2 (4 comandos separados) → más overhead conceptual.
- C3 (modo incremental en agentes existentes) → carga cada agente con más complejidad.

**Insight estructural de la Sesión 7**
- El framework greenfield está diseñado para construir desde cero, pero la vida real del producto pasa en **mantenimiento + evolución**, no en greenfield. Sin un flujo específico para post-Fase 6, el framework se vuelve inutilizable después del primer release (forzaría re-correr Fase 0 para cada feature).
- Los 4 modos no son perfectos: van a refinarse con uso real. El más usado (`feature`) va a estar bien probado; los otros (especialmente `migration`) van a necesitar iteración cuando haya evidencia.
- El prototipo interactivo cambia la naturaleza del feedback: en lugar de "esta pantalla se ve bien" el usuario puede decir "agregué 3 gastos y vi que el total no se actualiza, falta esa interacción".

### Iteración 3 — Sesión 6 (2026-05-13) — correcciones estructurales por aprendizaje real

**Trigger**: corrida completa de splitwise-mini (Fases 0-5) detectó 4 patrones sistémicos del framework. Documento `framework-improvements.md` con 4 patrones + métricas + recomendaciones específicas. ROI del experimento: 115-145h invertidas → 4 bugs estructurales del framework documentados antes de aplicarlo a AgroScore.

**Added — 2 skills nuevos (total 26)**
- `relevance-filter`: cada agente especialista declara sección "Filtro de relevancia" citando literalmente el MVP scope. Reemplaza idea original de "caps numéricos" (que generaba problemas distintos al sobre-engineering).
- `plan-b-addendum`: aplica recortes del DA Plan B como addendum firmado por agente original, NO relanzando agentes desde cero. Preserva voz del especialista, evita ciclo de sobre-entrega, crea aprendizaje.

**Changed — `phase-gate` skill**
- Nuevo Paso 4a: tabla obligatoria "Inputs heredados de gates previos". Diferir un input duro requiere ADR. Sin tabla, gate falla.
- Nuevo Paso 4c: modelo de findings con `enforcement_status`. Solo `RESOLVED` (con commit + tool) o `BLOCKED_BY_TOOL` (tool fail mientras siga abierto) permiten cerrar gate. `BLOCKED_BY_PROCESS` NO permite cerrar. `RISK_ACCEPTED` permite cerrar solo con ADR escrito y revisión en próximo gate.
- Gate 3B ahora exige `cross-review-notes.md` como single source of truth con sign-off.

**Changed — `adversarial-review` skill**
- Activación automática cuando una fase tiene ≥3 agentes especialistas paralelos.
- Prompt especial al DA en fases multi-agente: cuestionar proporción al MVP declarado.

**Changed — `cross-review` skill**
- Regla dura: TODA la cross-review vive en `docs/context/03-cross-review-notes.md` como único archivo. Prohibido que cada agente firme su parte en docs separados.
- Estructura del doc estandarizada con campos `id`, `description`, `proposed_by`, `responder`, `status`, `resolution`.

**Changed — `testing-strategy` skill**
- Regla dura: testcontainers obligatorios para proyectos con Postgres/MySQL antes de cerrar Gate 5. Mocks de DB NO cuentan para validar queries críticas (JOINs, agregaciones).

**Changed — `release-checklist` skill**
- Pre-requisito antes de Gate 6: `docs/runbooks/smoke-test.md` firmado por el founder (UCs ejercidos en stack real). Validación irremplazable: tests automáticos validan que el código hace lo que el dev cree, smoke test valida que el sistema funciona como producto.

**Changed — agentes técnicos (el DevOps & Platform agent, el Backend Developer, el Frontend Developer, el Mobile Developer, el Release Manager)**
- Bloque obligatorio "Inputs heredados" en cada uno. Diferir un input duro requiere ADR. El Critic verifica esta tabla en gates.

**Changed — `CLAUDE.md` global**
- Sección 10 actualizada con "el recorte temprano es 4-10× más barato que el recorte tardío".
- Nueva sección 11: "Patrones detectados en proyectos previos (lecciones de splitwise-mini)" documentando los 4 patrones estructurales para que los agentes los reconozcan.
- Renumeración: sección 11 vieja → 12 ("Cómo invocar agentes"), 12 → 13 ("Persistencia del contexto").

**Reformulaciones aplicadas (vs propuestas del doc)**
- **R1.2 reformulado**: en lugar de "caps numéricos por escala" (que tienen problemas: dependen del nº de usuarios solo, invitan al juego del cap, no atacan el problema real), se aplicó el skill `relevance-filter` que ataca el problema real (output desconectado del MVP).
- **R1.4 reformulado**: en lugar de "coordinator aplica recortes" (rol sin legitimidad formal en el framework), se aplicó el skill `plan-b-addendum` donde el agente original revisa y firma sus propios recortes, con escape al usuario para discrepancias.

**Hallazgos menores aplicados (H5-H10)**
- H5: DA bloqueante real en Gates 1, 2, 3B reforzado en sección 11.1.
- H7: sizing contra scope acordado, no contra entrega real (regla en agentes técnicos).
- H8: testcontainers obligatorios (testing-strategy).
- H9: smoke test manual del founder antes de Gate 6 (release-checklist).
- H10: regla del recorte temprano en sección 10.

**Insight estructural de la Sesión 6**
- El valor más alto del framework está en el **DA + Critic combinados**: el Critic captura ausencias por checklist, el DA cuestiona la proporción al MVP. Sin ambos, el framework produce artefactos justificados individualmente pero desconectados del producto declarado.
- La diferencia entre "tener una regla" y "tener una regla con enforcement mecánico" es de 4-15× en costo. Toda regla dura del framework, desde Sesión 6, debe tener tool que la enforce.

### Iteración 3 — Sesión 5 (2026-05-13) — mockups visuales

**Trigger**: el usuario preguntó si existía generación de mocks visuales antes de pasar a development. No existía. Era un gap real: hasta ahora se pasaba de descripciones textuales (UX spec, UI spec) directo a código React, sin visualización intermedia.

**Added**
- **Skill `mockup-generation`**: procedimiento detallado para generar mockups HTML+Tailwind navegables (sin build step, sin servidor). Tailwind via CDN, CSS variables del design system, datos plausibles, estados loading/empty/error explícitos, banner "MOCKUP" visible en cada pantalla.
- **Carpeta `mocks/`** en los 3 templates con UI (web-fullstack, mobile-rn, static-site) con README placeholder.

**Changed**
- **UI Designer**: ahora tiene como entregable obligatorio de Fase 3A los mockups HTML, además del UI spec. Su description del frontmatter incluye triggers "mockup", "mock", "wireframe", "ver pantallas".
- **Skill `phase-gate`**: agregó "Paso 4b — Checks específicos por fase" con checklists per-gate. Gate 3A ahora exige `mocks/` con index navegable y estados críticos mockeados.
- **install.sh**: actualizado a expected 24 skills.

**Por qué el UI Designer y no un agente nuevo o el Frontend Developer**
- el Frontend Developer construye lo final con stack real y tests; mocks son rápidos y desechables. Mezclar roles confunde responsabilidades.
- Crear un agente nuevo era over-engineering: la generación de mocks es continuación natural de definir tokens. el UI Designer ya define cómo se ve; ahora también lo muestra.
- Iterar mocks tuyos (el UI Designer) cuesta minutos; iterar React (el Frontend Developer) cuesta horas. La iteración rápida importa antes de development.

**Insight estructural**
- Hay decisiones del framework que solo emergen al aplicarlo a proyectos con características distintas. AgroScore (B2B scoring, poca UI compleja) no expuso este gap; splitwise-mini (UI-heavy) sí.
- Sigue la regla "no over-engineering preventivo": el gap apareció al validar, se cerró rápido, no se anticipó.

### Iteración 3 — Sesión 4 (2026-05-13) — calibración por contexto

**Trigger**: durante validación con splitwise-mini, el Product Discovery agent generó fricción excesiva debatiendo fechas tentativas y profundizando en validación del problema cuando el contexto era "proyecto personal de developer construyendo solución". Documentado en `splitwise-mini/docs/framework-findings.md`.

**Added**
- **Agente el Research Analyst (Research Analyst)**: investiga la web con WebSearch + WebFetch, trae findings estructurados con citas + URL + fecha + nivel de confianza. Soporta a el Software Architect (industria/stacks), el Security Architect (CVEs/práctica actual), el Cost Estimator (pricing actual), el API Architect (specs públicas), el Legal & Compliance agent (regulación actualizada). NO toma decisiones del proyecto.
- **Concepto `project_profile`** en CLAUDE.md global (sección 1.1) y en los 4 templates: cada proyecto declara `type`, `stakeholders`, `timeline`, `regulatory`, `data_sensitivity`, `primary_goal`. Los agentes leen este profile al iniciar sesión y modulan su rigor.

**Changed**
- **el Product Discovery agent re-calibrada**: ahora modula profundidad según profile. `personal + build_solution` → 1 página, 15-30 min, no debate fechas. `commercial` → rigor completo. Las reglas duras anti-cierre aplican solo en proyectos `commercial` o con `regulatory: high`.
- **Product Strategist**: modula rigor según profile. `personal` → no exige hipótesis falsables ni kill criteria comerciales.
- **Critic**: modula severidad de findings según profile. En proyectos personales, findings de proceso bajan a 🟢 sugerencia.
- **Devil's Advocate**: en proyectos personales, intervención opcional. Solo aparece en decisiones técnicas con consecuencias reales.
- **install.sh**: actualizado a expected 19 agentes.
- **Templates**: los 4 templates traen ahora sección `project_profile` para llenar al inicio.

**Fixed**
- 8 agentes tenían duplicada la línea `color:` en YAML (legado de Sesión 2). Consolidados a 1 color cada uno.
- Sesión 3 había dejado a el Product Discovery agent con `color: purple` duplicado.

**Insight estructural**
- El rigor universal NO escala. Un setup que aplica el mismo nivel de cuestionamiento a un side-project y a un MVP regulado, fracasa en ambos: es overkill en uno y subóptimo en el otro.
- La solución no es "menos rigor" sino "rigor modulado por contexto declarado". El usuario declara el contexto, los agentes adaptan su comportamiento.

### Iteración 2 — Sesión 3 (2026-05-13) — cierre Iteración 2

**Added — Skills (12 nuevos, total 23)**
- `mvp-prioritization`: framework de priorización brutal de MVP (el Product Strategist).
- `adr-writing`: ADRs de calidad consistente con plantilla y reglas.
- `testing-strategy`: pirámide de tests, coverage targets, CI gates.
- `release-checklist`: procedimiento completo de release con rollback plan obligatorio.
- `legal-compliance-check`: PII inventory + mapeo regulatorio + brief para estudio (el Legal & Compliance agent).
- `threat-modeling`: STRIDE detallado con matriz Likelihood × Impact (el Security Architect).
- `ux-flow-mapping`: traduce UCs a flows con estados obligatorios (el UX Designer).
- `api-contract-design`: REST + OpenAPI + RFC 7807 + cursor pagination (el API Architect).
- `cost-estimation`: 3 escenarios + costos ocultos + plan de migración (el Cost Estimator).
- `cross-review`: coordinación 3A↔3B y detección de conflictos.
- `enforce-rules`: genera workflows CI para enforcer reglas duras automáticamente.
- `retroactive-update`: maneja gaps descubiertos en fases posteriores sin perder trazabilidad.

**Added — Templates (3 nuevos, total 4)**
- `mobile-rn`: React Native + Expo, secure storage, EAS Build, OTA updates.
- `python-ml-service`: Python 3.11+ con uv, FastAPI, model registry, retraining patterns.
- `static-site`: Astro + Tailwind + Cloudflare Pages, performance/SEO targets.

**Changed**
- `install.sh` actualizado a expected 23 skills + 4 templates.
- README con tabla completa de skills/slash commands (orquestación, especializados, procedurales).

**Closed**
- **Iteración 2 cerrada**. Setup completo: 18 agentes, 23 skills, 4 templates, mecánicas operativas, hooks de CI.

### Iteración 2 — Sesión 2 (2026-05-13)

**Added**
- Agente el UX Designer (UX): user flows, IA, accesibilidad WCAG AA, edge cases.
- Agente el UI Designer (UI): design system con tokens, componentes reutilizables, Tailwind.
- Agente el DevOps & Platform agent (DevOps): infra, CI/CD, observabilidad, secrets, backups. Owna `04-infra.md`.
- Agente el Backend Developer (Backend Go): implementación idiomática, table-driven tests, sqlc + pgx.
- Agente el Frontend Developer (Frontend): React + TS strict + Vite + Tailwind + React Query + RHF/Zod.
- Agente el Mobile Developer (Mobile): React Native + Expo + secure storage + offline-first.

**Changed**
- Colores de agentes ahora son únicos (18 colores distintos). Mejora UX en `/agents`.
- README con tabla completa de agentes + fase asignada.
- `install.sh` actualizado a expected 18 agentes.

### Iteración 2 — Sesión 1 (2026-05-13)

**Added**
- Agente el Product Strategist (Product Strategy): MVP prioritization, kill criteria, roadmap interno.
- Agente el Legal & Compliance agent (Legal/Compliance): data protection, GDPR/Ley 25.326, consentimiento. NO reemplaza abogado matriculado.
- Agente el Release Manager (Release Manager): semver, CHANGELOG, rollback plans.
- `docs/context/STATE.md` como single source of truth de fase del proyecto. Todo agente lo lee al iniciar sesión.

**Changed**
- el Product Discovery agent: endurecidas reglas de cierre de Gate 0. No cede a presión de cronograma. Si hay riesgos críticos sin mitigación activa, no cierra aunque haya deadline externo.
- Skill `phase-gate`: añadido protocolo de loop de iteración. Reportes de iteración numerados (gate-N-iter-2.md, etc.).
- CLAUDE.md global: `STATE.md` agregado a docs obligatorias. Agentes ahora deben leerlo al iniciar sesión.

**Fixed**
- Loop de iteración del gate (era ambiguo quién dispara la reapertura).
- el Product Discovery agent cediendo a presión de calendario (detectado en dry-run de AgroScore Fase 0).

---

## Filosofía

Cinco principios que guiaron el diseño:

1. **Phase gates formales pero flexibles**: poder volver atrás cuando una fase posterior revela un hueco anterior.
2. **Adversarial collaboration**: el Devil's Advocate y las tensiones productivas entre agentes (el Software Architect ↔ el Security Architect ↔ el API Architect) previenen el sesgo de complacencia de los LLMs.
3. **Contexto como ciudadano de primera clase**: todo se escribe en MDs versionados. No hay memoria mágica.
4. **Opiniones fuertes con tradeoffs explícitos**: los agentes recomiendan, justifican, presentan qué se gana y qué se pierde. El usuario decide.
5. **Tres reglas duras anti-recurrencia**: sin wildcards en gateways, `EXECUTION.md` obligatorio desde Fase 4, toda desviación del default requiere ADR.

---

## Licencia

Setup personal. Usalo, modificalo, compartilo. Sin garantías.
