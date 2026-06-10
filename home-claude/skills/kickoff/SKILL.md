---
name: kickoff
description: Start a new project. Triggers Fase 0 (Discovery) with the Product Discovery agent leading. Use when starting any new project. Usage: /kickoff "<short project description>". Auto-invoke when user says "nuevo proyecto", "tengo una idea", "quiero empezar", "kickoff".
---

# Kickoff — Start a new project

Este comando arranca un proyecto nuevo siguiendo el flujo del setup personal.

## Procedimiento

### 1. Validar contexto

- Si ya hay archivos en `docs/context/`, preguntar al usuario: "Veo que hay contexto previo. ¿Querés que parta de cero, continúe lo existente, o trabaje en una sección particular?"
- Si no hay nada, crear estructura:
  ```bash
  mkdir -p docs/context/gates docs/adr docs/api docs/runbooks
  ```

### 2. Delegar a el Product Discovery agent

Invocar al subagente `product-discovery` con el contexto del proyecto (incluyendo archivos adjuntos si los hay).

el Product Discovery agent va a:
1. Leer cualquier doc adjunto que el usuario haya subido.
2. Hacer 5-8 preguntas críticas al usuario.
3. Esperar respuestas.
4. Iterar.
5. Producir `docs/context/00-discovery.md`.

### 3. No avanzar prematuramente

NO ejecutar Gate 0 todavía. el Product Discovery agent decide cuándo el discovery está lo suficientemente maduro.

Cuando el Product Discovery agent considere que está listo, ofrecerle al usuario:
- "Discovery está completo. ¿Querés que ejecute `/phase-gate 0` para validar y luego avanzar a Fase 1?"

### 4. Setup inicial del repo (opcional)

Si el usuario indica que quiere setup de repo desde ya:
- Preguntar tipo de proyecto (web fullstack, mobile, full+mobile)
- Aplicar el template correspondiente desde `~/.claude/templates/`
- Inicializar git si no lo está

### 5. Configurar CLAUDE.md del proyecto

Crear o actualizar `./CLAUDE.md` del proyecto con:
- Nombre del proyecto
- Naturaleza (personal/MVP/comercial)
- Referencia al `~/.claude/CLAUDE.md` global
- Override de cualquier regla específica del proyecto

## Output esperado

1. `docs/context/00-discovery.md` creado/actualizado con la propuesta del Product Discovery agent
2. Preguntas a usuario en chat
3. `./CLAUDE.md` del proyecto creado
4. Estructura inicial de `docs/` creada
5. (Opcional) Scaffolding inicial del repo si el usuario lo pidió

## Argumentos

- `$ARGUMENTS`: descripción corta del proyecto. Ej: `/kickoff "AgroScore - bureau de scoring agropecuario"`
- Si no se da argumento, el Product Discovery agent le pregunta al usuario.
