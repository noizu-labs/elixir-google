import Config

config :noizu_google,
  access_token: nil,
  refresh_token: nil,
  client_id: nil,
  client_secret: nil,
  api_base: "https://www.googleapis.com/",
  webmasters_base: "https://www.googleapis.com/webmasters/v3/",
  oauth_base: "https://oauth2.googleapis.com/",
  authorize_url: "https://accounts.google.com/o/oauth2/v2/auth",
  receive_timeout: 120_000,
  pool_timeout: 60_000

import_config "#{config_env()}.exs"
