defmodule Mix.Tasks.Google.Oauth.Exchange do
  @shortdoc "Exchange OAuth code for tokens; optionally write refresh to dc"
  @moduledoc """
  Exchange an authorization code for tokens.

      mix google.oauth.exchange --code CODE
      mix google.oauth.exchange --code CODE --write-dc

  With `--write-dc`, stores into direnv-config (no token printed):

      secrets google.marketing.client_id
      secrets google.marketing.client_secret
      secrets google.marketing.refresh_token

  Env: `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` (or `GOOGLE_MARKETING_*`).
  """

  use Mix.Task

  @default_redirect "http://127.0.0.1:8080/oauth2callback"

  @impl Mix.Task
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        strict: [
          code: :string,
          redirect_uri: :string,
          client_id: :string,
          client_secret: :string,
          write_dc: :boolean,
          print_access: :boolean
        ]
      )

    code = opts[:code] || System.get_env("GOOGLE_OAUTH_CODE")

    client_id =
      opts[:client_id] ||
        System.get_env("GOOGLE_MARKETING_CLIENT_ID") ||
        System.get_env("GOOGLE_CLIENT_ID")

    client_secret =
      opts[:client_secret] ||
        System.get_env("GOOGLE_MARKETING_CLIENT_SECRET") ||
        System.get_env("GOOGLE_CLIENT_SECRET")

    redirect =
      opts[:redirect_uri] ||
        System.get_env("GOOGLE_OAUTH_REDIRECT_URI") ||
        @default_redirect

    cond do
      is_nil(code) or code == "" ->
        Mix.raise("Pass --code or set GOOGLE_OAUTH_CODE")

      is_nil(client_id) or client_id == "" or is_nil(client_secret) or client_secret == "" ->
        Mix.raise("Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET (or GOOGLE_MARKETING_*)")

      true ->
        Application.ensure_all_started(:noizu_google)

        case Noizu.Google.OAuth.token(
               code: code,
               redirect_uri: redirect,
               client_id: client_id,
               client_secret: client_secret,
               decode: :strings
             ) do
          {:ok, tokens} ->
            handle_tokens(tokens, client_id, client_secret, opts)

          {:error, err} ->
            Mix.raise("token exchange failed: #{Exception.message(err)}")
        end
    end
  end

  defp handle_tokens(tokens, client_id, client_secret, opts) do
    refresh = tokens["refresh_token"] || tokens[:refresh_token]
    access = tokens["access_token"] || tokens[:access_token]

    if is_nil(refresh) or refresh == "" do
      Mix.shell().error(
        "No refresh_token in response (Google only returns it on first consent with prompt=consent). " <>
          "Revoke app access and re-authorize."
      )
    else
      Mix.shell().info("refresh_token=received")
    end

    if access && opts[:print_access] do
      Mix.shell().info("access_token=#{access}")
    else
      Mix.shell().info("access_token=#{if access, do: "received", else: "missing"}")
    end

    if opts[:write_dc] do
      write_dc!(client_id, client_secret, refresh)
    else
      Mix.shell().info("Tip: re-run with --write-dc to store under secrets google.marketing.*")
    end
  end

  defp write_dc!(client_id, client_secret, refresh) do
    unless System.find_executable("dc") do
      Mix.raise("`dc` CLI not found; install utilities (make install-utilities)")
    end

    set = fn path, value ->
      if is_binary(value) and value != "" do
        {_, 0} =
          System.cmd(
            "dc",
            ["config", "set", "secrets", path, "--value", value],
            stderr_to_stdout: true
          )
      end
    end

    set.("google.marketing.client_id", client_id)
    set.("google.marketing.client_secret", client_secret)
    set.("google.marketing.refresh_token", refresh)
    Mix.shell().info("Wrote secrets google.marketing.{client_id,client_secret,refresh_token} via dc")
  end
end
