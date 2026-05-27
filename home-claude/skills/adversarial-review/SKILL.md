---
name: adversarial-review
description: Run an adversarial multi-agent panel to stress-test a major decision. Use when facing big architectural choices, MVP scoping decisions, or any decision where complacency would be expensive. Invoke explicitly with /architecture-panel or when user says "panel", "que debatan", "que se discuta", "tradeoffs".
---

# Adversarial Review Panel

Este skill ejecuta un panel adversarial entre agentes para estresar una decisión importante.

## Cuándo usar

- Decisiones de arquitectura grandes (monolito vs micro, stack principal, gateway, BD).
- Decisión de MVP scope.
- Cualquier decisión de >2 días de trabajo.
- Cuando el usuario dice "no estoy seguro" sobre una decisión importante.
- Auto-invocar cuando el Software Architect (architect) presenta una arquitectura propuesta y antes de finalizarla.

## Activación automática (desde Sesión 6)

**El skill se activa automáticamente cuando se cumple cualquiera de estas condiciones**:

1. Una fase tiene **≥3 agentes especialistas trabajando en paralelo** (típicamente Fase 3 con el UX Designer + el UI Designer + el Software Architect + el Security Architect + el API Architect).
2. El gate de la fase está a punto de cerrar Y la fase produjo >1000 líneas combinadas de Markdown.
3. Hay una decisión central que afecta a ≥3 dominios distintos.
4. El Critic detecta un patrón de "entregables justificados pero potencialmente desproporcionados al MVP".

**Por qué este cambio**: en splitwise-mini, los 3 Plan B del DA en gates 1, 2 y 3 fueron adoptados. Sin el DA, el MVP habría salido con scope 30-50% inflado. El DA es **bloqueante real, no decorativo** — debe activarse por defecto en estos casos, no depender de que el usuario "lo invoque".

## Instrucción especial al DA en panel sobre fases multi-agente

Cuando el DA se activa por una fase multi-agente (≥3 agentes paralelos), su prompt debe incluir explícitamente:

> *"Cuestioná especialmente la **proporción del entregable al MVP declarado**, no solo decisiones individuales. Mirá si cada agente sobre-entregó por incentivo a demostrar rigor en su dominio. Buscá: amenazas que no se materializarán al volumen real, módulos que son boundaries de papel, error codes redundantes, features defensivas para escala que no existe."*

## Procedimiento

### Paso 1: Identificar la decisión

Una sola decisión central, no una lista. Ej:
- "¿Monolito modular o microservicios?"
- "¿Postgres o DynamoDB?"
- "¿Caddy, KrakenD o Traefik como gateway?"
- "¿El MVP incluye dashboard del cliente o solo API?"

### Paso 2: Identificar los participantes

Según la decisión, convocar entre 2-4 agentes con perspectivas distintas:

| Tipo de decisión | Panel sugerido |
|---|---|
| Arquitectura general | el Software Architect + el Security Architect + el API Architect + Devil's Advocate |
| Stack tecnológico | el Software Architect + dev del stack + el Cost Estimator |
| Seguridad vs simplicidad | el Security Architect + el Software Architect + el Cost Estimator |
| API design | el API Architect + el Software Architect + (el Frontend Developer o el Mobile Developer) |
| MVP scope | el Product Discovery agent + el Product Strategist + el Cost Estimator |

### Paso 3: Ejecutar las rondas

#### Ronda 1: Propuestas

Cada agente propone su posición SIN ver las de los demás (en mensajes separados).

Cada propuesta debe tener:
- La decisión recomendada
- Justificación en 3-5 bullets
- Tradeoffs reconocidos

#### Ronda 2: Critique

Cada agente lee las propuestas de los otros y critica:
- ¿Qué es débil en cada una?
- ¿Qué tradeoff no se mencionó?
- ¿Hay un escenario donde esa propuesta falla?

#### Ronda 3: Devil's Advocate

El Devil's Advocate construye el contraargumento más fuerte a la propuesta dominante.

#### Ronda 4: Síntesis del Critic

El Critic sintetiza:
- Áreas de consenso entre agentes
- Puntos de disenso reales
- Recomendación final con tradeoffs explícitos

### Paso 4: Presentar al usuario

Formato:

```markdown
# Panel: <decisión>

## Propuestas

### el Software Architect propone: <X>
- ...
- Tradeoff principal: ...

### el Security Architect propone: <Y>
- ...

### ...

## Críticas cruzadas

- el Software Architect sobre la propuesta del Security Architect: ...
- el Security Architect sobre la propuesta del Software Architect: ...

## Devil's Advocate dice
[Contraargumento fuerte]

## Síntesis del Critic

**Áreas de consenso**: 
- ...

**Disenso real**: 
- ...

**Recomendación**: <opción A | opción B | opción híbrida>
**Por qué**: ...
**Lo que se gana**: ...
**Lo que se pierde**: ...

## Decisión del usuario
- [ ] Opción A
- [ ] Opción B
- [ ] Opción híbrida
- [ ] Necesito más info: ___
```

### Paso 5: Capturar la decisión

Una vez que el usuario decide:
1. Crear un ADR en `docs/adr/NNNN-<decision>.md` capturando la decisión y los tradeoffs.
2. El ADR lista las alternativas consideradas y por qué se descartaron.

## Reglas duras

- **Mínimo 2 propuestas distintas**. Si todos los agentes proponen lo mismo, llamá al Devil's Advocate para que cuestione.
- **Tradeoffs siempre explícitos**. No se aprueba una decisión sin "lo que se pierde".
- **El usuario decide**. Los agentes no votan.
- **Tiempo máximo del panel**: 2-3 rondas. No infinitas.

## Anti-patterns a evitar

- **Strawmanning**: que un agente caricaturice la propuesta de otro. Si pasa, marcalo.
- **Consenso falso**: si todos están de acuerdo en algo no obvio, sospechar.
- **Decisión por agotamiento**: si el debate se vuelve circular, el Critic corta y propone síntesis.
