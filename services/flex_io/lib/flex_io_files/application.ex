defmodule FlexIoFiles.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FlexIoFilesWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:flex_io_files, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FlexIoFiles.PubSub},
      # Start a worker by calling: FlexIoFiles.Worker.start_link(arg)
      # {FlexIoFiles.Worker, arg},
      # Start to serve requests, typically the last entry
      FlexIoFilesWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FlexIoFiles.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FlexIoFilesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
