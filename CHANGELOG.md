# Changelog del setup

> Historial de iteraciones y sesiones de desarrollo del framework.
> El estado actual está documentado en README.md.

## Resumen de versiones

- **Iteración 1**: 9 agentes, 11 skills, 1 template (web-fullstack), install.sh. Agentes con nombres propios (Sofía, Diego, etc.).
- **Iteración 2 — Sesión 1**: 12 agentes (+Product Strategist, +Legal & Compliance agent, +Release Manager), ajustes al Product Discovery agent y phase-gate, STATE.md introducido.
- **Iteración 2 — Sesión 2**: 18 agentes — todos los principales completos. Colores únicos por agente.
- **Iteración 2 — Sesión 3**: 23 skills (+12 nuevos), 4 templates (+3 nuevos: mobile-rn, python-ml-service, static-site), mecánicas operativas. **Iteración 2 cerrada**.
- **Iteración 3 — Sesión 4**: re-calibración del rigor por contexto (`project_profile`), agente Research Analyst.
- **Iteración 3 — Sesión 5**: mockups HTML+Tailwind como entregable de Fase 3A.
- **Iteración 3 — Sesión 6**: correcciones estructurales por aprendizaje real (relevance-filter, plan-b-addendum, inputs heredados, enforcement mecánico, cross-review single source).
- **Iteración 3 — Sesión 7**: prototipos interactivos con JS de simulación + ciclo de evolución post-Fase 6 (`/evolve` con 4 modos).
- **Iteración 3 — Sesión 8**: **renombrado de agentes**. Eliminados nombres propios (Sofía, Diego, Iván, etc.) en favor de roles puros (product-discovery, software-architect, security-architect, etc.). Tono profesional preservando carácter funcional.
- **Iteración 4 — Sesión 9**: **consolidación y optimización de tokens**. 27 → 21 skills, agentes adelgazados ~25%, CLAUDE.md global 269 → ~205 líneas.
- **Iteración 4 — Sesión 10** (actual): **doctrina Propose-first + Grounding**. Los agentes dejan de interrogar: producen completo, recomiendan, declaran supuestos. Control humano solo en gates + dinero + deploy + publicación.

## Changelog del setup

### Iteración 4 — Sesión 10 (2026-06-10) — doctrina Propose-first + Grounding

**Trigger**: el kickoff real de AgroScore expuso el problema — el Product Discovery hizo 3 preguntas BLOQUEANTES (¿tenés el dataset?, ¿quién hace el outreach?, ¿qué MVP querés?) más 4 de calibración (background del usuario, kill criterion, proveedores) y se negó a escribir `00-discovery.md` sin respuestas. El framework estaba calibrado para validar una startup con un founder que ejecuta, no para que la IA construya. El "No asumir, preguntar" de §8 contradecía la modulación de §1.1.

**CLAUDE.md global — §8 reescrita: "Doctrina de los agentes: Propose-first"**
- §8.1: producí siempre (lagunas: docs → investigación → supuesto con default); recomendá siempre UNA opción; tabla "## Supuestos" obligatoria; máx 3 "Decisiones para el usuario" con default ("sin respuesta = avanzo con la recomendada"); temas prohibidos (staffing/equipo, background del usuario, disponibilidad actual de datos de terceros → "Prerequisitos de implementación"); puntos de control humano: gates + dinero real + deploy a prod + publicar; el disenso se resuelve entre agentes.
- §8.2 Grounding: base epistémica obligatoria por afirmación (HECHO con cita / INFERENCIA con razonamiento / SUPUESTO en tabla); datos duros solo de fuente verificable; citas reales con spot-check del Critic; lo investigable se investiga antes de asumirse (research-analyst como herramienta anti-alucinación); preguntar solo lo genuinamente indefinido.
- Eliminado: "No asumir, preguntar: en decisiones grandes (>2 días) el agente pregunta antes de avanzar".

**Agentes**
- `product-discovery`: rewrite profundo — de "entrevistar y esperar" a "leer, extraer (con cita), inferir, asumir con default, proponer". Produce `00-discovery.md` COMPLETO de una pasada con recomendación de corte de MVP fundamentada y kill criteria propuestos. Doc funcional existente = fuente primaria. Las reglas anti-cierre se ejercen POR ESCRITO (riesgos al gate), no bloqueando.
- `product-strategy`: propone EL corte recomendado con alternativas descartadas; kill criteria propuestos; secciones Supuestos/Decisiones en el template.
- `business-analyst`: resuelve ambigüedades con interpretación propuesta + supuesto declarado; solo escala bifurcaciones radicales (con default); propone el comportamiento de cada edge case.
- `critic`: checks nuevos de doctrina (2a): Supuestos presentes, decisiones con default, temas prohibidos → finding "propose-first violation", spot-check de grounding ("ungrounded claim"); el gate report SIEMPRE cierra con recomendación explícita del Critic.
- `legal-compliance`, `research-analyst`, `cost-estimator`, `api-architect`, `software-architect`, `ux-designer`, `ui-designer`: sección de doctrina + conversión de "## Preguntas para el usuario" (espera bloqueante) a "## Decisiones para el usuario" (con default, sin espera); legal extrae PII/jurisdicción de los docs; research interpreta pedidos vagos con contexto; cost no bloquea sin presupuesto; open questions inter-agente van a cross-review-notes, nunca al usuario.

**Skills**
- `kickoff`: rewrite — elimina "5-8 preguntas / esperar respuestas / iterar"; el discovery sale completo de una pasada; soporta doc funcional como fuente primaria (`/kickoff "<desc> — spec en <path>"`).
- `phase-gate`: check transversal de doctrina en 4b; recomendación del Critic en el Paso 5; BLOCKED_BY_PROCESS gana vía de salida (el agente redacta el ADR de riesgo aceptado, el usuario solo firma); regla de control humano explícita (dinero/deploy/publicar siempre consultan).
- `mvp-prioritization`: mapeo automático features↔hipótesis (auto-interrogación, no pregunta al usuario); produce el corte recomendado.
- `evolve`: modo inferido si la señal es clara (declarado en 1 línea); pregunta solo ambigüedad genuina entre modos.
- `retroactive-update`: el agente recomienda el nivel (tweak/patch/major) y procede; solo restart se eleva al gate.

**Instalaciones existentes**: re-correr `./install.sh` para actualizar `~/.claude/`.

### Iteración 4 — Sesión 9 (2026-06-10) — consolidación y optimización

**Trigger**: auditoría completa del repo buscando sobre-complejidad, contenido que los modelos frontier 2026 ya manejan nativamente, y oportunidades de ahorro de tokens (las descriptions de agentes y skills se cargan en TODA sesión; los cuerpos solo al invocar).

**Skills: 27 → 21 (merges, no pérdida de mecanismos)**
- `execution-runbook` → mergeada en `how-to-run` (ambas generaban `docs/EXECUTION.md`).
- `security-checklist` + `threat-modeling` → mergeadas en `security-review` (STRIDE sistemático + checklists por tipo de app + orquestación, sin definiciones de libro).
- `relevance-filter` + `plan-b-addendum` + `cross-review` → ahora son secciones del skill `phase-gate`. Los 3 mecanismos anti-patrones se preservan íntegros.
- **Instalaciones existentes**: re-correr `./install.sh` — limpia automáticamente las 6 skills deprecadas de `~/.claude/skills/` (sin esto, siguen cargando en cada sesión).

**Resource files (se cargan solo on-demand)**
- `enforce-rules`: YAML de GitHub Actions y hooks → `resources/` (372 → 80 líneas).
- `mockup-generation`: HTML/Tailwind/Alpine boilerplate → `resources/` (585 → 232).
- `adr-writing`: template + ejemplo → `resources/` (173 → 50).
- `gateway-hardening`: configs Caddy/KrakenD/Traefik → `resources/` (337 → 149). Matriz de decisión y checklist anti-wildcard intactos.

**Agentes: 19 (sin eliminaciones), ~3.900 → ~2.700 líneas**
- Demociones de modelo: `ui-designer` y `devops-platform` opus → sonnet (12 opus / 7 sonnet).
- Modulación por `project_profile`: los 4 agentes que re-explicaban la tabla ahora referencian CLAUDE.md global §1.1 (fuente canónica única) + su delta específico.
- Tabla "Inputs heredados": deduplicada en 5 agentes, copia canónica en `phase-gate` Paso 4a.
- Scaffolding de código estándar (Go/React/RN) eliminado del trío de developers; convenciones house preservadas como bullets.
- Fix de agentes entrevistadores: cuando corren como subagentes devuelven sus preguntas como sección "## Preguntas para el usuario" (no pueden interactuar a mitad de ejecución).

**Limpieza de contenido**
- Anécdotas históricas (splitwise-mini, "Sesión N", leftovers de AgroScore) eliminadas de prompts operativos; las reglas que justificaban se mantienen. La historia vive en este CHANGELOG.
- Nombres viejos de agentes corregidos: `bruno-mobile` (template mobile-rn), `ivan-security` (security-review), `sara-doc-sentinel` (phase-gate, docs-audit), `sofia-discovery` (kickoff), `diego-architect`/`pablo-api`/`renata-cost` (architecture-panel).

**Docs**
- CLAUDE.md global: 269 → ~205 líneas. §11 "patrones detectados" comprimida a 4 one-liners con puntero al enforcement en `phase-gate`. §9 comprimida.
- README: changelog extraído a este archivo; tablas de agentes/skills actualizadas; sección nueva sobre dónde se declara el `project_profile`.
- Templates: READMEs de adr/ y runbooks/ adelgazados (62/56 → ~11 líneas, apuntando a los skills).
- install.sh: conteo de skills 27 → 21 + array `DEPRECATED_SKILLS` con limpieza automática.

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
