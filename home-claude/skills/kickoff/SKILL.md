---
name: kickoff
description: Start a new project. Triggers Fase 0 (Discovery) with the Product Discovery agent leading. Accepts an existing functional doc/spec as primary source. Use when starting any new project. Usage: /kickoff "<short project description>" or /kickoff "<description> — spec en <path>". Auto-invoke when user says "nuevo proyecto", "tengo una idea", "quiero empezar", "kickoff".
---

# Kickoff — Start a new project

Este comando arranca un proyecto nuevo siguiendo el flujo del setup personal, bajo la doctrina **Propose-first** (CLAUDE.md global §8): el discovery sale COMPLETO de una pasada, con supuestos declarados y recomendaciones — no como cuestionario.

## Procedimiento

### 1. Validar contexto

- Si ya hay archivos en `docs/context/`, preguntar al usuario: "Veo que hay contexto previo. ¿Querés que parta de cero, continúe lo existente, o trabaje en una sección particular?"
- Si no hay nada, crear estructura:
  ```bash
  mkdir -p docs/context/gates docs/adr docs/api docs/runbooks
  ```

### 2. Identificar fuentes

- Si el usuario referenció un doc funcional/spec/propuesta (en el argumento o en el repo), ese doc es la **fuente primaria** del discovery: se construye DESDE él, sin re-preguntar lo que ya dice.
- Recolectar también `CLAUDE.md` del proyecto (project_profile) y cualquier otro material.

### 3. Delegar al Product Discovery agent

Invocar al subagente `product-discovery` con todo el material. El agente:

1. Lee project_profile + TODOS los inputs.
2. Extrae hechos (con cita), infiere hipótesis y riesgos, asume con defaults declarados lo que falte.
3. Produce `docs/context/00-discovery.md` **COMPLETO de una pasada**, incluyendo su **recomendación de corte de MVP** fundamentada y kill criteria propuestos.
4. Cierra con máximo 3 "Decisiones para el usuario", cada una con default recomendado.

### 4. Presentar al usuario

Mostrar en chat:
1. Resumen ejecutivo del discovery (3-5 bullets).
2. La recomendación de corte de MVP con su justificación.
3. Tabla de supuestos clave (los de mayor impacto).
4. Las decisiones con default (si las hay): "sin respuesta, avanzo con la recomendada".
5. Oferta: "¿Ejecuto `/phase-gate 0` para validar y avanzar a Fase 1?"

**No se espera respuesta para completar el doc** — el doc ya está escrito. Las respuestas del usuario se aplican como iteración sobre el doc existente.

### 5. Setup inicial del repo (opcional)

Si el usuario indica que quiere setup de repo desde ya:
- Inferir el tipo de proyecto del material (web fullstack, mobile, full+mobile); si es ambiguo, es una de las decisiones-con-default.
- Aplicar el template correspondiente desde `~/.claude/templates/`
- Inicializar git si no lo está

### 6. Configurar CLAUDE.md del proyecto

Crear o actualizar `./CLAUDE.md` del proyecto con:
- Nombre del proyecto
- `project_profile` (el declarado por el usuario, o el inferido del material con nota de supuesto)
- Referencia al `~/.claude/CLAUDE.md` global
- Override de cualquier regla específica del proyecto

## Output esperado

1. `docs/context/00-discovery.md` COMPLETO (con Supuestos, Prerequisitos de implementación, Decisiones para el usuario)
2. Resumen + recomendación en chat
3. `./CLAUDE.md` del proyecto creado
4. Estructura inicial de `docs/` creada
5. (Opcional) Scaffolding inicial del repo

## Argumentos

- `$ARGUMENTS`: descripción corta del proyecto, opcionalmente con referencia a docs existentes. Ej: `/kickoff "AgroScore — bureau de scoring agropecuario. Spec funcional en docs/specs/funcional.md"`
- Si no se da argumento ni hay material, el Product Discovery agent trabaja con lo que el usuario haya dicho en la conversación y declara como supuesto lo que falte.
