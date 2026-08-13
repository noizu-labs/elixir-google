defmodule Noizu.Google.Api.SearchConsole.SearchAnalytics do
  @moduledoc """
  Google Search Console **Search Analytics** resource.

  REST: `POST sites/{siteUrl}/searchAnalytics/query`

  Docs: https://developers.google.com/webmaster-tools/v1/searchanalytics/query
  """

  use Noizu.Google.Api

  @doc """
  POST `sites/{siteUrl}/searchAnalytics/query`.

  ## Request body (map)

  Required:
  * `:startDate` / `"startDate"` — `YYYY-MM-DD`
  * `:endDate` / `"endDate"` — `YYYY-MM-DD`

  Common optional fields: `dimensions`, `rowLimit`, `startRow`, `dimensionFilterGroups`,
  `aggregationType`, `dataState`, `type` (web/image/video/news/discover/googleNews).

  ## Example

      Noizu.Google.Api.SearchConsole.SearchAnalytics.query(
        "https://example.com/",
        %{
          startDate: "2026-01-01",
          endDate: "2026-01-31",
          dimensions: ["query", "page"],
          rowLimit: 25
        },
        client: client
      )
  """
  @spec query(String.t(), map(), opts()) :: result()
  def query(site_url, body, opts \\ [])
      when is_binary(site_url) and is_map(body) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = "sites/" <> Api.encode_site_url(site_url) <> "/searchAnalytics/query"

    HTTP.post(path, body,
      base: :webmasters,
      decode: Api.decode_opt(opts),
      client: client
    )
  end
end
