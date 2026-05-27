---
name: plan-b-addendum
description: Apply Plan B recommendations from Devil's Advocate as an addendum to the original artifact, signed by the original agent — NOT by relaunching agents from scratch. Use when DA produces Plan B with recortes. Trigger: "aplicar plan B", "addendum plan B", "/plan-b-addendum".
---

# Plan B Addendum

Skill estructural derivado del Patrón 1 (Sesión 6): cuando el Devil's Advocate propone un Plan B con recortes, los agentes originales NO se relanzan desde cero. Se aplica como addendum firmado.

## Por qué existe este skill

La propuesta original del Patrón 1 era: "el coordinator (el Software Architect en splitwise-mini) aplica recortes directamente, NO relanzar agentes individuales".

Problema con esa propuesta: **el "coordinator" no es un rol claro en el framework**. el Software Architect es par del Security Architect, el API Architect, el UX Designer — no su superior. Si el Software Architect recorta el threat model del Security Architect:
- ¿Tiene legitimidad? No formal.
- ¿el Security Architect aprende? No, solo se siente sobrepasado.
- ¿La próxima vez el Security Architect sobre-entrega igual? Sí.

**Solución mejor**: addendum aplicado **por el agente original**, no relanzando desde cero. Esto:
1. Preserva la voz del especialista.
2. Evita el ciclo de sobre-entrega de relanzar.
3. Crea aprendizaje (el agente ve sus propios recortes).
4. Genera trazabilidad clara (commit con el addendum, no rewrite del artefacto entero).

## Procedimiento

### Paso 1: Identificar items del Plan B a aplicar

El DA produjo un Plan B con N recortes. Listar cada uno con:
- ID del recorte
- Item a quitar / modificar
- Razón del DA
- Agente original que debe revisar

### Paso 2: Por cada recorte, el agente original responde

El agente especialista (el Security Architect, el API Architect, el Software Architect, etc.) abre su artefacto original y **agrega una sección addendum al final**:

```markdown
## Addendum: Recortes post-DA Plan B

**Fecha**: YYYY-MM-DD
**Gate**: N
**Plan B referenciado**: `docs/context/gate-N-da-plan-b.md`

### Recortes aplicados

| ID | Item recortado | Razón DA | Acción aplicada | Firmado |
|---|---|---|---|---|
| PB-001 | Trigger SQL anti-self-pay | "Redundante con REVOKE INSERT" | ✅ Removido + ajuste de doc línea 234 | [el Security Architect] |
| PB-002 | 8 módulos → 4 reales | "4 boundaries son de papel" | ✅ Consolidación documentada en ADR-007 | [el Software Architect] |

### Recortes RECHAZADOS por el agente original

[Si el agente discrepa con algún recorte específico, lo escribe acá:]

| ID | Item DA propuso recortar | Por qué el agente NO acepta | Próximo paso |
|---|---|---|---|
| PB-003 | "10 error codes → 3" | "Los 10 cubren casos reales del API contract; reducir rompe spec" | Decisión final del usuario |

### Items en zona gris (decisión del usuario)

[Items donde el agente duda:]

| ID | Item | Argumentos pro-recorte | Argumentos contra-recorte |
|---|---|---|---|
| ... | ... | ... | ... |
```

### Paso 3: El usuario resuelve discrepancias

Si hay items RECHAZADOS o en zona gris:
- El usuario lee la posición del DA + la del agente
- Decide cuál prevalece
- La decisión se registra en el addendum

### Paso 4: El gate verifica

El Critic verifica en el gate:
- [ ] Cada recorte del Plan B fue revisado por el agente original
- [ ] Los addendum están firmados (al menos con iniciales)
- [ ] Discrepancias resueltas por el usuario
- [ ] No hay items del Plan B sin tratar

## Reglas duras

- **NO se relanzan agentes desde cero** cuando se aplica Plan B. Solo addendum sobre el artefacto original.
- **El agente original puede RECHAZAR un recorte** con argumento escrito. No es decisión final del DA.
- **El usuario resuelve discrepancias**, no el "coordinator" (que no existe formalmente).
- **Trazabilidad obligatoria**: cada recorte tiene ID, razón citada del DA, acción aplicada, firma.

## Por qué este enfoque y no "coordinator aplica recortes"

| Enfoque original (descartado) | Enfoque actual |
|---|---|
| Coordinator (el Software Architect) recorta directamente | Cada agente revisa sus propios recortes |
| Sin legitimidad formal | Cada uno trabaja sobre su propio dominio |
| Sin aprendizaje (el agente no ve) | Aprendizaje (el agente firma cada recorte) |
| Discrepancia sin resolución clara | Discrepancia escala al usuario |
| Rewrite implícito | Addendum explícito + trazabilidad |

## Anti-patterns a rechazar

1. **Relanzar al agente desde cero**: rompe la regla principal y desencadena nueva sobre-entrega.
2. **Recortes sin firma**: si no hay firma del agente original, el recorte no se aplica.
3. **Aplicar Plan B sin que el agente original revise**: rompe la legitimidad del especialista.
4. **Addendum sin trazabilidad** (sin IDs, sin razones, sin acciones): no es addendum, es opinion.

## Output esperado

Sección **"Addendum: Recortes post-DA Plan B"** al final del artefacto original, firmada por el agente especialista, validada por Critic en gate.
