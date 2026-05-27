---
name: api-contract-design
description: Design API contracts (REST/GraphQL/gRPC) with OpenAPI specs, versioning, error handling, pagination, and BFF patterns. Use in Fase 3B by the API Architect. Auto-invoke when user says "contrato API", "OpenAPI", "diseñar API", "/api-design".
---

# API Contract Design

Skill operativo del API Architect para diseñar contratos de API antes del código. La filosofía: contratos primero, código después.

## Procedimiento

### Paso 1: Decidir el tipo de API por surface

| Surface | Default recomendado | Cuándo cambiar |
|---|---|---|
| Public API (clientes externos, BFF de mobile/web) | **REST + OpenAPI 3** | GraphQL si los clientes son muy heterogéneos |
| Internal API (entre módulos del monolito) | **REST simple o gRPC** | gRPC si performance importa y tenés más control |
| Real-time (notificaciones, updates) | **WebSocket + JSON** | SSE si solo server→client; gRPC streaming si todo es gRPC |
| Batch / async | **HTTP + polling** o **queue (SQS/NATS/RabbitMQ)** | Queue si volumen alto |

### Paso 2: Estructura del contrato REST

Cada API surface tiene un OpenAPI spec independiente en `docs/api/<surface>.openapi.yaml`.

#### Versionado

- Versión en path: `/api/v1/`, `/api/v2/`
- NO versionado por header (más difícil de debugear)
- Backward-compatible additions NO incrementan versión
- Breaking changes incrementan major (v1 → v2)
- Deprecation: header `Sunset: <date>` + warning en docs + 90 días mínimo

#### Resource naming

- Plural y kebab-case en paths: `/api/v1/score-events`, NO `/scoreEvent`
- Nested resources solo 1 nivel: `/productors/{id}/scores` OK, `/productors/{id}/scores/{sid}/details` NO
- IDs en path, filtros en query: `/scores?productor_id=X&from=Y`

#### Métodos y status codes

| Método | Uso | Status codes típicos |
|---|---|---|
| GET | Read | 200 OK, 404 Not Found |
| POST | Create | 201 Created (con Location header), 400 Bad Request, 409 Conflict |
| PUT | Replace | 200 OK / 204 No Content |
| PATCH | Partial update | 200 OK / 204 No Content |
| DELETE | Delete | 204 No Content, 404 Not Found |
| Cualquiera | Auth fail | 401 Unauthorized, 403 Forbidden |
| Cualquiera | Server error | 500 Internal Server Error |
| Cualquiera | Rate limit | 429 Too Many Requests |

#### Error format: RFC 7807 Problem Details

```json
{
  "type": "https://example.com/errors/insufficient-funds",
  "title": "Insufficient Funds",
  "status": 422,
  "detail": "Account balance is below the required amount.",
  "instance": "/accounts/12345"
}
```

Siempre con `Content-Type: application/problem+json`.

#### Pagination: cursor-based (no offset)

```
GET /api/v1/productors?limit=20&cursor=eyJhYmNkIjp0cnVlfQ
```

Response:
```json
{
  "data": [...],
  "next_cursor": "eyJhYmNkIjp0cnVlfQ",
  "has_more": true
}
```

**Por qué cursor y no offset**: cursors son estables ante inserts/deletes. Offset pagination con datasets que cambian = duplicados o gaps.

#### Idempotency keys

Para operaciones críticas (POST de transacciones, payments):

```
POST /api/v1/payments
Idempotency-Key: <uuid>
```

Server cachea response por key durante 24hs. Reintentar con misma key = misma respuesta, no duplicación.

#### Rate limiting headers

Toda response incluye:
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 42
X-RateLimit-Reset: 1715587200
```

Y en 429:
```
Retry-After: 30
```

### Paso 3: BFF (Backend For Frontend) decision

Decidir si necesitás BFF entre clientes y backend:

**Usar BFF cuando**:
- Múltiples clientes (web + mobile) con necesidades distintas
- Los clientes necesitan agregar datos de múltiples servicios
- El dominio interno cambia más rápido que los clientes
- Querés desacoplar las APIs públicas de las internas

**NO usar BFF cuando**:
- Solo un cliente
- Backend ya hace agregaciones internamente
- BFF agrega complejidad sin valor

Si usás BFF: documentar qué BFF habla con qué backend.

### Paso 4: Documentar el contrato (OpenAPI)

Template mínimo:

```yaml
openapi: 3.1.0
info:
  title: Scoring API
  version: '1.0'
  description: |
    Public API for the scoring service.
    See docs/context/03-api-design.md for design decisions.
  contact:
    name: API team

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://api-staging.example.com/v1
    description: Staging

security:
  - bearerAuth: []

paths:
  /scores/{productor_id}:
    get:
      summary: Get latest score for a productor
      operationId: getScore
      parameters:
        - name: productor_id
          in: path
          required: true
          schema:
            type: string
            pattern: '^[a-zA-Z0-9-]+$'
      responses:
        '200':
          description: Score retrieved
          headers:
            X-RateLimit-Limit:
              schema:
                type: integer
            X-RateLimit-Remaining:
              schema:
                type: integer
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Score'
        '404':
          description: Productor not found
          content:
            application/problem+json:
              schema:
                $ref: '#/components/schemas/Problem'
        '429':
          description: Rate limit exceeded
          headers:
            Retry-After:
              schema:
                type: integer
          content:
            application/problem+json:
              schema:
                $ref: '#/components/schemas/Problem'

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  schemas:
    Score:
      type: object
      required: [productor_id, value, computed_at]
      properties:
        productor_id:
          type: string
        value:
          type: number
          minimum: 0
          maximum: 1
        confidence_band:
          type: object
          properties:
            lower:
              type: number
            upper:
              type: number
        drivers:
          type: array
          items:
            $ref: '#/components/schemas/Driver'
        computed_at:
          type: string
          format: date-time

    Problem:
      type: object
      required: [type, title, status]
      properties:
        type:
          type: string
          format: uri
        title:
          type: string
        status:
          type: integer
        detail:
          type: string
        instance:
          type: string
```

### Paso 5: Coordinar con el Security Architect (security)

Cada endpoint público pasa por checklist:

- [ ] ¿Requiere auth? Si sí, qué tipo (JWT, mTLS, API key)?
- [ ] ¿Hay rate limit definido por endpoint?
- [ ] ¿Inputs validados (tipo + rango + formato)?
- [ ] ¿IDs son enumerables? Si sí, hay authz a nivel de recurso?
- [ ] ¿La operación es idempotente o necesita idempotency key?
- [ ] ¿Los errores no exponen internals (stack, queries SQL)?
- [ ] ¿Hay logs estructurados del request/response (sin PII)?

### Paso 6: Validar OpenAPI

```bash
npx @redocly/cli lint docs/api/*.openapi.yaml
```

Sin errores = OK para PR.

## Output esperado

- `docs/context/03-api-design.md`: decisiones de alto nivel (REST vs GraphQL, BFF sí/no, versionado, error format, pagination, idempotency)
- `docs/api/<surface>.openapi.yaml` para cada surface (uno por cliente o por contexto)

## Anti-patterns

- **Wildcards en routing del gateway**: cada endpoint declarado.
- **Errores con estructura inconsistente**: todos los endpoints, mismo formato Problem Details.
- **Offset pagination con datasets que cambian**: usar cursor.
- **Versionar por header**: usar path.
- **Exponer IDs internos en URLs públicas**: usar UUIDs o slugs públicos, internalmente otros IDs.
- **Endpoints "do-everything"**: si un endpoint hace 5 cosas distintas, hacer 5 endpoints.
- **No documentar errores**: cada response 4xx/5xx debe estar en el spec.
- **Polling sobre WebSocket cuando podés usar WebSocket o SSE**: hace ruido a la infra.

## Checklist final

- [ ] Decisión REST/GraphQL/gRPC justificada
- [ ] Decisión de BFF (sí/no) justificada
- [ ] OpenAPI specs en `docs/api/`
- [ ] Versionado en path
- [ ] Errores con RFC 7807
- [ ] Pagination cursor-based
- [ ] Rate limit declarado por endpoint
- [ ] Idempotency keys para operaciones críticas
- [ ] Coordinado con el Security Architect para checklist de seguridad
- [ ] Validado con redocly cli
