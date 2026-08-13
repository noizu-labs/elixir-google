defmodule Noizu.Google.Client do
  @moduledoc """
  Client configuration for Google API calls.

  Prefer building a client once and passing it via opts:

      client = Noizu.Google.Client.new(access_token: System.fetch_env!("GOOGLE_ACCESS_TOKEN"))
      Noizu.Google.Api.SearchConsole.Sites.list(client: client)

  When `client` is omitted, a default client is built from application config
  (`:noizu_google`).
  """

  alias Noizu.Google.Error

  @type t :: %__MODULE__{
          access_token: String.t() | nil,
          refresh_token: String.t() | nil,
          client_id: String.t() | nil,
          client_secret: String.t() | nil,
          api_base: String.t(),
          webmasters_base: String.t(),
          analytics_admin_base: String.t(),
          analytics_data_base: String.t(),
          adsense_base: String.t(),
          google_ads_base: String.t(),
          oauth_base: String.t(),
          authorize_url: String.t(),
          receive_timeout: pos_integer(),
          pool_timeout: pos_integer(),
          finch: atom()
        }

  defstruct access_token: nil,
            refresh_token: nil,
            client_id: nil,
            client_secret: nil,
            api_base: "https://www.googleapis.com/",
            webmasters_base: "https://www.googleapis.com/webmasters/v3/",
            analytics_admin_base: "https://analyticsadmin.googleapis.com/v1beta/",
            analytics_data_base: "https://analyticsdata.googleapis.com/v1beta/",
            adsense_base: "https://adsense.googleapis.com/v2/",
            google_ads_base: "https://googleads.googleapis.com/v17/",
            oauth_base: "https://oauth2.googleapis.com/",
            authorize_url: "https://accounts.google.com/o/oauth2/v2/auth",
            receive_timeout: 120_000,
            pool_timeout: 60_000,
            finch: Noizu.Google.Finch

  @doc """
  Build a client from keyword options merged over application env defaults.
  """
  @spec new(keyword() | map()) :: t()
  def new(opts \\ []) do
    opts = Map.new(opts)

    %__MODULE__{
      access_token: pick(opts, :access_token),
      refresh_token: pick(opts, :refresh_token),
      client_id: pick(opts, :client_id),
      client_secret: pick(opts, :client_secret),
      api_base: pick(opts, :api_base, "https://www.googleapis.com/"),
      webmasters_base:
        pick(opts, :webmasters_base, "https://www.googleapis.com/webmasters/v3/"),
      analytics_admin_base:
        pick(
          opts,
          :analytics_admin_base,
          "https://analyticsadmin.googleapis.com/v1beta/"
        ),
      analytics_data_base:
        pick(opts, :analytics_data_base, "https://analyticsdata.googleapis.com/v1beta/"),
      adsense_base: pick(opts, :adsense_base, "https://adsense.googleapis.com/v2/"),
      google_ads_base: pick(opts, :google_ads_base, "https://googleads.googleapis.com/v17/"),
      oauth_base: pick(opts, :oauth_base, "https://oauth2.googleapis.com/"),
      authorize_url:
        pick(opts, :authorize_url, "https://accounts.google.com/o/oauth2/v2/auth"),
      receive_timeout: pick(opts, :receive_timeout, 120_000),
      pool_timeout: pick(opts, :pool_timeout, 60_000),
      finch: pick(opts, :finch, Noizu.Google.Finch)
    }
  end

  @doc "Default client from application config."
  @spec default() :: t()
  def default, do: new()

  @doc "Return a client with an updated access token."
  @spec put_access_token(t(), String.t()) :: t()
  def put_access_token(%__MODULE__{} = client, token) when is_binary(token) do
    %{client | access_token: token}
  end

  @doc """
  Ensure the client has an access token.

  Returns `{:ok, client}` or `{:error, %Noizu.Google.Error{}}`.
  """
  @spec require_token(t()) :: {:ok, t()} | {:error, Error.t()}
  def require_token(%__MODULE__{access_token: token} = client)
      when is_binary(token) and token != "" do
    {:ok, client}
  end

  def require_token(%__MODULE__{}) do
    {:error, Error.config("Google access_token is not configured")}
  end

  @doc """
  Ensure a usable access token, refreshing when only a refresh_token is set.

  Returns `{:ok, client}` with `access_token` populated, or an error.
  """
  @spec ensure_access_token(t()) :: {:ok, t()} | {:error, Error.t()}
  def ensure_access_token(%__MODULE__{access_token: token} = client)
      when is_binary(token) and token != "" do
    {:ok, client}
  end

  def ensure_access_token(%__MODULE__{refresh_token: refresh} = client)
      when is_binary(refresh) and refresh != "" do
    case Noizu.Google.OAuth.refresh_token(refresh, client: client, decode: :strings) do
      {:ok, %{"access_token" => token}} when is_binary(token) and token != "" ->
        {:ok, put_access_token(client, token)}

      {:ok, other} ->
        {:error, Error.config("refresh_token response missing access_token: #{inspect(other)}")}

      {:error, _} = err ->
        err
    end
  end

  def ensure_access_token(%__MODULE__{}) do
    {:error, Error.config("Google access_token or refresh_token is not configured")}
  end

  @doc "Normalize API base URL (trailing slash)."
  @spec normalize_base(String.t()) :: String.t()
  def normalize_base(base) when is_binary(base) do
    if String.ends_with?(base, "/"), do: base, else: base <> "/"
  end

  defp pick(opts, key, default \\ nil) do
    case Map.fetch(opts, key) do
      {:ok, value} -> value
      :error -> Application.get_env(:noizu_google, key, default)
    end
  end
end
