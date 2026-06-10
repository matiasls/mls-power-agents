---
name: modular-monolith
description: Design a modular monolith architecture with proper domain boundaries. Use in Fase 3B when the Software Architect is defining modules. Auto-invoke when user says "monolito modular", "cómo divido los módulos", "boundaries", "qué módulos crear".
---

# Modular Monolith Design

Este skill encapsula los patrones de diseño de monolito modular que el Software Architect aplica. La filosofía: empezar simple, modular bien, evolucionar cuando duela.

## Principios fundamentales

1. **Empezar como monolito modular, no como microservicios**. Microservicios solo cuando se justifica con datos.
2. **Boundaries por dominio**, no por capa técnica.
3. **Cada módulo deployable independientemente** si en el futuro lo necesita.
4. **Comunicación entre módulos a través de contratos claros**, no llamadas directas a internals.
5. **Datos owned por módulo**: cada módulo tiene su propio set de tablas, no comparte.

## Anti-patterns a evitar

- **❌ División por capa técnica** (`controllers/`, `services/`, `repositories/`, `models/`): es un gran monolito con folders, no un modular monolith. Cualquier cambio toca todas las capas.
- **❌ Módulos con dependencias circulares** (`auth → users → notifications → auth`): si el grafo tiene ciclos, no son módulos realmente.
- **❌ Módulos "manager" o "shared" gigantes**: un `shared/` con 50 archivos es un dump. Debería ser varios módulos chicos o ir adentro de los módulos que lo usan.
- **❌ Módulos que comparten tablas**: si dos módulos hacen SELECT/UPDATE sobre la misma tabla, NO son módulos separados. Son uno.

## Patrón recomendado

### División por dominio (bounded context)

```
app/
├── ingestion/          # Módulo: data ingestion
│   ├── domain/         # Entidades y reglas del dominio
│   ├── handlers/       # HTTP, cron, queue handlers
│   ├── persistence/    # Repos propios
│   ├── services/       # Lógica del módulo
│   ├── contracts/      # Tipos exportados a otros módulos
│   └── module.go       # Punto de entrada / wire
├── scoring/            # Módulo: scoring engine
│   └── (misma estructura)
├── client_portal/      # Módulo: portal del cliente
├── admin/              # Módulo: admin panel
├── platform/           # Infra compartida (DB pool, logger, config)
└── cmd/
    └── api/main.go     # Wire everything together
```

### Reglas para los contratos

Solo el directorio `contracts/` de un módulo puede ser importado por otro módulo.

```go
// Módulo client_portal puede hacer:
import "app/scoring/contracts"   // ✅ OK

// Módulo client_portal NO puede hacer:
import "app/scoring/domain"      // ❌ Cruzar boundary
import "app/scoring/persistence" // ❌ Cruzar boundary
```

Enforcement: convención + code review, herramientas como `archtest` (Go) o `dependency-cruiser` (Node), o `internal/` directories de Go.

### Reglas para los datos

Cada módulo tiene:
- Su propio schema en la DB (o prefijo de tablas)
- Su propio set de migraciones
- NO acceso a tablas de otros módulos

Si necesitás data de otro módulo: pedila via su API/contracts, NO con SQL JOIN.

```sql
-- Estructura sugerida en Postgres
schema ingestion;     -- ingestion.satellite_data, ingestion.weather_data
schema scoring;       -- scoring.scores, scoring.model_versions
schema portal;        -- portal.users, portal.sessions
schema admin;         -- admin.audit_log
```

## Cómo identificar boundaries correctos

### Heurísticas para separar

1. **Lenguaje**: si "Score" significa algo distinto en dos contextos, son módulos distintos.
2. **Atributos por contexto**: si una entidad como "Productor" tiene atributos relevantes diferentes en distintos contextos, esos son módulos distintos (en `ingestion` tiene CUIT/geo/área; en `scoring` tiene score/drivers; en `client_portal` es un row de una tabla).
3. **Razones para cambiar**: si dos módulos siempre cambian juntos, probablemente son uno solo. Si nunca cambian juntos, son distintos.
4. **Equipos**: si en el futuro vas a tener un equipo dedicado a X, X es un módulo.

### Heurísticas inversas (cuándo NO son módulos separados)

- Si comparten más del 30% de modelos de datos.
- Si una operación de negocio típica toca ambos.
- Si para entender uno hay que entender el otro.
- Si separarlos genera más coupling vía APIs que el coupling actual vía código.

## Patrones de comunicación entre módulos

1. **Llamadas síncronas (default para MVP)**: módulo A llama a `b.contracts.GetX(id)`.
2. **Eventos / pub-sub**: solo cuando hay >2 consumidores, el procesamiento puede ser asincrónico, o querés desacoplar producer y consumer en el tiempo. Implementación en monolito: in-memory event bus o lightweight queue como NATS, **no Kafka**.
3. **Outbox pattern**: si una operación toca DB Y emite evento, usar outbox para garantizar atomicidad (insert del registro + insert en `outbox` en la misma transacción; worker separado publica al event bus).

## Cuándo SÍ extraer un módulo a microservicio

Lista checklist. Solo si la mayoría aplica:

- [ ] Tiene un equipo dedicado que lo opera independientemente.
- [ ] Tiene un perfil de escalado fundamentalmente distinto al resto.
- [ ] Su stack tecnológico tiene que ser diferente (ej: Python para ML).
- [ ] Su ciclo de release es radicalmente distinto.
- [ ] Hay regulación que obliga aislamiento (ej: datos PCI separados).
- [ ] La performance del monolito está saturada y este módulo es el cuello.

Si menos de 3 aplican: NO extraer. Sigue como módulo.

## Ejemplo canónico: ingesta + procesamiento + portal

```
modules/
├── ingestion/           # cronjobs satélite, BCRA, clima
├── scoring/             # model serving + persistencia de scores
├── client_portal/       # API + datos para clientes (cooperativas)
├── admin/               # panel admin de la plataforma
└── platform/            # auth, logging, config, DB pool
```

Comunicación:
- `ingestion` → `scoring`: vía eventos o llamada directa (`scoring.Recompute(productorID)`)
- `client_portal` → `scoring`: llamada síncrona (`scoring.GetScore(productorID)`)
- `admin` → cualquier: solo lectura, con permisos elevados

## Output esperado del Software Architect cuando aplique este skill

`docs/context/03-architecture.md` con:
- Lista de módulos identificados
- Justificación de por qué cada módulo es separado (heurística aplicada)
- Diagrama de dependencias (ASCII o referencia)
- Tabla de contratos entre módulos
- Schema de DB con namespaces por módulo
- Plan de evolución: "si crece X, separar Y primero"
