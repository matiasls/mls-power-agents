---
name: mvp-prioritization
description: Apply rigorous MVP prioritization framework. Use in Fase 2 (Product Decisions) when the Product Strategist needs to scope MVP brutally. Auto-invoke when user says "MVP", "priorizar features", "qué entra en v1", "/mvp-scope".
---

# MVP Prioritization

Este skill encapsula el framework de priorización brutal de MVP que aplica el Product Strategist. La filosofía: el MVP es lo mínimo que valida la hipótesis crítica, no la versión 1.0.

## Procedimiento

### Paso 1: Identificar la hipótesis crítica única

De las hipótesis listadas por el Product Discovery agent en `00-discovery.md`, identificar **UNA** hipótesis cuyo fallo mataría el proyecto:

- ¿Cuál hipótesis, si falla, no podés rescatar con otras?
- ¿Cuál es la más cara/lenta de validar?
- ¿Cuál es la más incierta?

La intersección de las tres es tu hipótesis crítica.

### Paso 2: Listar todas las features candidatas

De los UCs del Business Analyst (`01-functional-spec.md`) extraer todas las features posibles. Una feature por línea, sin agrupamientos.

### Paso 3: Aplicar el filtro de hipótesis

Auto-interrogación del agente (NO es pregunta al usuario): mapear automáticamente cada feature contra las hipótesis del discovery (`00-discovery.md`) — H-1, H-2, etc. del Product Discovery agent.

**Feature sin hipótesis mapeable = candidata a out-of-MVP con razón escrita.**

Si no mapea a ninguna hipótesis crítica → **NO entra al MVP**, va a backlog.

### Paso 4: Matriz Valor / Esfuerzo

Para cada feature candidata, asignar:

| Dimensión | Escala | Definición |
|---|---|---|
| **Valor de validación** | 1-5 | Cuánto contribuye a validar la hipótesis crítica |
| **Esfuerzo** | S/M/L/XL | S=<1 semana, M=1-2 semanas, L=2-4 semanas, XL=>4 semanas |
| **Riesgo técnico** | Bajo/Medio/Alto | Probabilidad de subestimar |
| **Dependencias externas** | Sí/No | Requiere terceros (APIs, datos, partners) |

### Paso 5: Aplicar filtros de corte

Sale del MVP cualquier feature que:
1. Tenga valor de validación ≤ 2.
2. Sea XL en esfuerzo sin ser absolutamente crítica.
3. Tenga dependencia externa no confirmada.
4. No mapee a una hipótesis crítica.

### Paso 6: Validación de costo

Pasar la lista resultante a el Cost Estimator. Si el MVP excede budget, recortar más. **No agregar tiempo**: tiempo siempre es más caro que features cortadas.

### Paso 7: Definir Kill Criteria

Para el MVP completo, definir 2-4 señales que matan el proyecto:

- "Si en 3 meses no hay LOI firmada, paramos."
- "Si AUC validado < 0.65, no hay producto."
- "Si CAC > 6x LTV proyectado, replanteamos."

Sin kill criteria, los proyectos se vuelven zombies.

### Paso 8: Producir output

Doctrina Propose-first (CLAUDE.md §8): el skill produce **EL corte recomendado completo** (qué entra / qué no entra, con justificación por feature). NO se le pregunta al usuario qué quiere que entre durante la ejecución: el usuario ajusta el corte en el Gate 2.

`docs/context/02-mvp-scope.md` con:
- Hipótesis crítica única
- Métrica primaria de éxito (UNA)
- Features que ENTRAN al MVP (con justificación por hipótesis)
- Features que NO ENTRAN (con versión target)
- Kill criteria
- Roadmap interno hasta v1.0

## Anti-patterns a rechazar

- **"Lo agregamos porque está casi listo"**: no es razón. Si no valida hipótesis, no entra.
- **"El cliente lo va a pedir"**: el cliente siempre pide más. Vos curás.
- **"Es solo un poquito más de trabajo"**: el "poquito" es el 80% del scope creep.
- **"Necesitamos esto para que se vea pro"**: vanidad ≠ validación.
- **"Lo metemos por las dudas"**: por las dudas → al backlog.

## Plantillas de output

### Tabla de features

```markdown
| ID | Feature | Hipótesis | Valor | Esfuerzo | Riesgo | Dep. ext. | Veredicto |
|---|---|---|---|---|---|---|---|
| F-001 | Login | H-2 | 3 | S | Bajo | No | ENTRA |
| F-002 | Dashboard básico | H-1 | 5 | M | Bajo | No | ENTRA |
| F-003 | Reports avanzados | H-1 | 2 | L | Medio | No | NO ENTRA (v0.2) |
| F-004 | Integración Nosis | H-3 | 4 | M | Alto | Sí | NO ENTRA (bloqueante: contrato Nosis) |
```

### Kill criteria

```markdown
## Kill Criteria del MVP

Si pasa cualquiera de estas, paramos y replanteamos:

1. **Tiempo**: si en YYYY-MM-DD no hay LOI firmada, paramos. Dueño: <nombre>.
2. **Producto**: si la métrica primaria <métrica> está <umbral> al final de la validación, paramos.
3. **Costo**: si los costos reales de MVP exceden USD <umbral>, paramos.
4. **Mercado**: si en N entrevistas válidas, <X>% dice que no pagaría, replanteamos pricing.
```
