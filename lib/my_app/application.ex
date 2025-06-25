defmodule MyApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MyApp.Telemetry,
      Data.Repo,
      {DNSCluster,
       query:
         Application.get_env(:my_app, :dns_cluster_query) ||
           :ignore},
      {Phoenix.PubSub, name: MyApp.PubSub},
      {Task, &OAuth.init/0},
      OAuth.Cache,
      # Start the Finch HTTP client for sending emails
      # {Finch, name: MyApp.Finch},
      # Start to serve requests, typically the last entry
      Web.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
