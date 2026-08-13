import Config

config :noizu_google,
  access_token: nil,
  refresh_token: nil,
  client_id: nil,
  client_secret: nil,
  developer_token: nil,
  login_customer_id: nil,
  api_base: "https://www.googleapis.com/",
  webmasters_base: "https://www.googleapis.com/webmasters/v3/",
  analytics_admin_base: "https://analyticsadmin.googleapis.com/v1beta/",
  analytics_data_base: "https://analyticsdata.googleapis.com/v1beta/",
  adsense_base: "https://adsense.googleapis.com/v2/",
  google_ads_base: "https://googleads.googleapis.com/v17/",
  oauth_base: "https://oauth2.googleapis.com/",
  authorize_url: "https://accounts.google.com/o/oauth2/v2/auth",
  receive_timeout: 120_000,
  pool_timeout: 60_000

import_config "#{config_env()}.exs"
