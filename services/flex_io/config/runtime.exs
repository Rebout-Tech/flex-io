import Config
import Dotenvy

loaded_env = source!([
  ".env",
  ".env.#{config_env()}",
  System.get_env()
])

for {key, value} <- loaded_env, not String.starts_with?(key, "=") do
  System.put_env(key, value)
end

config :flex_io_files,
  storage_adapter: FlexIoFiles.Storage.Adapters.S3

config :ex_aws,
  json_codec: Jason,
  access_key_id: env!("S3_ACCESS_KEY", :string),
  secret_access_key: env!("S3_SECRET_KEY", :string),
  region: env!("S3_REGION", :string, "us-east-1")

config :ex_aws, :s3,
  scheme: env!("S3_SCHEME", :string, "https://"),
  host: env!("S3_HOST", :string),
  port: env!("S3_PORT", :integer)

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "localhost"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :flex_io_files, FlexIoFilesWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    server: true,
    check_origin: false,
    render_errors: [
      formats: [json: FlexIoFilesWeb.ErrorJSON],
      layout: false
    ],
    pubsub_server: FlexIoFiles.PubSub,
    live_view: [signing_salt: "unused"]
end
