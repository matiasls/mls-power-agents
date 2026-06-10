# CLAUDE.md — Personal Development Setup

> Instrucciones globales para todo el trabajo de desarrollo personal del usuario.
> Estas reglas se aplican siempre, en todos los proyectos personales.

## 1. Identidad del usuario y contexto

- **Perfil**: Senior application developer con experiencia corporativa.
- **Entorno**: macOS, VSCode/Cursor, terminal con zsh.
- **Naturaleza del trabajo**: Proyectos personales (no corporativos). Greenfield la mayoría de las veces.
- **Estilo de trabajo**: Iterativo, busca calidad sobre velocidad, valora el debate de ideas.

## 1.1. Project profile (CRITICAL — modula el rigor de los agentes)

**Cada proyecto declara su `project_profile` en su CLAUDE.md local**. Los agentes lo leen al iniciar sesión y ajustan su comportamiento. Esta sección es la **única fuente canónica** de la modulación: los agentes la referencian, no la re-explican.

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
- **Cada módulo**: responsabilidad única, contratos claros con otros módulos, deployable independientemente si hace falta más adelante.
- **Microservicios solo si**: hay razón concreta (equipos separados, escalado distinto, lenguajes distintos por dominio). No por moda.

### 4.2. Seguridad de día uno

- **Backend siempre dentro de red privada** detrás de un gateway.
- **Gateway**: nunca configurado con wildcards. Cada endpoint declarado explícitamente. Rate limiting configurado por endpoint. Ver skill `gateway-hardening`.
- **Threat modeling** en fase de arquitectura, no después (skill `security-review`).
- **Secretos** nunca en repo. Validación automática en CI.

### 4.3. Testing mínimo

- **Coverage objetivo**: ≥85% para código de negocio (no incluye boilerplate, generated code, ni archivos triviales).
- **Pirámide**: unit tests (mayoría) → integration tests (boundaries entre módulos) → E2E (flujos críticos) → contract tests (APIs entre módulos).
- **Go**: table-driven tests como default. **Frontend**: Vitest + React Testing Library + Playwright para E2E.

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
| `CHANGELOG.md` | SemVer, mantenido por el Release Manager | Fase 6 |

**Regla**: si la doc no existe o está desactualizada, el Doc Sentinel lo bloquea en el Gate correspondiente.

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
    /evolve feature | hotfix | refactor | migration
```

**Contexto compartido**: cada fase produce uno o más MDs versionados en `docs/context/`. Los agentes de fases siguientes los leen al iniciar. NO hay memoria mágica entre agentes — todo es explícito y auditable.

**Phase Gates**: al cierre de cada fase, el agente `critic` (más el `devils-advocate` para gates 1, 2, 3B) emite un reporte que el usuario aprueba/itera. Ver skill `phase-gate` (incluye filtro de relevancia, Plan B por addendum y cross-review entre fases paralelas).

**Ciclo de evolución**: una vez released (post-Fase 6), el proyecto evoluciona con el skill `evolve` (feature/hotfix/refactor/migration). NO se vuelve a Fase 0/1 para cada feature.

## 7. Las 5 preguntas que el setup elimina

Estas preguntas YA están resueltas por las reglas y los agentes:

1. **¿Cómo ejecuto el sistema?** → Skill `how-to-run` exige `docs/EXECUTION.md` con local + staging + prod. Bloqueante en Gate 4.
2. **¿Cuál es el stack recomendado?** → Defaults sección 3. El Software Architect justifica desvíos por escrito (ADR).
3. **¿Están todas las barreras de seguridad aplicadas?** → El Security Architect ejecuta el skill `security-review` en Gate 3B y Gate 5.
4. **¿Está todo documentado?** → El Doc Sentinel verifica continuamente. Sección 5 lista la doc obligatoria.
5. **¿Qué gateway poner y está bien configurado sin wildcards?** → Skill `gateway-hardening` con matriz de decisión y checklist anti-wildcard.

Si el usuario hace alguna de estas preguntas, algún agente falló su trabajo. Marcalo y resolvelo en vez de simplemente responder.

## 8. Reglas de comportamiento de los agentes

- **Opiniones fuertes**: los agentes tienen posiciones definidas y las defienden. No son complacientes.
- **Disagreement productivo**: cuando dos agentes discrepan, lo explicitan, presentan tradeoffs, y el usuario decide.
- **No asumir, preguntar**: en decisiones grandes (>2 días de trabajo), el agente pregunta antes de avanzar.
- **Justificar con tradeoffs**: toda recomendación viene con "qué se gana, qué se pierde".
- **Honestidad sobre incertidumbre**: si un agente no sabe, lo dice. No inventar.

## 9. Cuándo usar Claude.ai web vs Claude Code

Fases 0-2 y 3A: Claude.ai web (conversacional, iterativo) o Claude Code indistintamente. Fases 3B-7: Claude Code (control de archivos). El contexto se traspasa commiteando los MDs de cada fase al repo.

## 10. Reglas de protección anti-burnout y anti-overengineering

- **Si un agente propone construir >2 cosas a la vez en MVP**, Critic lo bloquea.
- **Si el costo estimado del MVP supera lo declarado por el usuario**, el Cost Estimator levanta bandera.
- **Si el timeline es <50% del estimado realista**, Critic lo señala.
- **El MVP es lo mínimo que valida la hipótesis**, no la versión 1.0 del producto.
- **El recorte temprano es 4-10× más barato que el recorte tardío.** Cortar agresivo es decisión técnica, no debilidad de visión.

## 11. Patrones anti-falla del framework

Cuatro patrones de falla conocidos, con su mecanismo de enforcement (la mecánica completa vive en el skill `phase-gate`):

1. **Sobre-entrega multi-agente en fases paralelas** → filtro de relevancia obligatorio por artefacto (sección en `phase-gate`) + DA bloqueante en Gates 1/2/3B.
2. **Sub-entrega de inputs heredados** → tabla "Inputs heredados de gates previos" obligatoria en cada fase técnica; diferir requiere ADR (`phase-gate` Paso 4a).
3. **Warnings que se evaporan entre fases** → estados de finding `RESOLVED`/`BLOCKED_BY_TOOL`/`RISK_ACCEPTED`(con ADR); `BLOCKED_BY_PROCESS` no cierra gate (`phase-gate` Paso 4c).
4. **Cross-review "en papel"** → `docs/context/03-cross-review-notes.md` como single source of truth con sign-off (sección en `phase-gate`).

## 12. Cómo invocar agentes

- Por nombre explícito: "Que el Software Architect revise la arquitectura"
- Por slash command: `/architecture-panel`, `/security-review`, etc.
- Auto-delegación: Claude Code elige el agente según el `description` de cada uno
- En paneles: varios agentes participan secuencialmente, ver skill `adversarial-review`

## 13. Persistencia del contexto del proyecto

Cada proyecto tiene `docs/context/` con MDs numerados por fase. Los agentes:

1. **Al iniciar sesión**: leen `docs/context/STATE.md` para entender fase actual, bloqueantes abiertos y último agente activo. SIN ESTO, operan a ciegas.
2. **Al actuar**: producen su output como un MD en `docs/context/`.
3. **Al cerrar fase**: escriben el gate report en `docs/context/gates/` Y actualizan `STATE.md`.

Esto es OBLIGATORIO. Sin contexto compartido, los agentes se contradicen entre fases.

---

*Para modificar este archivo, considerar si la regla aplica a todos los proyectos personales o solo al actual.*
