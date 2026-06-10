---
name: legal-compliance-check
description: Apply legal & compliance checklist (data protection, regulatory mapping, consent design). Use when the Legal & Compliance agent reviews a project. Auto-invoke when user says "compliance check", "GDPR", "ley 25326", "/legal-check", "datos personales".
---

# Legal Compliance Check

Skill operativo del Legal & Compliance agent para mapear riesgos legales y compliance. La filosofía: identificar riesgo + dimensionar + proponer mitigación. NO reemplaza abogado matriculado.

## Disclaimer inicial obligatorio

Todo output de este skill empieza con:

> Este análisis es preparado por un agente IA y NO constituye consejo legal. Las decisiones finales requieren consulta con estudio jurídico matriculado en la jurisdicción aplicable.

## Procedimiento

### Paso 1: Identificar jurisdicciones aplicables

Para cada jurisdicción, marcar Sí/No con razón:

| Jurisdicción | Aplica si... | Marca |
|---|---|---|
| **Argentina (Ley 25.326 + AAIP)** | Procesás datos de residentes AR, tenés operación AR, o procesás datos AR aunque seas extranjero | |
| **UE (GDPR + ePrivacy)** | Criterio estándar de extraterritorialidad: residentes UE, oferta de servicios o monitoreo | |
| **California (CCPA/CPRA)** | Datos de californianos + thresholds de revenue/usuarios | |
| **Brasil (LGPD)** | Análogo: residentes BR, operación u oferta a BR | |
| **Otras (Chile, México, etc.)** | Análoga lógica de extraterritorialidad | |

### Paso 2: Inventario de PII (Personal Identifiable Information)

Tabla obligatoria. Para cada tipo de dato:

| Dato | Categoría | Origen | Propósito | Base legal AR | Base legal GDPR | Retention |
|---|---|---|---|---|---|---|

**Categorías especiales** (cuidado extra): datos sensibles (Ley 25.326 art. 7 / GDPR art. 9), datos de menores (consentimiento especial), datos financieros / scoring crediticio (regulación específica + sectorial).

### Paso 3: Mapeo regulatorio sectorial

Si el proyecto toca sectores regulados, agregar:

| Sector | Reguladores | Aplicación a este proyecto |
|---|---|---|
| Financiero | BCRA, CNV, UIF | Solo si hay intermediación. Scoring sin intermediación = NO aplica BCRA típicamente. |
| Salud | ANMAT, ministerios | Si hay datos de salud o dispositivos médicos. |
| Telecomunicaciones | ENACOM | Si sos operador o usás espectro. |
| Defensa de competencia | CNDC | Si facilitás flujos de info entre competidores. ⚠️ Bureaus sectoriales: revisar. |
| AML/CFT | UIF | Si movés dinero o tenés sujetos obligados como clientes. |

### Paso 4: Diseño de consentimiento

Para cada punto donde recolectás PII, validar:

- [ ] **Específico**: el usuario sabe exactamente qué datos y para qué uso
- [ ] **Informado**: lenguaje claro, no legalese; alternativas claras
- [ ] **Libre**: sin coerción, sin pre-ticked checkboxes, sin "todo o nada"
- [ ] **Granular**: opt-in separado por finalidad (marketing ≠ servicio core)
- [ ] **Retirable**: mecanismo claro y simétrico al opt-in
- [ ] **Auditable**: registro de qué consintió cada usuario y cuándo

Si alguno falla, el consentimiento NO es válido bajo GDPR ni 25.326 (actualizada).

### Paso 5: Derechos del titular

| Derecho | Implementación | Plazo legal |
|---|---|---|
| Acceso (ARCO / GDPR) | Endpoint o portal | 10 días (AR) / 1 mes (GDPR) |
| Rectificación | Endpoint o portal | Idem |
| Cancelación / Borrado | Soft delete + hard delete plan | Idem |
| Oposición | Mecanismo de opt-out | Idem |
| Portabilidad (GDPR) | Export formato estructurado | 1 mes |
| Decisiones automatizadas (art. 22 GDPR / art. 20 25.326) | Información + revisión humana opcional | Idem |

### Paso 6: Identificar riesgos

| ID | Riesgo | Norma | Probabilidad | Impacto | Mitigación | Owner | Plazo |
|---|---|---|---|---|---|---|---|

Severidad orientativa: 🔴 Crítico = multa potencial >USD 100K o suspensión operativa · 🟠 Alto = multa <USD 100K, daño reputacional serio · 🟡 Medio = warning de regulador, corrección obligatoria · 🟢 Bajo = best practice, no obligatorio.

### Paso 7: Identificar acciones requeridas

| Acción | Owner | Plazo objetivo | Bloqueante de qué |
|---|---|---|---|
| Designar DPO / Registrar BBDD en AAIP | Usuario | Pre-launch | Operación bajo GDPR/AR si aplica |
| Redactar Privacy Policy | Estudio externo | Pre-launch | Site público |
| DSA con design partners | Estudio externo | Antes de data sharing | Operación con partners |
| Procedimiento ARCO/GDPR | Backend | Pre-launch | Compliance operacional |

### Paso 8: Preparar brief para estudio externo

El valor del Legal & Compliance agent es **framing**, no respuesta final. Producir lista de preguntas concretas para el estudio:

**Estructura del brief**:
```markdown
# Brief para consulta legal — <proyecto>

## Contexto del proyecto
[3-4 párrafos describiendo qué hace, quién es cliente, qué datos toca]

## Mapa regulatorio identificado
[Resumen de aplicabilidad por jurisdicción]

## Preguntas concretas
1. ¿La estructura X cumple con Y? Cita normativa específica.
2. ¿Bajo qué umbral de N usuarios pasamos a obligación A?
...

## Documentos adjuntos
- Arquitectura general (sanitized)
- Diseño de consentimiento propuesto
- Lista de datos procesados
```

Una buena consulta legal con brief = 1-2 horas del estudio = $300-800 USD. Sin brief = 4-6 horas = $1500+ USD.

## Output esperado

`docs/context/02-legal-compliance.md` con secciones: disclaimer, jurisdicciones aplicables, PII inventory, mapeo regulatorio, diseño de consentimiento, derechos del titular, riesgos, acciones requeridas con owner + plazo, brief para estudio externo.

Status: borrador hasta validar con estudio externo. Después de consulta: actualizar con observaciones del estudio.
