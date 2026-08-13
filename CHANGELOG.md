# Changelog

## 0.2.3

- Mix tasks: `google.oauth.authorize`, `google.oauth.exchange` (optional `--write-dc`)

## 0.2.2

- Google Ads `mutate/3` with `dry_run` / `validateOnly` and `create_conversion_action/2`
- OAuth secrets runbook: `docs/oauth-secrets-runbook.md`

## 0.2.1

- AdSense Management API: Accounts, AdClients, AdUnits, Reports.generate
- Google Ads REST skeleton: `Api.Ads.Customers` search / list campaigns / conversion actions

## 0.2.0

- GA4 Admin API: Accounts, Properties, DataStreams
- GA4 Data API: `Reports.run_report/3`
- Client bases: `analytics_admin_base`, `analytics_data_base`, `adsense_base`, `google_ads_base`
- HTTP `PATCH` support
- `Noizu.Google.Scopes` OAuth scope helpers
- `Client.ensure_access_token/1` (refresh when only refresh_token set)
- ADR-001: marketing control plane (MCP + Terraform)

## 0.1.0

- Initial release: Google REST API Elixir client
- Finch + Jason HTTP stack with supervised pool
- OAuth2 authorize / token exchange / refresh
- Structured `Noizu.Google.Error` (HTTP / transport / codec / config)
- Search Console namespace: Sites, SearchAnalytics, Sitemaps
