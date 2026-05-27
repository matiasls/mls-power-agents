# CLAUDE.md — Personal Development Setup

> Instrucciones globales para todo el trabajo de desarrollo personal del usuario.
> Estas reglas se aplican siempre, en todos los proyectos personales.

## 1. Identidad del usuario y contexto

- **Perfil**: Senior application developer con experiencia corporativa.
- **Entorno**: macOS, VSCode/Cursor, terminal con zsh.
- **Naturaleza del trabajo**: Proyectos personales (no corporativos). Greenfield la mayoría de las veces.
- **Estilo de trabajo**: Iterativo, busca calidad sobre velocidad, valora el debate de ideas.

## 1.1. Project profile (CRITICAL — modula el rigor de los agentes)

**Cada proyecto declara su `project_profile` en su CLAUDE.md local**. Los agentes lo leen al iniciar sesión y ajustan su comportamiento.

Formato esperado en el CLAUDE.md del proyecto:

```yaml
project_profile:
  type: personal | mvp | commercial
  stakeholders: solo | small_team | external_parties
  timeline: flexible | soft_deadline | hard_external
  regulatory: none | medium | high
  data_sensitivity: none | personal | sensitive | regulated
  primary_goal: validate_problem | build_solution | both
```

### Cómo cada dimensión modula a los agentes

| Dimensión | Valor | Efecto en agentes |
|---|---|---|
| `type: personal` | | el Product Discovery agent hace discovery corta. el Product Strategist no exige kill criteria estrictos. Critic baja severidad de findings de proceso. |
| `type: mvp` | | Rigor estándar. Hipótesis críticas con métricas. Devil's Advocate activo en gates 1/2/3B. |
| `type: commercial` | | Rigor máximo. el Product Discovery agent aplica reglas duras anti-cierre. el Legal & Compliance agent profundiza. el Security Architect threat-model completo. |
| `stakeholders: solo` | | Nadie pregunta por sponsor, aprobaciones, equipo, dedicación. |
| `timeline: flexible` | | Nadie debate fechas. Si hay fecha tentativa irreal, se menciona como info, no como blocker. |
| `timeline: hard_external` | | Sí se discute scope-vs-fecha. el Cost Estimator calcula timeline real. |
| `regulatory: none` | | el Legal & Compliance agent no se activa salvo pedido explícito. |
| `regulatory: medium\|high` | | el Legal & Compliance agent activa por default desde Fase 2. |
| `data_sensitivity: regulated` | | el Security Architect + el Legal & Compliance agent coordinan obligatoriamente. STRIDE completo. |
| `primary_goal: build_solution` | | el Product Discovery agent toma 15-30 min. el Product Strategist va directo a scope. el Software Architect puede arrancar Fase 3B sin esperar gate formal de Fase 2. |
| `primary_goal: validate_problem` | | Foco en Fase 0-1. el Product Strategist es agresivo con MVP. Inversión en discovery. |
| `primary_goal: both` | | Default. Rigor estándar en todas las fases. |

### Defaults si no está declarado

Si el `project_profile` no está en el CLAUDE.md del proyecto, los agentes asumen el perfil más conservador:

```yaml
type: commercial
stakeholders: small_team
timeline: soft_deadline
regulatory: medium
data_sensitivity: personal
primary_goal: both
```

Esto es a propósito: el rigor por default es alto. Si querés rigor bajo, **declaralo explícitamente**.

### Regla del proyecto sobre el profile

El project_profile se declara **al inicio del proyecto** y se respeta. Si durante el proyecto el contexto cambia (ej: pasa de personal a comercial porque encontraste fit), se actualiza el profile **explícitamente** con un addendum en STATE.md, no de forma implícita.

## 2. Lenguaje de salida

| Contexto | Idioma |
|---|---|
| Conversación con el usuario | Español |
| Specs de producto, documentos de negocio, entrevistas | Español |
| Código, comentarios de código | Inglés |
| Docs técnicas (READMEs, ADRs, runbooks, API docs) | Inglés |
| Commits y mensajes de PR | Inglés |
| Output de agentes especialistas | Sigue su `output_language` en frontmatter; default español si no se especifica |

## 3. Stack tecnológico por default

Estos defaults se usan **salvo justificación explícita y escrita** del agente arquitecto:

- **Frontend web**: React + TypeScript + Vite + TailwindCSS
- **Mobile**: React Native + Expo
- **Backend**: Go (Golang) — Excepción: ML/Data Science → Python
- **Base de datos**: depende del caso (Postgres > SQLite > MongoDB > Redis), elegida por el arquitecto con justificación
- **Infra default**: Railway (con path de migración documentado a AWS o GCP)
- **Gateway**: decidido caso por caso por el arquitecto (ver skill `gateway-hardening`)
- **Manejo de secretos**: `.env` + `.gitignore`. Nunca commitear secretos. `.env.example` siempre presente.
- **Containerización**: Docker + docker-compose para local
- **CI/CD**: GitHub Actions

Cualquier desvío del default debe estar documentado en un ADR (`docs/adr/`).

## 4. Arquitectura: principios duros

### 4.1. Monolito modular, no microservicios prematuros

- **Default**: monolitos modulares con boundaries claros, NO un gran monolito.
- **División ejemplo** (sistema que ingesta datos, los procesa, sirve a clientes):
  - Servicio de ingesta (cronjobs, workers)
  - Servicio de portal cliente (API + autogestión)
  - Servicio de portal admin
  - Frontend(s) separado(s)
- **Cada módulo**: responsabilidad única, contratos claros con otros módulos, deployable independientemente si hace falta más adelante.
- **Microservicios solo si**: hay razón concreta (equipos separados, escalado distinto, lenguajes distintos por dominio). No por moda.

### 4.2. Seguridad de día uno

- **Backend siempre dentro de red privada** detrás de un gateway.
- **Gateway**: nunca configurado con wildcards. Cada endpoint declarado explícitamente. Rate limiting configurado por endpoint. Ver skill `gateway-hardening`.
- **Threat modeling** en fase de arquitectura, no después.
- **Secretos** nunca en repo. Validación automática en CI.

### 4.3. Testing mínimo

- **Coverage objetivo**: ≥85% para código de negocio (no incluye boilerplate, generated code, ni archivos triviales).
- **Pirámide de tests**:
  - Unit tests: la mayoría
  - Integration tests: para boundaries entre módulos del monolito modular
  - E2E tests: para flujos críticos
  - Contract tests: cuando hay APIs entre módulos
- **Go**: table-driven tests como default.
- **Frontend**: Vitest + React Testing Library + Playwright para E2E.

## 5. Documentación obligatoria

Todo proyecto personal debe tener:

| Archivo | Propósito | Cuándo se crea |
|---|---|---|
| `docs/context/STATE.md` | Single source of truth del estado del proyecto (fase actual, blockers, agente activo). Leído al inicio de toda sesión. | Fase 0, mantener actualizado en cada gate |
| `README.md` | Qué hace, para quién, cómo empezar | Fase 4 (DevOps) |
| `docs/EXECUTION.md` | Cómo ejecutar local, staging, prod (con comandos exactos) | Fase 4, mantener actualizado |
| `docs/ARCHITECTURE.md` | Vista de alto nivel de la arquitectura modular | Fase 3B |
| `docs/SECURITY.md` | Threat model, decisiones de seguridad, gateway config rationale | Fase 3B |
| `docs/adr/NNNN-titulo.md` | Architecture Decision Records (uno por decisión importante) | Continuo |
| `docs/runbooks/*.md` | Cómo operar el sistema en prod | Fase 6 |
| `CHANGELOG.md` | SemVer, mantenido por el Release Manager (Release Manager) | Fase 6 |

**Regla**: si la doc no existe o está desactualizada, el Doc Sentinel (Doc Sentinel) lo bloquea en el Gate correspondiente.

## 6. El flujo de fases

Todo proyecto sigue este flujo, con **phase gates formales pero flexibles** (se puede volver atrás si una fase posterior revela un hueco):

```
Fase 0 → Discovery (contexto, restricciones, MVP scope)
Fase 1 → Problem Definition (spec funcional)
Fase 2 → Product Decisions (MVP vs roadmap)
Fase 3A → UX/UI Design  ─┐
Fase 3B → Architecture   ─┴─► cross-review
Fase 4 → DevOps & Infra Setup
Fase 5 → Development (paralelo)
Fase 6 → Docs & Release
Fase 7 → Operations (continuo)
       ↓
    ciclo de evolución (post-Fase 6):
    /evolve feature    → agregar funcionalidad nueva
    /evolve hotfix     → bug crítico en producción
    /evolve refactor   → mejorar código sin cambios funcionales
    /evolve migration  → cambio tecnológico mayor
```

**Contexto compartido**: cada fase produce uno o más MDs versionados en `docs/context/`. Los agentes de fases siguientes los leen al iniciar. NO hay memoria mágica entre agentes — todo es explícito y auditable.

**Phase Gates**: al cierre de cada fase, el agente `critic` (más el `devils-advocate` para gates 1, 2, 3B) emite un reporte de revisión que el usuario aprueba/itera. Ver skill `phase-gate`.

**Ciclo de evolución**: una vez que el proyecto pasa Fase 6 (released), evoluciona con el skill `evolve`. NO se vuelve a Fase 0/1 para cada feature — eso sería overhead masivo. El skill `evolve` reusa los 19 agentes existentes con un orden y profundidad calibrados a cada modo (feature/hotfix/refactor/migration). Ver skill `evolve`.

## 7. Las 5 preguntas que el setup elimina

Estas preguntas que el usuario antes repetía en cada proyecto YA están resueltas por las reglas y los agentes. No deben surgir más:

1. **¿Cómo ejecuto el sistema?** → Skill `execution-runbook` exige `docs/EXECUTION.md` con local + staging + prod. Bloqueante en Gate 4.
2. **¿Cuál es el stack recomendado?** → Defaults sección 3. el Software Architect (arquitecto) debe justificar por escrito cualquier desvío.
3. **¿Están todas las barreras de seguridad aplicadas?** → el Security Architect (security) ejecuta checklist en Gate 3B y Gate 5. Skill `security-checklist`.
4. **¿Está todo documentado?** → el Doc Sentinel (doc sentinel) verifica continuamente. Sección 5 lista la doc obligatoria.
5. **¿Qué gateway poner y está bien configurado sin wildcards?** → Skill `gateway-hardening` con matriz de decisión y checklist anti-wildcard.

Si el usuario hace alguna de estas preguntas, significa que algún agente falló su trabajo. Marcalo y resolvelo en vez de simplemente responder.

## 8. Reglas de comportamiento de los agentes

- **Opiniones fuertes**: los agentes tienen posiciones definidas y las defienden. No son complacientes.
- **Disagreement productivo**: cuando dos agentes discrepan, lo explicitan, presentan tradeoffs, y el usuario decide.
- **No asumir, preguntar**: en decisiones grandes (>2 días de trabajo), el agente pregunta antes de avanzar.
- **Justificar con tradeoffs**: toda recomendación viene con "qué se gana, qué se pierde".
- **Honestidad sobre incertidumbre**: si un agente no sabe, lo dice. No inventar.

## 9. Cuándo usar Claude.ai web vs Claude Code

| Fase | Recomendado |
|---|---|
| 0, 1, 2 | Claude.ai web (Project) — conversacional, iterativo |
| 3A (UX) | Claude.ai web + Claude Code para prototipos |
| 3B (Arquitectura) | Claude Code (más control, puede tocar archivos) |
| 4, 5, 6, 7 | Claude Code |

El contexto se traspasa exportando los MDs de cada fase y commiteándolos al repo.

## 10. Reglas de protección anti-burnout y anti-overengineering

- **Si un agente propone construir >2 cosas a la vez en MVP**, Critic lo bloquea.
- **Si el costo estimado del MVP supera lo que el usuario dijo que podía gastar**, el Cost Estimator (Cost) levanta bandera.
- **Si el timeline es <50% del estimado realista**, Critic lo señala.
- **El MVP es lo mínimo que valida la hipótesis**, no la versión 1.0 del producto.
- **El recorte temprano es 4-10× más barato que el recorte tardío**. Cortar en Fase 1 cuesta horas del Business Analyst; cortar en Fase 5 cuesta días de código deshecho. Cortar agresivo es decisión técnica, no debilidad de visión.

## 11. Patrones detectados en proyectos previos (Sesión 6, lecciones de splitwise-mini)

Estos 4 patrones aparecieron en la corrida completa del framework con splitwise-mini. Los agentes deben conocerlos para reconocerlos en proyectos nuevos.

### 11.1 Sobre-entrega multi-agente en fases paralelas

En fases con ≥3 agentes paralelos (típicamente Fase 3 con el UX Designer + el UI Designer + el Software Architect + el Security Architect + el API Architect), cada agente sobre-entrega por su propio incentivo a demostrar rigor en su dominio. El sistema completo termina calibrado a un MVP 10× más grande.

**Mecanismos del framework**:
- **DA bloqueante obligatorio en Gates 1, 2, 3B**. Su Plan B es decisión, no opinión.
- **Skill `relevance-filter`** obligatorio para cada agente especialista: cada artefacto incluye sección "Filtro de relevancia" que cita literalmente el MVP scope.
- **Activación automática del `adversarial-review`** cuando una fase tiene ≥3 agentes paralelos.
- **Plan B aplicado por addendum firmado** (skill `plan-b-addendum`), NO relanzando agentes.

### 11.2 Sub-entrega de inputs heredados

Para evitar sobre-entrega, los agentes técnicos (el DevOps & Platform agent, el Backend Developer, el Frontend Developer) tienden a saltarse compromisos del gate previo. La advertencia "no sobre-entregues" sin la contraparte "y cumplí lo heredado al 100%" genera este efecto.

**Mecanismos del framework**:
- **Tabla "Inputs heredados de gates previos"** obligatoria en cada doc de fase técnica.
- **Diferir un input duro requiere ADR escrito**. Sin ADR, el gate falla.
- **El Critic usa la tabla como matriz de verificación obligatoria** (Paso 4a de `phase-gate`).

### 11.3 Warnings se evaporan sin enforcement mecánico

Warnings con "owner asignado" se difieren entre fases. En splitwise-mini, 2 de 3 bloqueantes en Gate 5 eran warnings explícitos de Gate 4 que se evaporaron. Costo del patrón: 4× más caro resolver en el gate siguiente que en el mismo gate.

**Mecanismos del framework**:
- **Estados de finding**: solo `RESOLVED`, `BLOCKED_BY_TOOL` o `RISK_ACCEPTED` (con ADR) permiten cerrar gate.
- **`BLOCKED_BY_PROCESS` no permite cerrar**: gate se reabre hasta que el finding tenga tool.
- **Cada finding bloqueante debe tener un comando que falla** si el problema reaparece.

### 11.4 Cross-review pasa "en papel" sin artefacto único

Cuando 2+ agentes trabajan en paralelo (Fase 3A ↔ 3B), tienden a "firmar cada uno su parte" y "delegar al Gate la integración". La cross-review queda como mención cruzada entre docs, no como acuerdo explícito.

**Mecanismos del framework**:
- **`docs/context/03-cross-review-notes.md` es single source of truth**.
- Cada item de cross-review se escribe ahí con `id`, `description`, `proposed_by`, `responder`, `status`, `resolution`.
- **El Critic valida que todos los items estén `resolved` o `risk_accepted` con ADR**.
- Sign-off final con iniciales de cada agente afectado.

## 12. Cómo invocar agentes

- Por nombre explícito: "Que el Software Architect revise la arquitectura"
- Por slash command: `/architecture-panel`, `/security-review`, etc.
- Auto-delegación: Claude Code elige el agente según el `description` de cada uno
- En paneles: varios agentes participan secuencialmente, ver skill `adversarial-review`

## 13. Persistencia del contexto del proyecto

Cada proyecto tiene `docs/context/` con MDs numerados por fase. Los agentes:

1. **Al iniciar sesión**: leen `docs/context/STATE.md` para entender en qué fase está el proyecto, qué bloqueantes hay abiertos, qué agente trabajó por última vez. SIN ESTO, los agentes operan a ciegas.
2. **Al actuar**: producen su output como un MD en `docs/context/`.
3. **Al cerrar fase**: escriben el gate report en `docs/context/gates/` Y actualizan `STATE.md`.

Esto es OBLIGATORIO. Sin contexto compartido, los agentes se contradicen entre fases.

---

*Última revisión: setup inicial Iteración 1.*
*Para modificar este archivo, considerar si la regla aplica a todos los proyectos personales o solo al actual.*
