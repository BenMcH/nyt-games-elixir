defmodule Nytgames.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NytgamesWeb.Telemetry,
      Nytgames.Repo,
      {DNSCluster, query: Application.get_env(:nytgames, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Nytgames.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Nytgames.Finch},
      # Start a worker by calling: Nytgames.Worker.start_link(arg)
      # {Nytgames.Worker, arg},
      # Start to serve requests, typically the last entry
      NytgamesWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nytgames.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NytgamesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
