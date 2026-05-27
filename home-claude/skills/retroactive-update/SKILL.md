---
name: retroactive-update
description: When a later phase reveals a gap, contradiction, or new info that affects earlier phases, update the earlier artifacts properly without losing history. Use whenever an agent finds that a previous decision needs revision. Auto-invoke when user says "actualizar fase anterior", "esto contradice X", "hay que volver atrás", "/retroactive".
---

# Retroactive Update

Skill para manejar el escenario común: una fase posterior revela un hueco en una fase anterior. El sistema debe permitir corregir sin perder trazabilidad. La filosofía: no rehacemos la fase, la enmendamos.

## Cuándo se dispara

Casos típicos:
- En Fase 3B (arquitectura), el Software Architect encuentra que un UC del Business Analyst (Fase 1) tiene ambigüedad técnica que cambia el diseño.
- En Fase 5 (development), el Backend Developer encuentra que un endpoint del API design del API Architect (Fase 3B) tiene un edge case no contemplado.
- En Fase 4 (DevOps), el DevOps & Platform agent descubre que el budget de infra excede lo estimado por el Cost Estimator en Fase 2.
- Llega información externa nueva: el design partner cancela, sale una ley, cambia un precio importante.

## Reglas duras

1. **NO se sobreescribe el doc original**. Los entregables de cada fase son inmutables como base histórica.
2. **Se crea un addendum** con la corrección y razón.
3. **El gate report original se actualiza** marcando que tuvo addendum.
4. **STATE.md se actualiza** reflejando que hay un hallazgo retroactivo.
5. **Si la corrección es estructural (cambia >30% del scope)**: NO es addendum, es rehacer la fase con un nuevo gate.

## Niveles de corrección

| Nivel | Cuándo aplica | Mecanismo |
|---|---|---|
| **Tweak** | Aclaración menor, sin cambiar decisiones | Addendum chiquito |
| **Patch** | Una decisión específica cambia, sin afectar el resto | Addendum + ADR si aplica |
| **Mayor** | Cambia >1 decisión o afecta a otras fases ya cerradas | Re-abrir gate de la fase afectada |
| **Restart** | El cambio invalida la fase entera | Rehacer la fase con nuevo gate |

## Procedimiento

### Paso 1: Identificar el conflicto

Quien lo encuentra (agente o usuario) escribe:
- **Qué se descubrió**: hallazgo concreto
- **De dónde viene** (qué actividad lo reveló)
- **A qué fase / artifact afecta** (referencia exacta)
- **Severidad propuesta**: tweak / patch / mayor / restart

### Paso 2: Validar la severidad

El Critic valida la severidad propuesta. Si discrepa, escala al usuario para decisión.

### Paso 3: Para nivel TWEAK o PATCH

Crear addendum:

```markdown
# 0X-<fase>-addendum-NN.md

**Tipo**: Addendum a `0X-<fase>.md`
**Fecha**: YYYY-MM-DD
**Origen**: Descubierto en <fase / agente / actividad>
**Severidad**: tweak | patch

## Hallazgo

[Descripción concreta del hallazgo]

## Decisión / cambio

[Qué se decide / cambia ahora]

## Impacto en el artifact original

[Qué secciones del doc original quedan afectadas. NO se editan, solo se referencia.]

Ejemplo:
- Sección "Hipótesis 2" del `00-discovery.md`: ahora se interpreta como ___
- BR-005 del `01-functional-spec.md`: se agrega edge case ___

## Impacto en fases posteriores

- Fase X: <impacto y acción>
- Fase Y: <impacto y acción>

## Quién aprobó

- [Agente]: <nombre>
- Usuario: <fecha aprobación>
```

### Paso 4: Para nivel MAYOR

- Re-abrir el gate de la fase afectada con `/phase-gate N --reopen`.
- El gate report del Critic incluye los hallazgos retroactivos.
- Posiblemente requiere ajustar fases intermedias entre la afectada y la actual.

### Paso 5: Para nivel RESTART

- Rehacer la fase con un nuevo gate (gate-N-restart-YYYYMMDD).
- Versionar el artifact original como `0X-<fase>-v1-deprecated.md` y crear nuevo `0X-<fase>.md`.
- Re-evaluar fases posteriores que dependían del artifact viejo.

### Paso 6: Actualizar STATE.md

Agregar entrada al historial de la fase afectada:

```markdown
## Phase history

| Phase | Status | Gate report | Closed at | Notes |
|---|---|---|---|---|
| 1 - Problem Definition | AMENDED (patch) | gate-1-discovery.md + addendum-01 | 2026-05-10 | Patch from Fase 3B finding |
```

### Paso 7: Notificar a agentes downstream

Los agentes de fases posteriores deben re-leer la fase afectada en sus próximas activaciones. El skill puede insertar una nota en el STATE.md que avise:

```markdown
## Open downstream impacts

- el Business Analyst (Fase 1): addendum-01 added. Re-read before next activation.
- el Software Architect (Fase 3B): impacted by el Business Analyst's addendum-01. Decide if re-design needed.
```

## Anti-patterns

1. **Editar el artifact original directamente**: rompe trazabilidad. Siempre addendum o re-fase.
2. **Hacer commits "fix" sin documentar la razón**: el "por qué cambió" se pierde.
3. **Skipear el cambio de severidad**: empezar con tweak cuando es mayor → sorpresas downstream.
4. **No notificar a agentes downstream**: ellos pueden seguir trabajando sobre supuestos viejos.
5. **Acumular muchos addendum sin consolidar**: si una fase tiene >3 addenda significativos, conviene un restart limpio.

## Ejemplos

### Ejemplo 1: TWEAK

el Software Architect descubre en Fase 3B que el actor "Administrador" mencionado en `01-functional-spec.md` no especifica qué pasa con sub-administradores. Es un edge case menor, no afecta el diseño.

→ Addendum chico en `01-problem-addendum-01.md` aclarando. el Business Analyst recibe nota para próxima activación.

### Ejemplo 2: PATCH

En Fase 5, el Frontend Developer descubre que el endpoint `/api/v1/scores/{id}` necesita devolver `confidence_band` que no está en el OpenAPI spec.

→ Addendum a `03-api-design.md` agregando el campo. el API Architect aprueba. ADR si el cambio es estructuralmente significativo. Sin impacto en otras fases (solo el Frontend Developer estaba trabajando sobre eso).

### Ejemplo 3: MAYOR

En Fase 3B, el Security Architect detecta que el modelo de consentimiento Nivel 1 propuesto en Fase 2 (el Product Strategist) no cumple GDPR para usuarios europeos. Cambia el scope del MVP.

→ Re-abrir Gate 2 con el Product Strategist + el Legal & Compliance agent. Revisar MVP scope. Posible cambio de target geográfico o de modelo de consent. STATE.md marca Fase 2 como AMENDED. el Software Architect espera resolución antes de cerrar Fase 3B.

### Ejemplo 4: RESTART

A las 4 semanas de Fase 3B, el design partner ancla (ej. ACA en AgroScore) se baja. Sin design partner no hay validación del modelo. La hipótesis principal del Product Discovery agent colapsa.

→ Re-hacer Fase 0 con un nuevo gate (gate-0-restart-YYYYMMDD). Posiblemente todo el proyecto pivota. STATE.md refleja status `RESTARTING_PHASE_0`. Todas las fases posteriores quedan en hold.

## Output esperado

- `docs/context/0X-<fase>-addendum-NN.md` (o gate report restart)
- `docs/context/STATE.md` actualizado
- Notes en gate reports afectados
- ADRs nuevos si el cambio es estructuralmente significativo
