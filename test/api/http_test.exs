defmodule Noizu.Google.HTTPTest do
  use ExUnit.Case, async: false
  use Mimic

  alias Noizu.Google.Client
  alias Noizu.Google.Error
  alias Noizu.Google.HTTP
  alias Noizu.Google.Test.FinchStub

  @client Client.new(access_token: "tok")

  test "get success decodes atoms by default" do
    Mimic.expect(Finch, :request, fn %Finch.Request{method: "GET", host: host, headers: headers},
                                     _n,
                                     _o ->
      assert host == "www.googleapis.com"
      assert header(headers, "authorization") == "Bearer tok"
      FinchStub.json_response(200, %{"ok" => true, "n" => 1})
    end)

    assert {:ok, %{ok: true, n: 1}} =
             HTTP.get("webmasters/v3/sites", client: @client, base: :api)
  end

  test "get can decode string keys" do
    Mimic.expect(Finch, :request, fn _req, _n, _o ->
      FinchStub.json_response(200, %{"ok" => true})
    end)

    assert {:ok, %{"ok" => true}} =
             HTTP.get("sites", client: @client, base: :webmasters, decode: :strings)
  end

  test "post encodes JSON body and uses webmasters base" do
    Mimic.expect(Finch, :request, fn %Finch.Request{
                                       method: "POST",
                                       host: "www.googleapis.com",
                                       path: path,
                                       body: body,
                                       headers: headers
                                     },
                                     _n,
                                     _o ->
      assert path == "/webmasters/v3/sites/https%3A%2F%2Fex.com%2F/searchAnalytics/query"
      assert header(headers, "content-type") == "application/json"
      assert header(headers, "authorization") == "Bearer tok"
      assert Jason.decode!(body)["startDate"] == "2026-01-01"
      FinchStub.json_response(200, %{"rows" => []})
    end)

    assert {:ok, %{rows: []}} =
             HTTP.post(
               "sites/https%3A%2F%2Fex.com%2F/searchAnalytics/query",
               %{startDate: "2026-01-01", endDate: "2026-01-31"},
               client: @client,
               base: :webmasters
             )
  end

  test "non-2xx maps to Error with status and Google message" do
    Mimic.expect(Finch, :request, fn _req, _n, _o ->
      FinchStub.json_response(403, %{
        "error" => %{
          "code" => 403,
          "message" => "User does not have sufficient permission",
          "status" => "PERMISSION_DENIED"
        }
      })
    end)

    assert {:error, %Error{status: 403, tag: "PERMISSION_DENIED", summary: summary}} =
             HTTP.get("sites", client: @client, base: :webmasters)

    assert summary =~ "permission"
  end

  test "missing token returns config error without calling Finch" do
    bare = Client.new(access_token: nil)

    assert {:error, %Error{tag: :config, reason: :config}} =
             HTTP.get("sites", client: bare, base: :webmasters)
  end

  test "transport failures become Error.transport" do
    Mimic.expect(Finch, :request, fn _req, _n, _o ->
      {:error, :timeout}
    end)

    assert {:error, %Error{tag: :transport, reason: :timeout}} =
             HTTP.get("sites", client: @client, base: :webmasters)
  end

  test "query params are appended" do
    Mimic.expect(Finch, :request, fn %Finch.Request{query: query}, _n, _o ->
      assert query =~ "sitemapIndex="
      FinchStub.json_response(200, %{"sitemap" => []})
    end)

    assert {:ok, _} =
             HTTP.get("sites/x/sitemaps",
               client: @client,
               base: :webmasters,
               query: [{"sitemapIndex", "https://example.com/sitemap_index.xml"}]
             )
  end

  test "auth: :none skips bearer and does not require token" do
    bare = Client.new(access_token: nil)

    Mimic.expect(Finch, :request, fn %Finch.Request{headers: headers}, _n, _o ->
      refute header(headers, "authorization")
      FinchStub.json_response(200, %{"access_token" => "x"})
    end)

    assert {:ok, %{access_token: "x"}} =
             HTTP.post("token", %{grant_type: "refresh_token"},
               client: bare,
               auth: :none,
               base: "https://oauth2.googleapis.com/"
             )
  end

  defp header(headers, name) do
    Enum.find_value(headers, fn {k, v} ->
      if String.downcase(k) == name, do: v
    end)
  end
end
