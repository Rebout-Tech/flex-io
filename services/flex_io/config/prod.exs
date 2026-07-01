import Config

config :flex_io_files, FlexIoFilesWeb.Endpoint,
  cache_static_lookup: true,
  check_origin: false

config :logger, level: :info
