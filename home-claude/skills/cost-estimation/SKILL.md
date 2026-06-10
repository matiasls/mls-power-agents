---
name: cost-estimation
description: Apply structured cost estimation methodology (one-time + recurring, 3-scenarios optimistic/realistic/pessimistic). Use by the Cost Estimator in Gates 2 and 3B. Auto-invoke when user says "estimación de costos", "cuánto sale", "/cost-estimate".
---

# Cost Estimation

Skill operativo del Cost Estimator para estimar costos del MVP y del primer año. La filosofía: estimar mal cuesta más que estimar conservador.

## Procedimiento

### Paso 1: Recolectar inputs

- Budget declarado por el usuario (de `00-discovery.md`)
- Alcance del MVP (de `02-mvp-scope.md`)
- Stack tecnológico (de `03-tech-stack.md`)
- Estimación de usuarios / transacciones / volumen (si existe)

### Paso 2: Categorizar costos

#### Costos one-time (build del MVP)

| Categoría | Items típicos |
|---|---|
| Dominio y branding | dominio, registro INPI, identidad visual básica |
| Asesoría legal | consultas a estudio, redacción de docs |
| Setup inicial cloud | configuración, certificados, accounts |
| Onboarding herramientas | Sentry, Datadog, password manager, etc. |
| Buffer | siempre 15-20% del subtotal |

#### Costos recurrentes (mensuales / anuales)

| Categoría | Items típicos |
|---|---|
| Infrastructure + DB managed | Railway / AWS / GCP / VPS, RDS, Railway Postgres |
| APIs externas | Nosis, Stripe (% por transacción), Twilio, SendGrid |
| Observability | Sentry, Datadog, Better Stack |
| CDN / Storage / Backups | Cloudflare, S3/R2, retention adicional |
| Domain / SSL / DNS | Letsencrypt gratis; wildcard y Route53 a veces no |
| Office tools | GitHub team, Notion, Figma, Slack |

#### Costos variables por volumen

Identificar drivers (cosas que escalan con uso) y proyectar:

| Driver | Costo unitario | A 100 unidades | A 1.000 | A 10.000 |
|---|---|---|---|---|
| API call externa (Nosis) | USD 0.50 | $50 | $500 | $5,000 |
| Storage / egress por GB | (según provider) | | | |

### Paso 3: Buscar precios actuales

Para servicios cuyos precios pueden haber cambiado en últimos 6 meses, usar `WebSearch` (ej: "Railway pricing 2026"). NO inventes precios. Si no estás segura, dejá rango ancho con bandera.

### Paso 4: Aplicar tres escenarios

Para cada item, estimar:

| Escenario | Multiplicador típico |
|---|---|
| **Optimista** | base × 1.0 (usás free tiers, no hay sobrepresion) |
| **Realista** | base × 1.3 (incluís margen para sorpresas) |
| **Pesimista** | base × 2.0 (costo real frecuente cuando subestimás) |

Para costos variables, asumir volumen real esperado en cada escenario (no solo precio unitario).

### Paso 5: Costos "ocultos" típicos

Siempre considerar (la mayoría se olvidan):

- **Egress de cloud**: salir de cloud cuesta. AWS = USD 0.09/GB.
- **NAT Gateway**: si usás VPC privada en AWS, NAT cuesta ~USD 32/mes + tráfico.
- **Backups y point-in-time recovery**: a veces es 1.5-2x el costo del storage primary.
- **Logs y observability**: crece silenciosamente. Datadog "se vuelve caro" rápido a >USD 200/mes.
- **DB connection limits**: planes baratos limitan conns. Pasás a plan caro o pooler.
- **Build minutes en CI**: GitHub Actions free tier termina con un repo activo.
- **SSL certs wildcard**: gratis con Letsencrypt, pagos en otros providers.
- **Idiomas adicionales**: si soportás más de 1 idioma, traducciones = costo.
- **Compliance audits**: SOC2, GDPR audits = USD 5-30K si crecés.

### Paso 6: Comparar contra budget

| | Budget user | Estimado optimista | Estimado realista | Estimado pesimista |
|---|---|---|---|---|
| **MVP total** | USD X | USD A | USD B | USD C |
| **Año 1 recurrente** | USD Y | USD D | USD E | USD F |

**Veredictos**:
- Si **realista** ≤ budget → ✅ proyecto cierra
- Si **realista** > budget pero < 1.5x → ⚠️ ajustar scope o budget
- Si **realista** > 1.5x budget → ❌ replanteo

### Paso 7: Identificar opciones de reducción

Para cada item caro, listar opciones:

| Costo | Opción | Ahorro estimado | Tradeoff |
|---|---|---|---|
| Postgres managed RDS | Railway Postgres | -USD 40/mes | Menos features (PITR limitado, etc.) |
| Sentry team plan | Sentry developer + self-hosted GlitchTip | -USD 30/mes | Mantenimiento manual |

### Paso 8: Plan de migración (si crecés)

Si superás cierto threshold, ¿qué tenés que cambiar?

| A partir de | Cambio sugerido | Costo migración | Costo recurrente nuevo |
|---|---|---|---|
| 1000 usuarios activos | DB con replica | USD 0 | +USD 50/mes |
| 100K transacciones/mes | Data warehouse separado | USD 500-2000 | +USD 100/mes |

## Output esperado

`docs/context/02-cost-estimate.md`:

```markdown
# Cost Estimate

## Inputs
- Budget declarado: USD <X> total / USD <Y>/mes recurrente
- Scope: MVP v0.1 según `02-mvp-scope.md`
- Stack: según `03-tech-stack.md`
- Volumen estimado año 1: <X> usuarios, <Y> transacciones/mes

## Costos one-time
| Item | Optimista | Realista | Pesimista | Notas |
|---|---|---|---|---|

## Costos recurrentes mensuales
| Item | Optimista | Realista | Pesimista | Notas |
|---|---|---|---|---|

## Costos variables por volumen
| Driver | Costo unitario | A 100 | A 1K | A 10K |
|---|---|---|---|---|

## Escenarios año 1 totales
| Escenario | One-time | Recurrente anual | Total año 1 | vs Budget |
|---|---|---|---|---|

## Veredicto
[✅ / ⚠️ / ❌ + recomendación]

## Costos NO incluidos (transparencia)
- Tiempo del equipo, marketing, contadores, ...

## Opciones de reducción
[Lista priorizada]

## Plan de migración cuando crezca
[Tabla con thresholds]
```

## Anti-patterns

1. **Solo precio unitario, sin volumen**: USD 0.50 por consulta es nada hasta que son 10K/día = USD 150K/año.
2. **Ignorar egress**: el "cloud barato" cobra por sacar datos.
3. **Asumir free tier para siempre**: free tiers expiran o se exceden.
4. **No incluir buffer**: el 80% de los estimados se quedan cortos.
5. **No considerar el tiempo humano**: si los fundadores cobran sueldo, eso es el costo más grande.
6. **Estimaciones aspiracionales**: "vamos a usar AWS porque es lo mejor" cuesta 3x más que Railway en MVP.

## Checklist final

- [ ] Three scenarios calculados (optimista/realista/pesimista)
- [ ] Costos one-time y recurrentes separados
- [ ] Costos variables con drivers y proyección por volumen
- [ ] Costos ocultos típicos considerados
- [ ] Comparado contra budget declarado
- [ ] Opciones de reducción identificadas
- [ ] Plan de migración cuando crezca
