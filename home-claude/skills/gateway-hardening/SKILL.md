---
name: gateway-hardening
description: Configure or audit an API gateway with strict security: no wildcards, explicit endpoints, rate limiting per endpoint, security headers. Use when designing gateway in Fase 3B, or auditing existing gateway config. Auto-invoke when user says "gateway", "configurar gateway", "auditar gateway", "/gateway-config", "wildcards", "rate limit".
---

# Gateway Hardening

Este skill es la respuesta a una de las preguntas más repetidas del usuario: "¿qué gateway poner y está bien configurado, sin wildcards?". Encapsula la decisión + checklist anti-wildcard + configuraciones de referencia.

## Cuándo usar

- Diseñando arquitectura nueva (Fase 3B): elegir y configurar el gateway.
- Auditando gateway existente: ejecutar checklist de hardening.
- Antes de Gate 3B y Gate 4: verificación obligatoria.

## Matriz de decisión: qué gateway elegir

| Caso de uso | Gateway recomendado | Por qué |
|---|---|---|
| Proyecto personal simple, 1-3 servicios, quiero HTTPS automático | **Caddy** | Config mínima, automatic HTTPS, performance excelente, sin yamls complicados |
| Microservicios con Docker, necesito service discovery | **Traefik** | Integración nativa con Docker, dashboard, middlewares ricos |
| API gateway agregador, alto throughput, sin lógica de negocio | **KrakenD** | Stateless, declarativo, performance top, ideal para BFF de agregación |
| Necesito plugins, transformaciones complejas, enterprise features | **Kong** | Ecosistema maduro, plugins, pero más complejo |
| Vivo en Cloudflare/Vercel | **Edge worker / nativo** | Si ya estás en una plataforma, usá su gateway |
| Solo necesito reverse proxy + TLS, nada más | **Nginx** | Solo si vas a operar la complejidad manualmente |

**Default para proyectos del usuario**: Caddy si es simple; KrakenD si es API gateway agregador con BFF.

**Bandera roja**: si elegís Kong para un proyecto personal de 1-2 servicios, justificá muy bien.

## Reglas duras (NO NEGOCIABLES)

1. **CERO wildcards en endpoint declarations**. Cada path declarado explícitamente.
   - ❌ MAL: `/api/*` → forward to backend
   - ✅ BIEN: `/api/v1/scores/{id}`, `/api/v1/scores/batch`, ... cada uno declarado.

2. **Rate limit por endpoint**. Default global no alcanza.
   - Endpoint de login: estricto (ej: 5/min por IP).
   - Endpoint de lectura general: razonable (ej: 60/min).
   - Endpoint de batch caro: muy estricto (ej: 5/min con burst).

3. **TLS 1.2+ obligatorio**. TLS 1.0/1.1 deshabilitados.

4. **Headers de seguridad** seteados por gateway:
   - `Strict-Transport-Security: max-age=31536000; includeSubDomains`
   - `X-Content-Type-Options: nosniff`
   - `X-Frame-Options: DENY`
   - `Content-Security-Policy: <restrictivo>`
   - `Referrer-Policy: strict-origin-when-cross-origin`

5. **CORS restrictivo**. Listar orígenes permitidos explícitamente. Sin `*`.

6. **Health/readiness endpoints NO expuestos públicamente**. Solo dentro de la red privada.

7. **Logging de accesos denegados** habilitado. Para detectar ataques.

8. **Backend SIEMPRE en red privada**. El gateway es la única puerta pública.

## Checklist de auditoría

Cuando auditás un gateway existente:

```markdown
# Gateway Audit — <fecha>

## Configuración base
- [ ] TLS 1.2+ obligatorio
- [ ] Certificate válido y autorenovable
- [ ] Health endpoints solo internos

## Endpoints
- [ ] **CERO wildcards** en rutas (grep buscando `*`, `:.*`, regex amplias)
- [ ] Cada endpoint declarado explícitamente
- [ ] Endpoints obsoletos eliminados

## Rate limiting
- [ ] Rate limit configurado en TODOS los endpoints públicos
- [ ] Endpoints sensibles (login, recover password) con límite estricto
- [ ] Endpoints caros (batch, ML inference) con límite muy estricto
- [ ] Política definida por IP, por user, o ambas

## Headers
- [ ] HSTS
- [ ] X-Content-Type-Options
- [ ] X-Frame-Options
- [ ] CSP
- [ ] Referrer-Policy

## CORS
- [ ] Orígenes listados explícitamente
- [ ] No hay `Access-Control-Allow-Origin: *`
- [ ] Methods restrictivos a lo necesario

## Auth
- [ ] Endpoints públicos identificados explícitamente
- [ ] Endpoints autenticados rechazan request sin token con 401
- [ ] Token validation en gateway (no solo en backend)

## Backend privacy
- [ ] Backend NO accesible directamente desde internet
- [ ] mTLS gateway→backend (si aplica)

## Logging
- [ ] Access log habilitado
- [ ] Errores 401/403/5xx loggeados con context
- [ ] No hay tokens/secretos en logs

## Performance
- [ ] Timeouts razonables (no infinitos)
- [ ] Connection pooling al backend
- [ ] Compresión habilitada para responses grandes
```

## Templates de configuración

### Caddy (mi recomendación default para proyectos simples)

```caddyfile
# /etc/caddy/Caddyfile
{
    email tu-email@dominio.com
    auto_https on
}

api.tudominio.com {
    # Headers de seguridad globales
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        Referrer-Policy "strict-origin-when-cross-origin"
        Content-Security-Policy "default-src 'self'"
        -Server
    }
    
    # CORS restrictivo
    @cors_preflight method OPTIONS
    handle @cors_preflight {
        header {
            Access-Control-Allow-Origin "https://app.tudominio.com"
            Access-Control-Allow-Methods "GET, POST, PUT, DELETE"
            Access-Control-Allow-Headers "Authorization, Content-Type"
            Access-Control-Max-Age "3600"
        }
        respond "" 204
    }
    
    # Endpoints declarados explícitamente. CERO wildcards.
    
    # Login: rate limit estricto
    @login path /api/v1/auth/login
    handle @login {
        rate_limit {
            zone login {
                key {remote_host}
                events 5
                window 1m
            }
        }
        reverse_proxy auth-service:8080
    }
    
    # Scoring por ID: rate limit normal
    @get_score path_regexp ^/api/v1/scores/[a-zA-Z0-9-]+$
    handle @get_score {
        method GET
        rate_limit {
            zone read {
                key {remote_host}
                events 60
                window 1m
            }
        }
        reverse_proxy scoring-service:8080
    }
    
    # Batch scoring: rate limit muy estricto
    @batch path /api/v1/scores/batch
    handle @batch {
        method POST
        rate_limit {
            zone batch {
                key {remote_host}
                events 5
                window 1m
            }
        }
        reverse_proxy scoring-service:8080
    }
    
    # Resto: reject explícito
    handle {
        respond "Not found" 404
    }
}
```

**Nota**: el `rate_limit` directive requiere el plugin `caddy-rate-limit` (compilar Caddy con xcaddy).

### KrakenD (recomendado para BFF agregador)

```json
{
  "version": 3,
  "name": "agroscore-gateway",
  "port": 8080,
  "timeout": "3s",
  "cache_ttl": "300s",
  "extra_config": {
    "router": {
      "return_error_msg": false,
      "disable_redirect_trailing_slash": true
    },
    "security/cors": {
      "allow_origins": ["https://app.tudominio.com"],
      "allow_methods": ["GET", "POST"],
      "allow_headers": ["Origin", "Authorization", "Content-Type"],
      "expose_headers": [],
      "max_age": "12h"
    }
  },
  "endpoints": [
    {
      "endpoint": "/api/v1/scores/{id}",
      "method": "GET",
      "extra_config": {
        "qos/ratelimit/router": {
          "max_rate": 60,
          "client_max_rate": 60,
          "every": "1m"
        },
        "auth/validator": {
          "alg": "RS256",
          "jwk_url": "https://auth.tudominio.com/.well-known/jwks.json",
          "disable_jwk_security": false
        }
      },
      "backend": [
        {
          "url_pattern": "/scoring/{id}",
          "host": ["http://scoring-service:8080"]
        }
      ]
    }
  ]
}
```

### Traefik (con Docker)

```yaml
# traefik.yml
api:
  dashboard: false  # NO expongas el dashboard a internet

entryPoints:
  websecure:
    address: ":443"
    http:
      tls:
        options: secure@file
        certResolver: letsencrypt

tls:
  options:
    secure:
      minVersion: VersionTLS12

certificatesResolvers:
  letsencrypt:
    acme:
      email: tu-email@dominio.com
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: web

providers:
  docker:
    exposedByDefault: false
  file:
    filename: /etc/traefik/dynamic.yml
```

```yaml
# dynamic.yml
http:
  routers:
    scoring-get:
      rule: "Host(`api.tudominio.com`) && PathRegexp(`^/api/v1/scores/[a-zA-Z0-9-]+$`) && Method(`GET`)"
      service: scoring-service
      middlewares:
        - security-headers
        - rate-limit-read
        - jwt-auth

  middlewares:
    security-headers:
      headers:
        stsSeconds: 31536000
        stsIncludeSubdomains: true
        contentTypeNosniff: true
        frameDeny: true
        referrerPolicy: "strict-origin-when-cross-origin"
    
    rate-limit-read:
      rateLimit:
        average: 60
        burst: 10
        period: 1m
    
    jwt-auth:
      forwardAuth:
        address: "http://auth-service:8080/validate"
```

## Anti-patterns observados (REJECT)

1. **Wildcards "para no listar 20 endpoints"**: si tenés 20 endpoints, declarás los 20. La pereza acá te cuesta seguridad.

2. **Rate limit global "para todos"**: no protege contra abuso de endpoints específicos. Necesitás por endpoint.

3. **CORS `*` "porque dev"**: nunca, ni en dev. Usá staging con CORS estricto desde el principio.

4. **Health endpoint público "para Pingdom"**: usá auth para health endpoints externos. Endpoints internos solo en red privada.

5. **JWT validation solo en backend**: el gateway debe validar también. Defense in depth.

6. **Backend con IP pública "para debug"**: NUNCA. Setup port forwarding o SSH tunnel para debug.

## Output esperado al user

Al ejecutar este skill, producir:
1. **Decisión de gateway** con justificación (en `docs/context/03-gateway.md`).
2. **Configuración inicial** del gateway elegido en el repo, con TODOS los endpoints declarados explícitamente.
3. **Checklist de auditoría** ejecutado.
4. **Sección en `03-security.md`** con la rationale de gateway.
