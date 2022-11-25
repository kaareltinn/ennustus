defmodule Ennustus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      EnnustusWeb.Telemetry,
      # Start the Ecto repository
      Ennustus.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ennustus.PubSub},
      # Start Finch
      {Finch, name: Ennustus.Finch},
      # Start the Endpoint (http/https)
      EnnustusWeb.Endpoint
      # Start a worker by calling: Ennustus.Worker.start_link(arg)
      # {Ennustus.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ennustus.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EnnustusWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
