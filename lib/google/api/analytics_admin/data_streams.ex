defmodule Noizu.Google.Api.AnalyticsAdmin.DataStreams do
  @moduledoc """
  Google Analytics Admin API — **Data Streams** (GA4).

  REST: `properties/{property}/dataStreams`

  Docs: https://developers.google.com/analytics/devguides/config/admin/v1/rest/v1beta/properties.dataStreams
  """

  use Noizu.Google.Api

  @doc """
  GET `properties/{property}/dataStreams` — list streams for a property.
  """
  @spec list(String.t(), opts()) :: result()
  def list(property, opts \\ []) when is_binary(property) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = normalize_property(property) <> "/dataStreams"

    HTTP.get(path,
      base: :analytics_admin,
      query: page_query(opts),
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  GET `properties/{property}/dataStreams/{dataStream}` — get a stream.

  Prefer `get(property, stream_id, opts)`. Full resource names are accepted as
  `property` when they already contain `/dataStreams/`.
  """
  @spec get(String.t(), String.t(), opts()) :: result()
  def get(property, stream_id, opts \\ [])
      when is_binary(property) and is_binary(stream_id) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)

    path =
      if String.contains?(property, "/dataStreams/") do
        String.trim_leading(property, "/")
      else
        stream_path(property, stream_id)
      end

    HTTP.get(path,
      base: :analytics_admin,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  POST `properties/{property}/dataStreams` — create a data stream.

  Body example (web stream):

      %{
        type: "WEB_DATA_STREAM",
        displayName: "example.com",
        webStreamData: %{
          defaultUri: "https://example.com"
        }
      }
  """
  @spec create(String.t(), map(), opts()) :: result()
  def create(property, body, opts \\ []) when is_binary(property) and is_map(body) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = normalize_property(property) <> "/dataStreams"

    HTTP.post(path, body,
      base: :analytics_admin,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc """
  PATCH a data stream. Optional `:update_mask`.
  """
  @spec patch(String.t(), String.t(), map(), opts()) :: result()
  def patch(property, stream_id, body, opts \\ [])
      when is_binary(property) and is_binary(stream_id) and is_map(body) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = stream_path(property, stream_id)
    query = update_mask_query(opts)

    HTTP.patch(path, body,
      base: :analytics_admin,
      query: query,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  @doc "DELETE a data stream."
  @spec delete(String.t(), String.t(), opts()) :: result()
  def delete(property, stream_id, opts \\ [])
      when is_binary(property) and is_binary(stream_id) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = stream_path(property, stream_id)

    HTTP.delete(path,
      base: :analytics_admin,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  defp stream_path(property, stream_id) do
    normalize_property(property) <> "/dataStreams/" <> strip_stream(stream_id)
  end

  defp strip_stream("properties/" <> rest) do
    case String.split(rest, "/dataStreams/") do
      [_prop, id] -> id
      _ -> rest
    end
  end

  defp strip_stream(id), do: id

  defp normalize_property("properties/" <> _ = name), do: name
  defp normalize_property(id), do: "properties/" <> id

  defp page_query(opts) do
    []
    |> maybe_q("pageSize", Keyword.get(opts, :page_size) || Keyword.get(opts, :pageSize))
    |> maybe_q("pageToken", Keyword.get(opts, :page_token) || Keyword.get(opts, :pageToken))
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
