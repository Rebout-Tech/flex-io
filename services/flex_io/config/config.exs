import Config

config :flex_io_files,
  generators: [timestamp_type: :utc_datetime]

config :flex_io_files, FlexIoFilesWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: FlexIoFilesWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: FlexIoFiles.PubSub

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
