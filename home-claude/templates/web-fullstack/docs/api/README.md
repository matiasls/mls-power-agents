# API Specifications

This directory holds OpenAPI 3.x specs for each API in the system.

## Conventions

- One file per API surface: `<api-name>.openapi.yaml`
- Public API: `<api>-public.openapi.yaml`
- Internal API (between modules): `<api>-internal.openapi.yaml`
- Specs are the source of truth — code must match.

## Validation

```bash
# Lint specs
npx @redocly/cli lint *.openapi.yaml

# Preview
npx @redocly/cli preview-docs <api>.openapi.yaml
```

## Generated content

If you generate client SDKs or server stubs from these specs, the generated code goes elsewhere (not in this dir).

el API Architect (api architect) owns this directory.
