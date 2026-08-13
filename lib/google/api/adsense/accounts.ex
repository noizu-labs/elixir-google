defmodule Noizu.Google.Api.AdSense.Accounts do
  @moduledoc """
  AdSense Management API v2 — **Accounts**.

  REST: `https://adsense.googleapis.com/v2/accounts`

  Docs: https://developers.google.com/adsense/management/reference/rest/v2/accounts
  """

  use Noizu.Google.Api

  @doc "GET `accounts` — list AdSense accounts."
  @spec list(opts()) :: result()
  def list(opts \\ []) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)

    HTTP.get("accounts",
      base: :adsense,
      query: page_query(opts),
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  GET `accounts/{account}` — get an account.

  `account` may be `"accounts/pub-…"` or `"pub-…"`.
  """
  @spec get(String.t(), opts()) :: result()
  def get(account, opts \\ []) when is_binary(account) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)

    HTTP.get(normalize_account(account),
      base: :adsense,
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
