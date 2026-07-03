import Config

config :flex_io_files,
  generators: [timestamp_type: :utc_datetime]

config :flex_io_files,
  storage_adapter: FlexIoFiles.Storage.Adapters.S3

config :ex_aws,
  json_codec: Jason,
  access_key_id: System.get_env("S3_ACCESS_KEY", "any_access_key"),
  secret_access_key: System.get_env("S3_SECRET_KEY", "any_secret_key"),
  region: "us-east-1"

config :ex_aws, :s3,
  scheme: System.get_env("S3_SCHEME", "http://"),
  host: System.get_env("S3_HOST", "localhost"),
  port: System.get_env("S3_PORT", "8333"),
  region: "us-east-1"

config :flex_io_files, FlexIoFilesWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: FlexIoFilesWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: FlexIoFiles.PubSub,
  live_view: [signing_salt: "aBcDeFgHiJkLmNoPqRsTuVwXyZ123456"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
