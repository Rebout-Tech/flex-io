defmodule FlexIoFilesWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :flex_io_files

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library(),
    length: 50_000_000

  plug Plug.MethodOverride
  plug Plug.Head

  plug FlexIoFilesWeb.Router
end
