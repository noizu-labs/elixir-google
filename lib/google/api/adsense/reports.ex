defmodule Noizu.Google.Api.AdSense.Reports do
  @moduledoc """
  AdSense Management API v2 — **Reports** (generate).

  REST: `accounts/{account}/reports:generate`
  """

  use Noizu.Google.Api

  @doc """
  GET `accounts/{account}/reports:generate` with report query params.

  Common opts (mapped to query):
  * `:start_date` / `:end_date` — maps or `Date` (year/month/day keys) or `"YYYY-MM-DD"`
  * `:metrics` — list of metric names
  * `:dimensions` — list of dimension names
  * `:currency_code`, `:limit`
  """
  @spec generate(String.t(), opts()) :: result()
  def generate(account, opts \\ []) when is_binary(account) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = normalize_account(account) <> "/reports:generate"

    HTTP.get(path,
      base: :adsense,
      query: report_query(opts),
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  defp normalize_account("accounts/" <> _ = name), do: name
  defp normalize_account(id), do: "accounts/" <> id

  defp report_query(opts) do
    q = []

    q =
      case Keyword.get(opts, :start_date) || Keyword.get(opts, :startDate) do
        nil -> q
        d -> q ++ date_params("startDate", d)
      end

    q =
      case Keyword.get(opts, :end_date) || Keyword.get(opts, :endDate) do
        nil -> q
        d -> q ++ date_params("endDate", d)
      end

    q =
      case Keyword.get(opts, :metrics) do
        nil -> q
        list when is_list(list) -> q ++ Enum.map(list, &{"metrics", &1})
      end

    q =
      case Keyword.get(opts, :dimensions) do
        nil -> q
        list when is_list(list) -> q ++ Enum.map(list, &{"dimensions", &1})
      end

    q
    |> maybe_q("currencyCode", Keyword.get(opts, :currency_code) || Keyword.get(opts, :currencyCode))
    |> maybe_q("limit", Keyword.get(opts, :limit))
    |> case do
      [] -> nil
      out -> out
    end
  end

  defp date_params(prefix, %Date{} = d) do
    [
      {"#{prefix}.year", d.year},
      {"#{prefix}.month", d.month},
      {"#{prefix}.day", d.day}
    ]
  end

  defp date_params(prefix, %{year: y, month: m, day: d}) do
    [{"#{prefix}.year", y}, {"#{prefix}.month", m}, {"#{prefix}.day", d}]
  end

  defp date_params(prefix, %{"year" => y, "month" => m, "day" => d}) do
    [{"#{prefix}.year", y}, {"#{prefix}.month", m}, {"#{prefix}.day", d}]
  end

  defp date_params(prefix, other) when is_binary(other) do
    case Date.from_iso8601(other) do
      {:ok, d} -> date_params(prefix, d)
      _ -> []
    end
  end

  defp maybe_q(q, _k, nil), do: q
  defp maybe_q(q, k, v), do: q ++ [{k, v}]
end
