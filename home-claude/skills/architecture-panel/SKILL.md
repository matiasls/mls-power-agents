---
name: architecture-panel
description: Convene the architecture panel (the Software Architect + the Security Architect + the API Architect + Devil's Advocate) to design or review the system architecture in Fase 3B. Auto-invoke when user says "diseñar arquitectura", "panel de arquitectura", "/architecture-panel", "qué stack uso".
---

# Architecture Panel

Convoca al panel de arquitectura para diseñar o revisar el sistema. Es donde el Software Architect, el Security Architect, el API Architect y el Devil's Advocate debaten para producir la arquitectura final.

## Pre-requisitos

- `docs/context/01-functional-spec.md` debe existir (la spec funcional).
- `docs/context/02-mvp-scope.md` debe existir (qué entra y qué no en MVP).
- Si alguno no existe, ejecutar primero la fase correspondiente.

## Procedimiento

### Paso 1: Briefing inicial

Leer `00-discovery.md`, `01-problem.md`, `01-functional-spec.md` y `02-mvp-scope.md`.

Producir resumen al usuario: "Voy a convocar al panel. El sistema tiene que: [3-5 bullets sintetizando]. ¿Confirmás antes de arrancar?"

### Paso 2: el Software Architect propone arquitectura inicial

Invocar a `software-architect`: lee la spec funcional y MVP scope, propone arquitectura inicial con módulos (aplicando skill `modular-monolith`), stack tecnológico, decisiones grandes que requieren ADR, y lista de open questions.

### Paso 3: el Security Architect aporta perspectiva de seguridad

Invocar a `security-architect`: lee la propuesta del Software Architect, aplica skill `security-review` (y `gateway-hardening` si hay gateway), lista threats prioritarios y mitigaciones, e identifica conflictos con la propuesta.

### Paso 4: el API Architect aporta perspectiva de APIs

Invocar a `api-architect`: lee la propuesta y los hallazgos del Security Architect, diseña los contratos entre módulos, propone configuración de gateway, e identifica patterns (BFF, etc.) que justifican.

### Paso 5: Devil's Advocate cuestiona

Invocar a `devils-advocate`: identifica la decisión central del Software Architect, construye el contraargumento más fuerte, plantea 2-3 escenarios donde la decisión actual falla.

### Paso 6: el Cost Estimator estima costos (sanity check)

Invocar a `cost-estimator`: lee la propuesta consolidada, estima costos one-time + recurrentes 1 año, compara contra budget del usuario. Bandera roja si supera budget.

### Paso 7: Síntesis del Critic

Invocar a `critic`: lee TODOS los outputs anteriores e identifica áreas de consenso, conflictos reales sin resolver y decisiones que requieren input del usuario. Produce síntesis estructurada.

### Paso 8: Presentar al usuario

```markdown
# Architecture Panel — Síntesis

## Propuesta consolidada
- Módulos / Stack / Gateway / Decisiones grandes: [...]

## Acuerdos del panel
- ...

## Conflictos / decisiones pendientes del usuario
1. **<Decisión>**: el Software Architect propone A, el Security Architect prefiere B porque [...]. Devil's Advocate dice C.
   - [ ] Opción A
   - [ ] Opción B
   - [ ] Opción C

## Cost check
- MVP: USD ___ (Budget: USD ___) ✅ / ⚠️ / ❌
- Anual: USD ___

## Open questions para el usuario
- ...
```

### Paso 9: Capturar decisiones

Para cada decisión que el usuario tome:
- Crear o actualizar el ADR correspondiente en `docs/adr/`
- Actualizar `docs/context/03-architecture.md`, `03-tech-stack.md`, `03-security.md`, `03-api-design.md`, `03-gateway.md` según corresponda

### Paso 10: Ofrecer Gate 3B

"La arquitectura está propuesta. ¿Querés ejecutar `/phase-gate 3B` para validación formal y avanzar a Fase 4 (DevOps)?"

## Reglas duras

- **NO avanzar sin que el usuario decida los conflictos**.
- **CADA decisión no obvia requiere ADR**.
- **El gateway NUNCA tiene wildcards** — el Security Architect tiene veto sobre eso.
- **el Software Architect justifica desvíos del stack default por escrito**.
- **Si el Cost Estimator banderea rojo en costos, frenar y decidir**.

## Output esperado

- `docs/context/03-architecture.md`
- `docs/context/03-tech-stack.md`
- `docs/context/03-security.md`
- `docs/context/03-api-design.md`
- `docs/context/03-gateway.md` (si hay gateway)
- `docs/adr/NNNN-*.md` para cada decisión grande
- Resumen ejecutivo al usuario con decisiones pendientes
