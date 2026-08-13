defmodule Noizu.Google.Api.SearchConsole.Sites do
  @moduledoc """
  Google Search Console **Sites** resource.

  REST base: `https://www.googleapis.com/webmasters/v3/sites`

  Docs: https://developers.google.com/webmaster-tools/v1/sites
  """

  use Noizu.Google.Api

  @doc """
  GET `sites` — list sites in the authenticated Search Console account.
  """
  @spec list(opts()) :: result()
  def list(opts \\ []) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)

    HTTP.get("sites",
      base: :webmasters,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  GET `sites/{siteUrl}` — get a site's permission level for the authenticated user.
  """
  @spec get(String.t(), opts()) :: result()
  def get(site_url, opts \\ []) when is_binary(site_url) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = "sites/" <> Api.encode_site_url(site_url)

    HTTP.get(path,
      base: :webmasters,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  PUT `sites/{siteUrl}` — add a site to Search Console.
  """
  @spec add(String.t(), opts()) :: result()
  def add(site_url, opts \\ []) when is_binary(site_url) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = "sites/" <> Api.encode_site_url(site_url)

    HTTP.put(path, %{},
      base: :webmasters,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  DELETE `sites/{siteUrl}` — remove a site from Search Console.
  """
  @spec delete(String.t(), opts()) :: result()
  def delete(site_url, opts \\ []) when is_binary(site_url) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = "sites/" <> Api.encode_site_url(site_url)

    HTTP.delete(path,
      base: :webmasters,
      decode: Api.decode_opt(opts),
      client: client
    )
  end
end
