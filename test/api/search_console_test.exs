defmodule Noizu.Google.Api.SearchConsoleTest do
  use ExUnit.Case, async: false
  use Mimic

  alias Noizu.Google.Api.SearchConsole.SearchAnalytics
  alias Noizu.Google.Api.SearchConsole.Sites
  alias Noizu.Google.Api.SearchConsole.Sitemaps
  alias Noizu.Google.Client
  alias Noizu.Google.Error
  alias Noizu.Google.Test.FinchStub

  @client Client.new(access_token: "test-token")
  @site "https://example.com/"
  @sitemap "https://example.com/sitemap.xml"

  setup do
    Mimic.stub(Finch, :request, fn request, _name, _opts ->
      handle(request)
    end)

    :ok
  end

  test "Sites.list GETs webmasters sites with bearer auth" do
    assert {:ok, %{siteEntry: entries}} = Sites.list(client: @client)
    assert [%{siteUrl: "https://example.com/", permissionLevel: "siteOwner"}] = entries
  end

  test "Sites.get encodes site URL in path" do
    assert {:ok, %{siteUrl: "https://example.com/"}} = Sites.get(@site, client: @client)
  end

  test "SearchAnalytics.query POSTs documented path and body" do
    assert {:ok, %{rows: rows}} =
             SearchAnalytics.query(
               @site,
               %{
                 startDate: "2026-01-01",
                 endDate: "2026-01-31",
                 dimensions: ["query"]
               },
               client: @client
             )

    assert [%{keys: ["seo"], clicks: 10}] = rows
  end

  test "Sitemaps.list GETs sitemaps collection" do
    assert {:ok, %{sitemap: maps}} = Sitemaps.list(@site, client: @client)
    assert [%{path: "https://example.com/sitemap.xml"}] = maps
  end

  test "Sitemaps.get encodes feedpath" do
    assert {:ok, %{path: path, lastSubmitted: _}} =
             Sitemaps.get(@site, @sitemap, client: @client)

    assert path == @sitemap
  end

  test "Sitemaps.submit PUTs empty body to feedpath" do
    assert {:ok, nil} = Sitemaps.submit(@site, @sitemap, client: @client)
  end

  test "Sitemaps.delete DELETEs feedpath" do
    assert {:ok, nil} = Sitemaps.delete(@site, @sitemap, client: @client)
  end

  test "missing token returns config error on API surface" do
    bare = Client.new(access_token: nil)

    assert {:error, %Error{tag: :config}} = Sites.list(client: bare)
  end

  # ---------------------------------------------------------------------------

  defp handle(%Finch.Request{
         method: method,
         host: "www.googleapis.com",
         path: path,
         headers: headers,
         body: body
       }) do
    assert_auth(headers)

    cond do
      method == "GET" and path == "/webmasters/v3/sites" ->
        FinchStub.json_response(200, %{
          "siteEntry" => [
            %{"siteUrl" => "https://example.com/", "permissionLevel" => "siteOwner"}
          ]
        })

      method == "GET" and path == "/webmasters/v3/sites/https%3A%2F%2Fexample.com%2F" ->
        FinchStub.json_response(200, %{
          "siteUrl" => "https://example.com/",
          "permissionLevel" => "siteOwner"
        })

      method == "POST" and
          path ==
            "/webmasters/v3/sites/https%3A%2F%2Fexample.com%2F/searchAnalytics/query" ->
        decoded = Jason.decode!(body)
        assert decoded["startDate"] == "2026-01-01"
        assert decoded["endDate"] == "2026-01-31"
        assert decoded["dimensions"] == ["query"]
        assert header(headers, "content-type") == "application/json"

        FinchStub.json_response(200, %{
          "rows" => [%{"keys" => ["seo"], "clicks" => 10, "impressions" => 100}]
        })

      method == "GET" and
          path == "/webmasters/v3/sites/https%3A%2F%2Fexample.com%2F/sitemaps" ->
        FinchStub.json_response(200, %{
          "sitemap" => [
            %{
              "path" => "https://example.com/sitemap.xml",
              "lastSubmitted" => "2026-01-15T00:00:00.000Z"
            }
          ]
        })

      method == "GET" and
          path ==
            "/webmasters/v3/sites/https%3A%2F%2Fexample.com%2F/sitemaps/https%3A%2F%2Fexample.com%2Fsitemap.xml" ->
        FinchStub.json_response(200, %{
          "path" => "https://example.com/sitemap.xml",
          "lastSubmitted" => "2026-01-15T00:00:00.000Z",
          "isPending" => false
        })

      method == "PUT" and
          path ==
            "/webmasters/v3/sites/https%3A%2F%2Fexample.com%2F/sitemaps/https%3A%2F%2Fexample.com%2Fsitemap.xml" ->
        FinchStub.json_response(204, nil)

      method == "DELETE" and
          path ==
            "/webmasters/v3/sites/https%3A%2F%2Fexample.com%2F/sitemaps/https%3A%2F%2Fexample.com%2Fsitemap.xml" ->
        FinchStub.json_response(204, nil)

      true ->
        FinchStub.json_response(404, %{
          "error" => %{
            "code" => 404,
            "message" => "unknown path #{method} #{path}",
            "status" => "NOT_FOUND"
          }
        })
    end
  end

  defp assert_auth(headers) do
    assert header(headers, "authorization") == "Bearer test-token"
  end

  defp header(headers, name) do
    Enum.find_value(headers, fn {k, v} ->
      if String.downcase(k) == name, do: v
    end)
  end
end
