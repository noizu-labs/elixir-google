defmodule Noizu.Google.Api.SearchConsole.Sitemaps do
  @moduledoc """
  Google Search Console **Sitemaps** resource.

  REST base: `sites/{siteUrl}/sitemaps`

  Docs: https://developers.google.com/webmaster-tools/v1/sitemaps
  """

  use Noizu.Google.Api

  @doc """
  GET `sites/{siteUrl}/sitemaps` — list sitemaps submitted for the site.

  Optional query via opts: `sitemapIndex` (feedpath of a sitemap index to expand).
  """
  @spec list(String.t(), opts()) :: result()
  def list(site_url, opts \\ []) when is_binary(site_url) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = "sites/" <> Api.encode_site_url(site_url) <> "/sitemaps"
    query = list_query(opts)

    HTTP.get(path,
      base: :webmasters,
      query: query,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  GET `sites/{siteUrl}/sitemaps/{feedpath}` — get a specific sitemap.
  """
  @spec get(String.t(), String.t(), opts()) :: result()
  def get(site_url, feedpath, opts \\ [])
      when is_binary(site_url) and is_binary(feedpath) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)

    path =
      "sites/" <>
        Api.encode_site_url(site_url) <>
        "/sitemaps/" <>
        Api.encode_feedpath(feedpath)

    HTTP.get(path,
      base: :webmasters,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  PUT `sites/{siteUrl}/sitemaps/{feedpath}` — submit a sitemap.
  """
  @spec submit(String.t(), String.t(), opts()) :: result()
  def submit(site_url, feedpath, opts \\ [])
      when is_binary(site_url) and is_binary(feedpath) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)

    path =
      "sites/" <>
        Api.encode_site_url(site_url) <>
        "/sitemaps/" <>
        Api.encode_feedpath(feedpath)

    HTTP.put(path, %{},
      base: :webmasters,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  DELETE `sites/{siteUrl}/sitemaps/{feedpath}` — delete a submitted sitemap.
  """
  @spec delete(String.t(), String.t(), opts()) :: result()
  def delete(site_url, feedpath, opts \\ [])
      when is_binary(site_url) and is_binary(feedpath) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)

    path =
      "sites/" <>
        Api.encode_site_url(site_url) <>
        "/sitemaps/" <>
        Api.encode_feedpath(feedpath)

    HTTP.delete(path,
      base: :webmasters,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  defp list_query(opts) do
    case Keyword.fetch(opts, :sitemap_index) do
      {:ok, v} -> [{"sitemapIndex", v}]
      :error ->
        case Keyword.fetch(opts, :sitemapIndex) do
          {:ok, v} -> [{"sitemapIndex", v}]
          :error -> nil
        end
    end
  end
end
