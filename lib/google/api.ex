defmodule Noizu.Google.Api do
  @moduledoc false

  alias Noizu.Google.Client

  defmacro __using__(_opts) do
    quote do
      alias Noizu.Google.Client
      alias Noizu.Google.HTTP
      alias Noizu.Google.Api

      @type opts :: keyword() | map()
      @type result :: {:ok, term()} | {:error, Noizu.Google.Error.t()}
    end
  end

  @doc false
  def normalize_opts(nil), do: []
  def normalize_opts(opts) when is_list(opts), do: opts
  def normalize_opts(opts) when is_map(opts), do: Map.to_list(opts)

  @doc false
  def client(opts) do
    opts = normalize_opts(opts)

    case Keyword.get(opts, :client) do
      %Client{} = c -> c
      _ -> Client.default()
    end
  end

  @doc false
  def decode_opt(opts, default \\ :atoms) do
    Keyword.get(normalize_opts(opts), :decode, default)
  end

  @doc false
  def http_opts(client, opts) do
    opts
    |> normalize_opts()
    |> Keyword.put(:client, client)
    |> Keyword.take([:client, :decode, :auth, :headers, :timeout, :pool_timeout, :query, :base])
  end

  @doc """
  Encode a Search Console site URL for path segments.

  Google expects the site URL to be URL-encoded when embedded in the path
  (e.g. `https://example.com/` → `https%3A%2F%2Fexample.com%2F`).
  """
  @spec encode_site_url(String.t()) :: String.t()
  def encode_site_url(site_url) when is_binary(site_url) do
    URI.encode(site_url, &URI.char_unreserved?/1)
  end

  @doc "Encode a sitemap feed path for the Sitemaps resource path segment."
  @spec encode_feedpath(String.t()) :: String.t()
  def encode_feedpath(feedpath) when is_binary(feedpath) do
    URI.encode(feedpath, &URI.char_unreserved?/1)
  end
end
