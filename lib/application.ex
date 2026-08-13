defmodule Noizu.Google.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: Noizu.Google.Finch}
    ]

    opts = [strategy: :one_for_one, name: Noizu.Google.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
