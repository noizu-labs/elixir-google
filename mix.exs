defmodule Noizu.Google.MixProject do
  use Mix.Project

  @version "0.2.3"
  @source_url "https://github.com/noizu-labs/elixir-google"

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
      homepage_url: @source_url,
      test_coverage: [summary: [threshold: 30]]
    ]
  end

  def application do
    [
      mod: {Noizu.Google.Application, []},
      extra_applications: [:logger, :crypto]
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

  defp description do
    """
    Google REST API client for Elixir — OAuth2 bearer auth, Finch + Jason HTTP,
    structured errors, Search Console, and GA4 Admin/Data APIs (AdSense/Ads next).
    """
  end

  defp package do
    [
      name: "noizu_google",
      licenses: ["MIT"],
      maintainers: ["Keith Brings"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "Search Console API" => "https://developers.google.com/webmaster-tools",
        "Analytics Admin API" =>
          "https://developers.google.com/analytics/devguides/config/admin/v1",
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
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: [
        "README.md",
        "CHANGELOG.md",
        "docs/ADR-001-marketing-control-plane.md",
        "docs/oauth-secrets-runbook.md"
      ],
      groups_for_modules: [
        Core: [
          Noizu.Google,
          Noizu.Google.Client,
          Noizu.Google.Error,
          Noizu.Google.HTTP,
          Noizu.Google.OAuth,
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
        ]
      ]
    ]
  end
end
