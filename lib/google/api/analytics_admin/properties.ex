defmodule Noizu.Google.Api.AnalyticsAdmin.Properties do
  @moduledoc """
  Google Analytics Admin API — **Properties** (GA4).

  REST base: `https://analyticsadmin.googleapis.com/v1beta/properties`

  Docs: https://developers.google.com/analytics/devguides/config/admin/v1/rest/v1beta/properties
  """

  use Noizu.Google.Api

  @doc """
  GET `properties` — list properties.

  Requires a filter, typically:

      filter: "parent:accounts/123456"

  Optional opts: `:filter` (required by API), `:page_size`, `:page_token`, `:show_deleted`.
  """
  @spec list(opts()) :: result()
  def list(opts \\ []) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)

    HTTP.get("properties",
      base: :analytics_admin,
      query: list_query(opts),
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  GET `properties/{property}` — get a GA4 property.

  `property` may be `"properties/123"` or just `"123"`.
  """
  @spec get(String.t(), opts()) :: result()
  def get(property, opts \\ []) when is_binary(property) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = normalize_property(property)

    HTTP.get(path,
      base: :analytics_admin,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  POST `properties` — create a GA4 property.

  Body example:

      %{
        parent: "accounts/123456",
        displayName: "Example",
        timeZone: "America/Los_Angeles",
        currencyCode: "USD",
        industryCategory: "TECHNOLOGY"
      }
  """
  @spec create(map(), opts()) :: result()
  def create(body, opts \\ []) when is_map(body) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)

    HTTP.post("properties", body,
      base: :analytics_admin,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  PATCH `properties/{property}` — update a property.

  Optional opts: `:update_mask` (field mask string, e.g. `"displayName,timeZone"`).
  """
  @spec patch(String.t(), map(), opts()) :: result()
  def patch(property, body, opts \\ []) when is_binary(property) and is_map(body) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = normalize_property(property)
    query = update_mask_query(opts)

    HTTP.patch(path, body,
      base: :analytics_admin,
      query: query,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  DELETE soft-deletes via Admin API `properties/{property}` DELETE
  (moves property to trash; restore is a separate operation).
  """
  @spec delete(String.t(), opts()) :: result()
  def delete(property, opts \\ []) when is_binary(property) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = normalize_property(property)

    HTTP.delete(path,
      base: :analytics_admin,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  defp normalize_property("properties/" <> _ = name), do: name
  defp normalize_property(id), do: "properties/" <> id

  defp list_query(opts) do
    []
    |> maybe_q("filter", Keyword.get(opts, :filter))
    |> maybe_q("pageSize", Keyword.get(opts, :page_size) || Keyword.get(opts, :pageSize))
    |> maybe_q("pageToken", Keyword.get(opts, :page_token) || Keyword.get(opts, :pageToken))
    |> maybe_q("showDeleted", Keyword.get(opts, :show_deleted) || Keyword.get(opts, :showDeleted))
    |> case do
      [] -> nil
      q -> q
    end
  end

  defp update_mask_query(opts) do
    mask = Keyword.get(opts, :update_mask) || Keyword.get(opts, :updateMask)

    case mask do
      nil -> nil
      m -> [{"updateMask", m}]
    end
  end

  defp maybe_q(q, _k, nil), do: q
  defp maybe_q(q, k, v), do: q ++ [{k, v}]
end
