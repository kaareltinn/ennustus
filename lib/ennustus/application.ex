defmodule Ennustus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        # Start the Telemetry supervisor
        EnnustusWeb.Telemetry,
        # Start the Ecto repository
        Ennustus.Repo,
        # Run migrations on boot when configured (SQLite on Fly mounts the data
        # volume only on the app machine, not the release_command machine)
        migrator_child(),
        # Start the PubSub system
        {Phoenix.PubSub, name: Ennustus.PubSub},
        # Start Finch
        {Finch, name: Ennustus.Finch},
        # Start the Endpoint (http/https)
        EnnustusWeb.Endpoint
        # Start a worker by calling: Ennustus.Worker.start_link(arg)
        # {Ennustus.Worker, arg}
      ]
      |> Enum.reject(&is_nil/1)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ennustus.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp migrator_child do
    if Application.get_env(:ennustus, :run_migrations_on_boot, false) do
      repos = Application.fetch_env!(:ennustus, :ecto_repos)
      {Ecto.Migrator, repos: repos}
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EnnustusWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
