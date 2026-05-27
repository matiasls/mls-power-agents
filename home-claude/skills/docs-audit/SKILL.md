---
name: docs-audit
description: Audit the project documentation for completeness and freshness. Delegates to the Doc Sentinel (doc-sentinel). Use on-demand or in any gate. Auto-invoke when user says "auditar docs", "está todo documentado", "docs status", "/docs-audit".
---

# Docs Audit

Audit del estado de documentación del proyecto. Verifica completitud, frescura y drift contra el código.

## Procedimiento

### Paso 1: Identificar fase actual

Leer `docs/context/gates/` y determinar la última fase aprobada.

### Paso 2: Invocar a el Doc Sentinel

Invocar a `sara-doc-sentinel`:
- Pasa la fase actual
- el Doc Sentinel revisa toda la doc obligatoria para esa fase
- el Doc Sentinel detecta drift contra el código

### Paso 3: el Doc Sentinel produce el reporte

Reporte estructurado:

```markdown
# Docs Audit — <fecha>

## Estado general
- Fase actual: N
- Total archivos obligatorios: X
- Existen: Y
- Frescos: Z
- Status: ✅ OK / ⚠️ Drift detectado / ❌ Faltan archivos críticos

## Archivos faltantes
- [ ] docs/EXECUTION.md (REQUERIDO desde Fase 4)
- [ ] ...

## Archivos desactualizados
| Archivo | Última edición | Cambios de código desde entonces |
|---|---|---|

## Drift detectado
- Endpoint X existe en código pero no en OpenAPI spec
- Módulo Y existe pero no en ARCHITECTURE.md

## Recomendaciones de acción
1. Actualizar archivo X
2. Crear sección Y en archivo Z
```

### Paso 4: Ofrecer auto-fix donde sea seguro

el Doc Sentinel puede:
- ✅ Crear archivos faltantes con templates iniciales (vacíos pero estructurados)
- ✅ Agregar secciones que faltan estructuralmente
- ❌ NO escribir contenido decisional (eso es del Software Architect, el Security Architect, etc.)

Preguntar al usuario:
"Encontré N archivos faltantes y M con drift. ¿Querés que:
1. Cree los templates faltantes
2. Te muestre qué falta para que vos completes
3. Convoque al agente responsable (el Software Architect, el Security Architect, etc.) para que actualice
"

## Reglas duras

- **`docs/EXECUTION.md` faltante en Fase 4+ → BLOQUEANTE**
- **README faltante en Fase 4+ → BLOQUEANTE**
- **OpenAPI specs desactualizados en Fase 5+ → HIGH**
- **CHANGELOG faltante en Fase 6+ → BLOQUEANTE**
- **ADRs faltantes para decisiones tomadas en Fase 3B → MEDIUM**

## Output esperado

- Reporte estructurado al usuario
- Lista accionable de fixes
- Si el usuario aprueba, ejecución de auto-fixes seguros
