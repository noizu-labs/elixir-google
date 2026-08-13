defmodule Noizu.Google.Api.AdSense.AdClients do
  @moduledoc """
  AdSense Management API v2 — **AdClients**.

  REST: `accounts/{account}/adclients`

  Docs: https://developers.google.com/adsense/management/reference/rest/v2/accounts.adclients
  """

  use Noizu.Google.Api

  @doc "GET `accounts/{account}/adclients`."
  @spec list(String.t(), opts()) :: result()
  def list(account, opts \\ []) when is_binary(account) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = normalize_account(account) <> "/adclients"

    HTTP.get(path,
      base: :adsense,
      query: page_query(opts),
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  defp normalize_account("accounts/" <> _ = name), do: name
  defp normalize_account(id), do: "accounts/" <> id

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
