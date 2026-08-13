defmodule Noizu.Google.Scopes do
  @moduledoc """
  Common OAuth2 scope URLs for Google marketing APIs.

  Pass one or more (space-separated) to `Noizu.Google.OAuth.authorize_url/1`
  via the `:scope` option.
  """

  @search_console "https://www.googleapis.com/auth/webmasters"
  @search_console_readonly "https://www.googleapis.com/auth/webmasters.readonly"

  @analytics "https://www.googleapis.com/auth/analytics"
  @analytics_readonly "https://www.googleapis.com/auth/analytics.readonly"
  @analytics_edit "https://www.googleapis.com/auth/analytics.edit"

  @adsense "https://www.googleapis.com/auth/adsense"
  @adsense_readonly "https://www.googleapis.com/auth/adsense.readonly"

  @adwords "https://www.googleapis.com/auth/adwords"

  @doc "Search Console full access."
  def search_console, do: @search_console

  @doc "Search Console read-only."
  def search_console_readonly, do: @search_console_readonly

  @doc "Google Analytics (includes GA4 Admin + Data) full."
  def analytics, do: @analytics

  @doc "Google Analytics read-only."
  def analytics_readonly, do: @analytics_readonly

  @doc "Google Analytics edit (Admin API write)."
  def analytics_edit, do: @analytics_edit

  @doc "AdSense full."
  def adsense, do: @adsense

  @doc "AdSense read-only."
  def adsense_readonly, do: @adsense_readonly

  @doc "Google Ads API."
  def adwords, do: @adwords

  @doc """
  Recommended offline-consent scope string for marketing automation.

  Includes Search Console + Analytics edit + AdSense readonly + Ads.
  Narrow in production to least privilege.
  """
  def marketing_default do
    Enum.join(
      [
        @search_console,
        @analytics_edit,
        @analytics_readonly,
        @adsense_readonly,
        @adwords
      ],
      " "
    )
  end

  @doc "Join a list of scope URLs into a space-separated string."
  @spec join([String.t()]) :: String.t()
  def join(scopes) when is_list(scopes), do: Enum.join(scopes, " ")
end
