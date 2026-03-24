import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :flex_io_files, FlexIoFilesWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "a/63TbXQe53xLStlCO2pz5sGwej/8X4DQE8zMwzTduiT9J92l09tIu4BA+5iGcsh",
  server: false

# In test we don't send emails
config :flex_io_files, FlexIoFiles.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
