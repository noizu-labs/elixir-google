defmodule Noizu.Google.MixProject do
  use Mix.Project

  @version "0.2.4"
  @source_url "https://github.com/noizu-labs/elixir-google"
  @hexdocs_url "https://hexdocs.pm/noizu_google"

  def project do
    [
      app: :noizu_google,
      name: "Noizu Google",
      description: description(),
      package: package(),
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      source_url: @source_url,
      homepage_url: @hexdocs_url,
      test_coverage: [summary: [threshold: 30]]
    ]
  end

  def application do
    [
      mod: {Noizu.Google.Application, []},
      extra_applications: [:logger, :crypto, :public_key]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:finch, "~> 0.18"},
      {:jason, "~> 1.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:mimic, "~> 1.0", only: :test},
      {:junit_formatter, "~> 3.3", only: :test}
    ]
  end

  # Hex.pm description: a short paragraph, max 300 characters.
  defp description do
    """
    Google REST API client for Elixir. OAuth2 (authorize, token, refresh) plus service-account JWT bearer, Finch + Jason HTTP, and structured errors. Search Console, GA4 Admin/Data, AdSense Management, and Google Ads (GAQL search, mutate, conversion actions).
    """
    |> String.trim()
  end

  defp package do
    [
      name: "noizu_google",
      licenses: ["MIT"],
      maintainers: ["Keith Brings"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "HexDocs" => @hexdocs_url,
        "Search Console API" => "https://developers.google.com/webmaster-tools",
        "Analytics Admin API" =>
          "https://developers.google.com/analytics/devguides/config/admin/v1",
        "Analytics Data API" =>
          "https://developers.google.com/analytics/devguides/reporting/data/v1",
        "AdSense Management API" => "https://developers.google.com/adsense/management",
        "Google Ads API" => "https://developers.google.com/google-ads/api/docs/start",
        "Noizu Labs" => "https://github.com/noizu-labs"
      },
      files: ~w(
        lib
        docs
        .formatter.exs
        mix.exs
        README.md
        LICENSE
        CHANGELOG.md
      )
    ]
  end

  defp docs do
    [
      main: "readme",
      authors: ["Keith Brings"],
      source_ref: "v#{@version}",
      source_url: @source_url,
      homepage_url: @hexdocs_url,
      extras: [
        "README.md",
        "CHANGELOG.md",
        {"docs/oauth-secrets-runbook.md", [title: "OAuth & secrets runbook"]},
        {"docs/ADR-001-marketing-control-plane.md", [title: "ADR-001: Marketing control plane"]}
      ],
      groups_for_extras: [
        Guides: [
          "docs/oauth-secrets-runbook.md",
          "docs/ADR-001-marketing-control-plane.md"
        ]
      ],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      nest_modules_by_prefix: [
        Noizu.Google.Api.SearchConsole,
        Noizu.Google.Api.AnalyticsAdmin,
        Noizu.Google.Api.AnalyticsData,
        Noizu.Google.Api.AdSense,
        Noizu.Google.Api.Ads
      ],
      groups_for_modules: [
        Core: [
          Noizu.Google,
          Noizu.Google.Client,
          Noizu.Google.Error,
          Noizu.Google.HTTP,
          Noizu.Google.OAuth,
          Noizu.Google.ServiceAccount,
          Noizu.Google.Scopes
        ],
        "API — Search Console": [
          Noizu.Google.Api.SearchConsole.Sites,
          Noizu.Google.Api.SearchConsole.SearchAnalytics,
          Noizu.Google.Api.SearchConsole.Sitemaps
        ],
        "API — Analytics Admin (GA4)": [
          Noizu.Google.Api.AnalyticsAdmin.Accounts,
          Noizu.Google.Api.AnalyticsAdmin.Properties,
          Noizu.Google.Api.AnalyticsAdmin.DataStreams
        ],
        "API — Analytics Data (GA4)": [
          Noizu.Google.Api.AnalyticsData.Reports
        ],
        "API — AdSense": [
          Noizu.Google.Api.AdSense.Accounts,
          Noizu.Google.Api.AdSense.AdClients,
          Noizu.Google.Api.AdSense.AdUnits,
          Noizu.Google.Api.AdSense.Reports
        ],
        "API — Google Ads": [
          Noizu.Google.Api.Ads.Customers
        ],
        "Mix Tasks": [
          Mix.Tasks.Google.Oauth.Authorize,
          Mix.Tasks.Google.Oauth.Exchange
        ]
      ]
    ]
  end
end
