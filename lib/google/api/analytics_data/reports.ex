defmodule Noizu.Google.Api.AnalyticsData.Reports do
  @moduledoc """
  Google Analytics Data API — **Reports** (GA4).

  REST: `POST properties/{property}/runReport`

  Docs: https://developers.google.com/analytics/devguides/reporting/data/v1
  """

  use Noizu.Google.Api

  @doc """
  POST `properties/{propertyId}/runReport`.

  `property` may be `"properties/123"` or `"123"`.

  ## Example

      Noizu.Google.Api.AnalyticsData.Reports.run_report(
        "properties/123456",
        %{
          dateRanges: [%{startDate: "7daysAgo", endDate: "yesterday"}],
          dimensions: [%{name: "sessionDefaultChannelGroup"}],
          metrics: [%{name: "sessions"}]
        },
        client: client
      )
  """
  @spec run_report(String.t(), map(), opts()) :: result()
  def run_report(property, body, opts \\ [])
      when is_binary(property) and is_map(body) do
    client = Api.client(opts)
    opts = Api.normalize_opts(opts)
    path = normalize_property(property) <> "/runReport"

    HTTP.post(path, body,
      base: :analytics_data,
      decode: Api.decode_opt(opts),
      client: client
    )
  end

  defp normalize_property("properties/" <> _ = name), do: name
  defp normalize_property(id), do: "properties/" <> id
end
