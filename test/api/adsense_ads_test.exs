defmodule Noizu.Google.Api.AdSenseAdsTest do
  use ExUnit.Case, async: false
  use Mimic

  alias Noizu.Google.Api.AdSense.Accounts
  alias Noizu.Google.Api.AdSense.AdClients
  alias Noizu.Google.Api.AdSense.AdUnits
  alias Noizu.Google.Api.Ads.Customers
  alias Noizu.Google.Client
  alias Noizu.Google.Error
  alias Noizu.Google.Test.FinchStub

  @client Client.new(access_token: "test-token")

  setup do
    Mimic.stub(Finch, :request, fn request, _name, _opts ->
      handle(request)
    end)

    :ok
  end

  test "AdSense Accounts.list" do
    assert {:ok, %{accounts: accounts}} = Accounts.list(client: @client)
    assert [%{name: "accounts/pub-1"}] = accounts
  end

  test "AdSense AdClients.list" do
    assert {:ok, %{adClients: clients}} =
             AdClients.list("accounts/pub-1", client: @client)

    assert [%{name: "accounts/pub-1/adclients/ca-pub-1"}] = clients
  end

  test "AdSense AdUnits.list" do
    assert {:ok, %{adUnits: units}} =
             AdUnits.list("accounts/pub-1/adclients/ca-pub-1", client: @client)

    assert [%{name: _}] = units
  end

  test "Ads search requires developer token" do
    assert {:error, %Error{tag: :config}} =
             Customers.search("123", %{query: "SELECT 1"}, client: @client)
  end

  test "Ads search posts with developer-token header" do
    assert {:ok, %{results: results}} =
             Customers.search(
               "123-456-7890",
               %{query: "SELECT campaign.id FROM campaign"},
               client: @client,
               developer_token: "dev-tok",
               login_customer_id: "999-888-7777"
             )

    assert is_list(results)
  end

  test "Ads mutate with dry_run sets validateOnly" do
    assert {:ok, %{results: _}} =
             Customers.mutate(
               "1234567890",
               %{
                 mutateOperations: [
                   %{
                     conversionActionOperation: %{
                       create: %{name: "Lead", type: "WEBPAGE", category: "DEFAULT"}
                     }
                   }
                 ]
               },
               client: @client,
               developer_token: "dev-tok",
               dry_run: true
             )
  end

  test "create_conversion_action requires name" do
    assert {:error, %Error{tag: :config}} =
             Customers.create_conversion_action("123",
               client: @client,
               developer_token: "dev-tok"
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
      host == "adsense.googleapis.com" and method == "GET" and path == "/v2/accounts" ->
        FinchStub.json_response(200, %{"accounts" => [%{"name" => "accounts/pub-1"}]})

      host == "adsense.googleapis.com" and method == "GET" and
          path == "/v2/accounts/pub-1/adclients" ->
        FinchStub.json_response(200, %{
          "adClients" => [%{"name" => "accounts/pub-1/adclients/ca-pub-1"}]
        })

      host == "adsense.googleapis.com" and method == "GET" and
          path == "/v2/accounts/pub-1/adclients/ca-pub-1/adunits" ->
        FinchStub.json_response(200, %{
          "adUnits" => [%{"name" => "accounts/pub-1/adclients/ca-pub-1/adunits/1"}]
        })

      host == "googleads.googleapis.com" and method == "POST" and
          path == "/v17/customers/1234567890/googleAds:search" ->
        assert header(headers, "developer-token") == "dev-tok"
        assert header(headers, "login-customer-id") == "9998887777"
        _ = body
        FinchStub.json_response(200, %{"results" => []})

      host == "googleads.googleapis.com" and method == "POST" and
          path == "/v17/customers/1234567890/googleAds:mutate" ->
        assert header(headers, "developer-token") == "dev-tok"
        decoded = Jason.decode!(body)
        assert decoded["validateOnly"] == true
        assert decoded["partialFailure"] == true
        FinchStub.json_response(200, %{"results" => []})

      true ->
        FinchStub.json_response(404, %{"error" => %{"message" => "#{method} #{host}#{path}"}})
    end
  end

  defp header(headers, name) do
    Enum.find_value(headers, fn {k, v} ->
      if String.downcase(k) == name, do: v
    end)
  end
end
