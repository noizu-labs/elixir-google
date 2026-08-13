defmodule Noizu.Google.Api.AnalyticsAdmin.Accounts do
  @moduledoc """
  Google Analytics Admin API — **Accounts**.

  REST base: `https://analyticsadmin.googleapis.com/v1beta/accounts`

  Docs: https://developers.google.com/analytics/devguides/config/admin/v1
  """

  use Noizu.Google.Api

  @doc """
  GET `accounts` — list GA accounts accessible to the authenticated user.

  Optional opts: `:page_size`, `:page_token`, `:show_deleted`.
  """
  @spec list(opts()) :: result()
  def list(opts \\ []) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)

    HTTP.get("accounts",
      base: :analytics_admin,
      query: page_query(opts),
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  GET `accounts/{account}` — get a single account.

  `account` may be `"accounts/123"` or just `"123"`.
  """
  @spec get(String.t(), opts()) :: result()
  def get(account, opts \\ []) when is_binary(account) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = normalize_account(account)

    HTTP.get(path,
      base: :analytics_admin,
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
    |> maybe_q("showDeleted", Keyword.get(opts, :show_deleted) || Keyword.get(opts, :showDeleted))
    |> case do
      [] -> nil
      q -> q
    end
  end

  defp maybe_q(q, _k, nil), do: q
  defp maybe_q(q, k, v), do: q ++ [{k, v}]
end
