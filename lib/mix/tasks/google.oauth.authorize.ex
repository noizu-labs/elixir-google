defmodule Mix.Tasks.Google.Oauth.Authorize do
  @shortdoc "Print Google OAuth authorize URL for marketing scopes"
  @moduledoc """
  Print an OAuth2 authorization URL for the marketing control plane.

      mix google.oauth.authorize
      mix google.oauth.authorize --redirect-uri http://127.0.0.1:8080/oauth2callback

  Env: `GOOGLE_CLIENT_ID` or `GOOGLE_MARKETING_CLIENT_ID`.
  Optional: `GOOGLE_OAUTH_REDIRECT_URI` (default `http://127.0.0.1:8080/oauth2callback`).
  """

  use Mix.Task

  @default_redirect "http://127.0.0.1:8080/oauth2callback"

  @impl Mix.Task
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        strict: [redirect_uri: :string, scope: :string, client_id: :string]
      )

    client_id =
      opts[:client_id] ||
        System.get_env("GOOGLE_MARKETING_CLIENT_ID") ||
        System.get_env("GOOGLE_CLIENT_ID")

    redirect =
      opts[:redirect_uri] ||
        System.get_env("GOOGLE_OAUTH_REDIRECT_URI") ||
        @default_redirect

    scope = opts[:scope] || Noizu.Google.Scopes.marketing_default()

    if is_nil(client_id) or client_id == "" do
      Mix.raise("Set GOOGLE_CLIENT_ID / GOOGLE_MARKETING_CLIENT_ID or pass --client-id")
    end

    url =
      Noizu.Google.OAuth.authorize_url(
        client_id: client_id,
        redirect_uri: redirect,
        scope: scope,
        access_type: "offline",
        prompt: "consent"
      )

    case url do
      {:error, err} ->
        Mix.raise(Exception.message(err))

      url when is_binary(url) ->
        Mix.shell().info("Open this URL in a browser, consent, then copy the ?code= value:")
        Mix.shell().info("")
        Mix.shell().info(url)
        Mix.shell().info("")
        Mix.shell().info("Then run:")
        Mix.shell().info("  mix google.oauth.exchange --code CODE --redirect-uri #{redirect}")
        Mix.shell().info("Or write via dc (recommended):")
        Mix.shell().info("  # see mix google.oauth.exchange --help")
    end
  end
end
