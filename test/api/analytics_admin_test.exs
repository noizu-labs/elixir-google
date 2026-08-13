defmodule Noizu.Google.Api.AnalyticsAdminTest do
  use ExUnit.Case, async: false
  use Mimic

  alias Noizu.Google.Api.AnalyticsAdmin.Accounts
  alias Noizu.Google.Api.AnalyticsAdmin.DataStreams
  alias Noizu.Google.Api.AnalyticsAdmin.Properties
  alias Noizu.Google.Api.AnalyticsData.Reports
  alias Noizu.Google.Client
  alias Noizu.Google.Test.FinchStub

  @client Client.new(access_token: "test-token")

  setup do
    Mimic.stub(Finch, :request, fn request, _name, _opts ->
      handle(request)
    end)

    :ok
  end

  test "Accounts.list hits analyticsadmin accounts" do
    assert {:ok, %{accounts: accounts}} = Accounts.list(client: @client)
    assert [%{name: "accounts/1", displayName: "Acme"}] = accounts
  end

  test "Properties.list requires filter query" do
    assert {:ok, %{properties: props}} =
             Properties.list(filter: "parent:accounts/1", client: @client)

    assert [%{name: "properties/99", displayName: "Web"}] = props
  end

  test "Properties.get normalizes id" do
    assert {:ok, %{name: "properties/99"}} = Properties.get("99", client: @client)
  end

  test "DataStreams.list GETs property streams" do
    assert {:ok, %{dataStreams: streams}} =
             DataStreams.list("properties/99", client: @client)

    assert [%{name: "properties/99/dataStreams/1", type: "WEB_DATA_STREAM"}] = streams
  end

  test "Reports.run_report POSTs to analyticsdata" do
    assert {:ok, %{rowCount: 1}} =
             Reports.run_report(
               "99",
               %{
                 dateRanges: [%{startDate: "7daysAgo", endDate: "yesterday"}],
                 metrics: [%{name: "sessions"}]
               },
               client: @client
             )
  end

  defp handle(%Finch.Request{
         method: method,
         host: host,
         path: path,
         headers: headers,
         body: body
       }) do
    assert header(headers, "authorization") == "Bearer test-token"

    cond do
      host == "analyticsadmin.googleapis.com" and method == "GET" and path == "/v1beta/accounts" ->
        FinchStub.json_response(200, %{
          "accounts" => [%{"name" => "accounts/1", "displayName" => "Acme"}]
        })

      host == "analyticsadmin.googleapis.com" and method == "GET" and
          String.starts_with?(path, "/v1beta/properties") and
          not String.contains?(path, "dataStreams") and
          path != "/v1beta/properties/99" ->
        FinchStub.json_response(200, %{
          "properties" => [%{"name" => "properties/99", "displayName" => "Web"}]
        })

      host == "analyticsadmin.googleapis.com" and method == "GET" and
          path == "/v1beta/properties/99" ->
        FinchStub.json_response(200, %{"name" => "properties/99", "displayName" => "Web"})

      host == "analyticsadmin.googleapis.com" and method == "GET" and
          path == "/v1beta/properties/99/dataStreams" ->
        FinchStub.json_response(200, %{
          "dataStreams" => [
            %{"name" => "properties/99/dataStreams/1", "type" => "WEB_DATA_STREAM"}
          ]
        })

      host == "analyticsdata.googleapis.com" and method == "POST" and
          path == "/v1beta/properties/99/runReport" ->
        _ = body
        FinchStub.json_response(200, %{"rowCount" => 1, "rows" => []})

      true ->
        FinchStub.json_response(404, %{
          "error" => %{"message" => "unknown #{method} #{host}#{path}"}
        })
    end
  end

  defp header(headers, name) do
    Enum.find_value(headers, fn {k, v} ->
      if String.downcase(k) == name, do: v
    end)
  end
end
