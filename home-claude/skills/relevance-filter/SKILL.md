---
name: relevance-filter
description: Apply the "relevance filter" pattern when a specialist agent (the Security Architect, the API Architect, the Software Architect, etc.) produces an artifact in a phase. Forces explicit alignment to MVP scope, prevents over-engineering by incentive. Auto-invoke when an agent finishes a Fase 3 artifact, or use as part of phase-gate. Trigger words: "filtro de relevancia", "está calibrado al MVP", "/relevance-filter".
---

# Relevance Filter

Skill estructural derivado del Patrón 1 detectado en splitwise-mini: **sobre-entrega multi-agente por incentivo individual**. La filosofía: cada agente especialista debe declarar explícitamente cómo su entregable está calibrado al MVP — no al producto-completo imaginado.

## Por qué existe este skill

En fases con ≥3 agentes paralelos, cada uno tiende a sobre-entregar en su dominio:
- el Security Architect modela 22 amenazas cuando solo 5 son reales al MVP
- el API Architect crea 30 error codes cuando 8 alcanzan
- el Software Architect diseña 8 módulos cuando 4 son boundaries reales
- el UX Designer especifica PWA para 4 usuarios que abren desde WhatsApp

Cada artefacto está justificado en su dominio, pero el sistema completo está calibrado a un MVP 10× más grande.

**El filtro de relevancia obliga a cada agente a justificar la conexión al MVP**, no a justificar la rigurosidad del rigor.

## Cuándo aplicar

- Cualquier agente especialista (el Security Architect, el API Architect, el Software Architect, el UX Designer, el UI Designer, el DevOps & Platform agent) que termine un artefacto en Fase 3 o 4.
- Antes del Critic en cualquier gate donde haya ≥2 agentes paralelos.
- Cuando se sospecha sobre-entrega.

## Procedimiento

### Paso 1: Cada agente agrega sección "Filtro de relevancia"

Al final de su artefacto principal de fase, el agente escribe esta sección obligatoria:

```markdown
## Filtro de relevancia

### MVP declarado (referencia)
[Citar literalmente del `02-mvp-scope.md`:]
- Métrica primaria de éxito: <copia exacta>
- Volumen esperado: <usuarios, transacciones, tamaño>
- Kill criteria: <copia exacta>
- Out of scope explícito: <copia exacta>

### Cómo este entregable se conecta al MVP

[Para cada decisión/elemento mayor del artefacto, mostrar la conexión:]

| Elemento del artefacto | Cómo soporta al MVP declarado |
|---|---|
| <Decisión / componente / amenaza / módulo> | <Frase que conecta con métrica/volumen/scope> |

### Excluí explícitamente (considerado y descartado)

[Items que SÍ pensé pero descarté por no ser MVP. Esto es lo más importante de la sección. Mostrar que pensaste a futuro pero decidiste cortar:]

| Item descartado | Razón de descarte | Cuándo se revisita |
|---|---|---|
| <Amenaza / módulo / feature> | <Por qué no MVP> | <v0.2 / cuando llegue a N usuarios / nunca> |

### Sobre-entrega declarada

Si hay items en el artefacto que están en zona gris (podrían ser MVP o no), declararlo:

- <Item>: incluído por defensividad. Si vos creés que no aplica, eliminalo y firmá.
```

### Paso 2: El Critic valida el filtro

En el gate de la fase, el Critic verifica:

- [ ] ¿Cada agente especialista incluyó su sección "Filtro de relevancia"?
- [ ] ¿La sección cita literalmente del `02-mvp-scope.md`?
- [ ] ¿Hay correspondencia entre cada elemento del artefacto y el MVP?
- [ ] ¿La lista "Excluí explícitamente" tiene al menos 2-3 items? (si no hay nada descartado, sospechá over-entrega oculta)
- [ ] ¿Hay items en "zona gris" que el usuario debería revisar?

### Paso 3: El Devil's Advocate ataca el filtro

El DA tiene como input el filtro de relevancia. Su pregunta clave:

> *"De los items que el agente INCLUYÓ, ¿hay alguno que en realidad pertenece a 'Excluí explícitamente'? ¿Hay defensividad disfrazada de rigor?"*

Si el DA detecta items que deberían haberse excluido, los propone para recorte. El agente original revisa vía `plan-b-addendum` (no se relanza).

## Reglas duras

- **Sin filtro de relevancia, el artefacto no se acepta en el gate**. Bloqueante automático.
- **El filtro NO puede ser genérico**: debe citar literalmente del `02-mvp-scope.md`. Frases tipo "es necesario para el sistema" no califican.
- **La lista "Excluí explícitamente" no puede estar vacía**: si no se descartó nada, hay sobre-entrega oculta o falta de pensamiento sobre alternativas.
- **Los items en zona gris se marcan, no se ocultan**: si el agente duda si algo es MVP, lo dice; no asume.

## Por qué este enfoque y no caps numéricos

La propuesta original del Patrón 1 (Sesión 6) era usar caps numéricos como "5 amenazas STRIDE para <10 usuarios". Esa idea se reemplazó por este filtro porque:

1. **Los caps numéricos NO son función solo del nº de usuarios.** AgroScore con 4 cooperativas puede tener 12-15 amenazas STRIDE legítimas (datos regulados, k-anonymity, competidores). El cap "5" lo bloquearía indebidamente.
2. **Los caps invitan al "juego del cap"**: agentes inventan justificaciones para excederlos. El cap se vuelve ceremonia.
3. **El problema real es "output desconectado del MVP", no "demasiado output"**. El filtro ataca el problema real.

## Anti-patterns a rechazar

1. **Filtro genérico**: "este STRIDE soporta el MVP porque la seguridad es importante" → INVÁLIDO.
2. **Lista de exclusión vacía**: "no descarté nada porque todo es relevante" → SOSPECHOSO. Re-pensar.
3. **Cita falsa del MVP**: parafrasear el MVP scope en lugar de citarlo literal → INVÁLIDO.
4. **Items en zona gris sin marcar**: si el agente duda, debe explicitarlo.

## Output esperado

Sección **"Filtro de relevancia"** al final de cada artefacto principal de fase, validada por Critic en el gate.
