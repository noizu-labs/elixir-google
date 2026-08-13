# ADR-001: Google Marketing Control Plane

**Status:** Accepted  
**Date:** 2026-04-07

## Context

We need terminal/agent and IaC management of Google marketing products (Search Console, GA4, AdSense, Google Ads). Official `hashicorp/google` does not cover these marketing APIs. Self-hosted SEO (seonaut/serpbear) and Matomo remain separate.

## Decision

Three planes:

| Plane | Tooling | Examples |
|-------|---------|----------|
| A — GCP, secrets, app IDs | Existing OpenTofu + Infisical + Helm | OAuth client, refresh tokens, `G-` / `ca-pub` in values |
| B — Stable product config | Custom TF provider `noizu/google-marketing` | GSC site, GA4 property/stream, conversion actions |
| C — Ops & intelligence | Elixir MCP server `:noizu_google_mcp` | Reports, bids, URL inspection, day-to-day mutates |

Shared REST foundation: extend `:noizu_google` (`Portfolio/Libs/api/elixir-google`).

Packages:

- `Portfolio/Libs/api/elixir-google` — `:noizu_google`
- `Portfolio/Libs/ai/elixir-google-mcp` — `:noizu_google_mcp`
- `Portfolio/Libs/api/terraform-provider-google-marketing` — `noizu/google-marketing`

## Non-goals (v1)

- Campaigns, bids, budgets as Terraform resources
- Replacing Matomo / seonaut / serpbear
- Full generated Google API surface

## Consequences

- Dual HTTP clients (Elixir + Go) must share resource ID semantics
- OAuth refresh tokens stay in env/secrets, not committed HCL
- Ads spend mutates require MCP guardrails (`dry_run` / `confirm`)
