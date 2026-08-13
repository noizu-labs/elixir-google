defmodule Noizu.Google.OAuthTest do
  use ExUnit.Case, async: false
  use Mimic

  alias Noizu.Google.Client
  alias Noizu.Google.Error
  alias Noizu.Google.OAuth
  alias Noizu.Google.Test.FinchStub

  @client Client.new(
            access_token: nil,
            client_id: "cid",
            client_secret: "csecret"
          )

  test "authorize_url builds Google OAuth URL" do
    url =
      OAuth.authorize_url(
        client: @client,
        redirect_uri: "https://app.example/cb",
        scope: "https://www.googleapis.com/auth/webmasters.readonly",
        access_type: "offline",
        prompt: "consent"
      )

    assert is_binary(url)
    uri = URI.parse(url)
    assert uri.host == "accounts.google.com"
    qs = URI.decode_query(uri.query)
    assert qs["client_id"] == "cid"
    assert qs["redirect_uri"] == "https://app.example/cb"
    assert qs["access_type"] == "offline"
    assert qs["response_type"] == "code"
  end

  test "authorize_url without client_id is config error" do
    assert {:error, %Error{tag: :config}} =
             OAuth.authorize_url(client: Client.new(client_id: nil))
  end

  test "token exchange posts form to oauth2.googleapis.com" do
    Mimic.expect(Finch, :request, fn %Finch.Request{
                                       method: "POST",
                                       host: "oauth2.googleapis.com",
                                       path: "/token",
                                       body: body,
                                       headers: headers
                                     },
                                     _n,
                                     _o ->
      assert header(headers, "content-type") == "application/x-www-form-urlencoded"
      form = URI.decode_query(body)
      assert form["grant_type"] == "authorization_code"
      assert form["code"] == "auth-code"
      assert form["client_id"] == "cid"
      assert form["client_secret"] == "csecret"
      FinchStub.json_response(200, %{"access_token" => "at", "refresh_token" => "rt"})
    end)

    assert {:ok, %{"access_token" => "at", "refresh_token" => "rt"}} =
             OAuth.token(
               code: "auth-code",
               redirect_uri: "https://app.example/cb",
               client: @client
             )
  end

  test "refresh_token posts grant_type refresh_token" do
    Mimic.expect(Finch, :request, fn %Finch.Request{body: body}, _n, _o ->
      form = URI.decode_query(body)
      assert form["grant_type"] == "refresh_token"
      assert form["refresh_token"] == "rt"
      FinchStub.json_response(200, %{"access_token" => "new-at"})
    end)

    assert {:ok, %{"access_token" => "new-at"}} =
             OAuth.refresh_token("rt", client: @client)
  end

  defp header(headers, name) do
    Enum.find_value(headers, fn {k, v} ->
      if String.downcase(k) == name, do: v
    end)
  end
end
