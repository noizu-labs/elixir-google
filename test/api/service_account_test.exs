defmodule Noizu.Google.ServiceAccountTest do
  use ExUnit.Case, async: false
  use Mimic

  alias Noizu.Google.Client
  alias Noizu.Google.Error
  alias Noizu.Google.OAuth
  alias Noizu.Google.ServiceAccount
  alias Noizu.Google.Test.FinchStub
  alias Noizu.Google.Test.SAFixture

  @moduletag :capture_log

  test "load_file missing path is config error" do
    assert {:error, %Error{tag: :config, message: msg}} =
             ServiceAccount.load_file("/tmp/noizu-google-missing-#{System.unique_integer([:positive])}.json")

    assert msg =~ "not found"
  end

  test "validate rejects non-service-account type" do
    assert {:error, %Error{tag: :config, message: msg}} =
             ServiceAccount.validate(%{"type" => "authorized_user", "client_email" => "a", "private_key" => "b"})

    assert msg =~ "authorized_user"
  end

  test "validate requires client_email and private_key" do
    assert {:error, %Error{tag: :config}} = ServiceAccount.validate(%{"type" => "service_account"})
  end

  test "assertion signs a 3-part RS256 JWT" do
    creds = SAFixture.creds()
    assert {:ok, jwt} = ServiceAccount.assertion(creds, scope: "https://www.googleapis.com/auth/webmasters")
    assert [header_b64, claims_b64, sig_b64] = String.split(jwt, ".")
    header = header_b64 |> Base.url_decode64!(padding: false) |> Jason.decode!()
    claims = claims_b64 |> Base.url_decode64!(padding: false) |> Jason.decode!()
    assert header["alg"] == "RS256"
    assert claims["iss"] == creds["client_email"]
    assert claims["scope"] == "https://www.googleapis.com/auth/webmasters"
    assert claims["aud"] == "https://oauth2.googleapis.com/token"
    assert is_integer(claims["iat"])
    assert claims["exp"] > claims["iat"]
    assert byte_size(Base.url_decode64!(sig_b64, padding: false)) > 0
  end

  test "assertion includes subject when set" do
    creds = SAFixture.creds()
    assert {:ok, jwt} = ServiceAccount.assertion(creds, subject: "user@example.com")
    [_h, claims_b64, _s] = String.split(jwt, ".")
    claims = claims_b64 |> Base.url_decode64!(padding: false) |> Jason.decode!()
    assert claims["sub"] == "user@example.com"
  end

  test "access_token exchanges jwt-bearer grant" do
    creds = SAFixture.creds()

    Mimic.expect(Finch, :request, fn %Finch.Request{
                                       method: "POST",
                                       host: "oauth2.googleapis.com",
                                       path: "/token",
                                       body: body
                                     },
                                     _n,
                                     _o ->
      form = URI.decode_query(body)
      assert form["grant_type"] == "urn:ietf:params:oauth:grant-type:jwt-bearer"
      assert is_binary(form["assertion"]) and form["assertion"] != ""
      FinchStub.json_response(200, %{"access_token" => "ya29.sa-token", "expires_in" => 3600})
    end)

    assert {:ok, "ya29.sa-token"} = ServiceAccount.access_token(creds)
  end

  test "access_token from credentials file" do
    path = SAFixture.write_temp!()
    on_exit(fn -> File.rm(path) end)

    Mimic.expect(Finch, :request, fn %Finch.Request{body: body}, _n, _o ->
      form = URI.decode_query(body)
      assert form["grant_type"] == "urn:ietf:params:oauth:grant-type:jwt-bearer"
      FinchStub.json_response(200, %{"access_token" => "from-file"})
    end)

    assert {:ok, "from-file"} = ServiceAccount.access_token(path)
  end

  test "Client.ensure_access_token uses service_account map" do
    creds = SAFixture.creds()

    Mimic.expect(Finch, :request, fn %Finch.Request{}, _n, _o ->
      FinchStub.json_response(200, %{"access_token" => "via-client"})
    end)

    client =
      Client.new(
        access_token: nil,
        refresh_token: nil,
        service_account: creds,
        scopes: "https://www.googleapis.com/auth/webmasters"
      )

    assert {:ok, %Client{access_token: "via-client"}} = Client.ensure_access_token(client)
  end

  test "Client.ensure_access_token uses credentials_file" do
    path = SAFixture.write_temp!()
    on_exit(fn -> File.rm(path) end)

    Mimic.expect(Finch, :request, fn %Finch.Request{}, _n, _o ->
      FinchStub.json_response(200, %{"access_token" => "via-file"})
    end)

    client = Client.new(access_token: nil, credentials_file: path)
    assert {:ok, %Client{access_token: "via-file"}} = Client.ensure_access_token(client)
  end

  test "OAuth.jwt_bearer rejects empty assertion" do
    assert {:error, %Error{tag: :config}} = OAuth.jwt_bearer("")
  end
end
