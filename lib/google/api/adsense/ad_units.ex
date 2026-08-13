defmodule Noizu.Google.Api.AdSense.AdUnits do
  @moduledoc """
  AdSense Management API v2 — **AdUnits**.

  REST: `accounts/{account}/adclients/{adClient}/adunits`
  """

  use Noizu.Google.Api

  @doc """
  GET ad units for an ad client.

  `parent` is typically `accounts/{account}/adclients/{adClient}`.
  """
  @spec list(String.t(), opts()) :: result()
  def list(parent, opts \\ []) when is_binary(parent) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = String.trim_leading(parent, "/") <> "/adunits"

    HTTP.get(path,
      base: :adsense,
      query: page_query(opts),
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc "GET a single ad unit by full resource name."
  @spec get(String.t(), opts()) :: result()
  def get(name, opts \\ []) when is_binary(name) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)

    HTTP.get(String.trim_leading(name, "/"),
      base: :adsense,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  defp page_query(opts) do
    []
    |> maybe_q("pageSize", Keyword.get(opts, :page_size) || Keyword.get(opts, :pageSize))
    |> maybe_q("pageToken", Keyword.get(opts, :page_token) || Keyword.get(opts, :pageToken))
    |> case do
      [] -> nil
      q -> q
    end
  end

  defp maybe_q(q, _k, nil), do: q
  defp maybe_q(q, k, v), do: q ++ [{k, v}]
end
