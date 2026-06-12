defmodule Ennustus.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :ennustus

  alias Ennustus.Repo
  alias Ennustus.Games.{Match, Player}

  alias Ennustus.Worldcup2026.{
    MatchesExporter,
    GroupStageExporter,
    PlayoffStageExporter,
    WinnerExporter
  }

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  @doc """
  Idempotently seeds World Cup 2026 data via the `Ennustus.Worldcup2026`
  exporters: the match fixtures (only when no matches exist yet) and every
  entrant's predictions/winner picks found in `priv/data/worldcup2026` (skipping
  entrants already imported).

  Safe to re-run: it never duplicates rows and never clobbers match results that
  have been entered through the admin page.

  Run in production:

      /app/bin/ennustus eval 'Ennustus.Release.seed()'
  """
  def seed do
    load_app()
    {:ok, _} = Application.ensure_all_started(:xlsxir)

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, fn _repo -> seed_worldcup2026() end)
    end
  end

  @doc """
  The idempotent seeding logic, assuming the repo is already started. Called by
  `seed/0` (which starts the repo first) and usable directly when the app is
  already running.
  """
  def seed_worldcup2026 do
    ensure_fixtures()
    Enum.each(prediction_files(), &import_entrant/1)
    :ok
  end

  defp ensure_fixtures do
    if Repo.aggregate(Match, :count) == 0 do
      MatchesExporter.export(:group_stage)
      MatchesExporter.export(:playoffs)
      IO.puts("Seeded 104 match fixtures.")
    else
      IO.puts("Matches already present — skipping fixtures.")
    end
  end

  defp prediction_files do
    dir = Application.app_dir(@app, "priv/data/worldcup2026")

    case File.ls(dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".xlsx"))
        |> Enum.map(&Path.join(dir, &1))

      {:error, _} ->
        IO.puts("No prediction directory at #{dir} — skipping entrant import.")
        []
    end
  end

  defp import_entrant(path) do
    name = GroupStageExporter.parse_name(path)

    if Repo.get_by(Player, name: name) do
      IO.puts("#{name}: already imported — skipping.")
    else
      GroupStageExporter.process(path)
      PlayoffStageExporter.process(path)
      WinnerExporter.process(path)
      IO.puts("#{name}: imported predictions + winner picks.")
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
