import Config

if System.get_env("PHX_SERVER") do
  config :flex_io_files, FlexIoFilesWeb.Endpoint, server: true
end

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :flex_io_files, FlexIoFilesWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port,
      parser_options: [json: [max_length: 100_000_000]]
    ],
    secret_key_base: secret_key_base,
    check_origin: false,
    render_errors: [
      formats: [json: FlexIoFilesWeb.ErrorJSON],
      layout: false
    ],
    pubsub_server: FlexIoFiles.PubSub,
    live_view: [signing_salt: "unused"]

  # ## SSL Support
  #
  # Если за сервисом стоит Nginx/Traefik/Ingress,
  # то SSL терминируется на прокси, а сюда идет уже чистый HTTP.
  #
  # Если сервис должен сам работать по HTTPS (без прокси):
  #
  #     config :flex_io_files, FlexIoFilesWeb.Endpoint,
  #       https: [
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SSL_KEY_PATH"),
  #         certfile: System.get_env("SSL_CERT_PATH")
  #       ]
end
