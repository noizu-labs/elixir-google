# Noizu Google

**Google REST API** client for Elixir.

Covers OAuth2 bearer auth, structured errors, Finch + Jason HTTP, Search Console
(webmasters v3), and GA4 Admin/Data APIs. AdSense and Google Ads bases are wired
on the client for upcoming modules.

Part of the **marketing control plane** — see `docs/ADR-001-marketing-control-plane.md`
(MCP server + Terraform provider).

## Installation

```elixir
def deps do
  [
    {:noizu_google, "~> 0.2.0"}
    # monorepo:
    # {:noizu_google, path: "../elixir-google"}
  ]
end
```

### Hex package checklist

| Field | Status |
|-------|--------|
| `app` / package name `noizu_google` | ✓ |
| `version`, `description`, `licenses` | ✓ |
| `maintainers`, `links` (GitHub, Changelog, API) | ✓ |
| `files` (`lib`, mix, README, LICENSE, CHANGELOG) | ✓ |
| Runtime deps: Finch, Jason only | ✓ |

```sh
mix test
mix test --cover
mix hex.build          # builds tarball; does not publish
```

## Configuration

```elixir
# config/runtime.exs
config :noizu_google,
  access_token: System.get_env("GOOGLE_ACCESS_TOKEN"),
  refresh_token: System.get_env("GOOGLE_REFRESH_TOKEN"),
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")
```

Or build a client explicitly:

```elixir
client = Noizu.Google.client(
  access_token: "...",
  client_id: "...",
  client_secret: "..."
)
```

Pass the client on each call via `client:`:

```elixir
Noizu.Google.Api.SearchConsole.Sites.list(client: client)
```

## Quick examples

### Search Console — sites

```elixir
client = Noizu.Google.client(access_token: System.fetch_env!("GOOGLE_ACCESS_TOKEN"))

{:ok, %{siteEntry: sites}} =
  Noizu.Google.Api.SearchConsole.Sites.list(client: client)

{:ok, site} =
  Noizu.Google.Api.SearchConsole.Sites.get("https://example.com/", client: client)
```

### Search Console — search analytics

```elixir
{:ok, report} =
  Noizu.Google.Api.SearchConsole.SearchAnalytics.query(
    "https://example.com/",
    %{
      startDate: "2026-01-01",
      endDate: "2026-01-31",
      dimensions: ["query"],
      rowLimit: 25
    },
    client: client
  )
```

### Search Console — sitemaps

```elixir
site = "https://example.com/"

{:ok, %{sitemap: maps}} =
  Noizu.Google.Api.SearchConsole.Sitemaps.list(site, client: client)

{:ok, sm} =
  Noizu.Google.Api.SearchConsole.Sitemaps.get(
    site,
    "https://example.com/sitemap.xml",
    client: client
  )

{:ok, _} =
  Noizu.Google.Api.SearchConsole.Sitemaps.submit(
    site,
    "https://example.com/sitemap.xml",
    client: client
  )
```

### GA4 Admin — properties & streams

```elixir
{:ok, %{properties: props}} =
  Noizu.Google.Api.AnalyticsAdmin.Properties.list(
    filter: "parent:accounts/123456",
    client: client
  )

{:ok, prop} =
  Noizu.Google.Api.AnalyticsAdmin.Properties.get("properties/789", client: client)

{:ok, %{dataStreams: streams}} =
  Noizu.Google.Api.AnalyticsAdmin.DataStreams.list("properties/789", client: client)
```

### GA4 Data — runReport

```elixir
{:ok, report} =
  Noizu.Google.Api.AnalyticsData.Reports.run_report(
    "properties/789",
    %{
      dateRanges: [%{startDate: "7daysAgo", endDate: "yesterday"}],
      dimensions: [%{name: "sessionDefaultChannelGroup"}],
      metrics: [%{name: "sessions"}]
    },
    client: client
  )
```

### OAuth2

```elixir
url =
  Noizu.Google.OAuth.authorize_url(
    client_id: "CLIENT_ID",
    redirect_uri: "https://example.com/oauth/callback",
    scope: Noizu.Google.Scopes.marketing_default(),
    access_type: "offline",
    prompt: "consent"
  )

{:ok, tokens} =
  Noizu.Google.OAuth.token(
    code: code,
    redirect_uri: "https://example.com/oauth/callback",
    client: client
  )

{:ok, refreshed} =
  Noizu.Google.OAuth.refresh_token(tokens["refresh_token"], client: client)
```

## Architecture

| Module | Role |
|--------|------|
| `Noizu.Google` | Root facade (`client/0|1`) |
| `Noizu.Google.Client` | Credentials + base URLs |
| `Noizu.Google.HTTP` | GET/POST/PUT/DELETE JSON + bearer |
| `Noizu.Google.OAuth` | Authorize / token / refresh |
| `Noizu.Google.Error` | HTTP / transport / codec / config |
| `Noizu.Google.Api.SearchConsole.*` | Sites, SearchAnalytics, Sitemaps |

## Scopes

Common Search Console scopes:

* `https://www.googleapis.com/auth/webmasters.readonly`
* `https://www.googleapis.com/auth/webmasters`
