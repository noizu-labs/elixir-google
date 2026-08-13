defmodule Noizu.Google.Test.FinchStub do
  @moduledoc false

  def json_response(status, nil) do
    {:ok,
     %Finch.Response{
       status: status,
       body: "",
       headers: [{"content-type", "application/json"}]
     }}
  end

  def json_response(status, body) when is_map(body) or is_list(body) do
    {:ok,
     %Finch.Response{
       status: status,
       body: Jason.encode!(body),
       headers: [{"content-type", "application/json"}]
     }}
  end

  def json_response(status, body) when is_binary(body) do
    {:ok, %Finch.Response{status: status, body: body, headers: []}}
  end
end
