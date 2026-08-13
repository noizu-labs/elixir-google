defmodule Noizu.GoogleTest do
  use ExUnit.Case, async: true

  alias Noizu.Google.Client

  test "client/0 builds from application config" do
    client = Noizu.Google.client()
    assert %Client{} = client
    assert client.access_token == "test-access-token"
    assert client.webmasters_base =~ "webmasters/v3"
    assert client.finch == Noizu.Google.Finch
  end

  test "client/1 merges explicit opts over defaults" do
    client = Noizu.Google.client(access_token: "override")
    assert client.access_token == "override"
  end

  test "api_base and webmasters_base helpers" do
    assert is_binary(Noizu.Google.api_base())
    assert is_binary(Noizu.Google.webmasters_base())
  end

  test "Application starts named Finch pool" do
    assert Process.whereis(Noizu.Google.Finch)
  end
end
