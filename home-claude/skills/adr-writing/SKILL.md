---
name: adr-writing
description: Write or audit an Architecture Decision Record (ADR). Use when the Software Architect (or any agent) needs to capture a non-obvious technical decision, or to audit if existing ADRs follow the standard. Auto-invoke when user says "ADR", "decisión arquitectónica", "/adr", "documentar decisión".
---

# ADR Writing

Skill para producir Architecture Decision Records de calidad consistente. La filosofía: si dentro de 6 meses no recordás por qué tomaste una decisión, el ADR falló.

## Cuándo escribir un ADR

**Escribir ADR para:**
- Cualquier desvío del stack default del setup
- Decisión técnica con tradeoffs explícitos (no obvia)
- Decisión que un dev nuevo necesitaría entender el "por qué"
- Decisión que sospechás vas a revisitar
- Decisión con consecuencias a largo plazo

**NO escribir ADR para:**
- Convenciones de naming (van en CONTRIBUTING.md o style guides)
- Decisiones triviales ("usamos camelCase en variables")
- Decisiones que están en docs oficiales del framework

## Estructura obligatoria

Cada ADR debe estar en `docs/adr/NNNN-titulo-en-kebab-case.md` donde NNNN es un secuencial 4-digit zero-padded.

Usar `resources/adr-template.md` como template completo del documento (leer el archivo de recurso cuando vayas a escribir un ADR). Secciones obligatorias: header (Status/Date/Deciders/Tags), Context, Decision, Rationale, Alternatives Considered, Consequences (positivas, negativas, riesgos y reversibilidad), References. Implementation Notes es opcional.

En `resources/adr-example.md` hay un ejemplo de buen ADR (sqlc vs GORM) que muestra el nivel de especificidad esperado; leerlo si dudás del nivel de detalle.

## Reglas de calidad

1. **El status es honesto**: no marques Accepted hasta que se haya implementado o se vaya a implementar inmediatamente.
2. **El contexto es específico**: "necesitamos buena performance" no es contexto. "Necesitamos servir 1000 RPS con p95 < 100ms" sí.
3. **Las alternativas son reales**: si propusiste 3 alternativas pero 2 son strawmen, el ADR es débil. Buscá la versión más fuerte de cada alternativa. Mínimo 2 alternativas serias.
4. **Las consecuencias son honestas**: incluí las negativas, no solo las positivas. Si todo es positivo, sospechá del análisis.
5. **Los ADRs son inmutables**: si la decisión cambia, NUEVO ADR que supersedes al anterior. NO editar el anterior.

## Cómo auditar ADRs existentes

Para `/docs-audit` o cuando el Doc Sentinel revisa:

- [ ] ¿Todos los archivos siguen el naming `NNNN-titulo.md`?
- [ ] ¿Los NNNN son secuenciales sin gaps?
- [ ] ¿Cada ADR tiene todas las secciones obligatorias?
- [ ] ¿Status es válido?
- [ ] ¿Hay decisiones tomadas en código que NO tienen ADR? (drift)
- [ ] ¿Hay ADRs con status "Proposed" hace >2 semanas? (resolver o eliminar)
- [ ] ¿Hay ADRs supersedidos sin marca de superseded by?
