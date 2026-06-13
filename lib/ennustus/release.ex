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
    WinnerExporter,
    QuestionsExporter
  }

  # The consolidated extra-questions workbook lives alongside the entrant
  # workbooks but is not an entrant — it is imported separately.
  @extra_questions_file "LISAKÜSIMUSTE VASTUSED.xlsx"

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
    QuestionsExporter.process()
    :ok
  end

  @doc """
  Imports only the consolidated extra-questions workbook, starting the repo
  first so it is runnable via `bin/ennustus eval` in production. Idempotent.

      /app/bin/ennustus eval 'Ennustus.Release.seed_questions()'
  """
  def seed_questions do
    load_app()
    {:ok, _} = Application.ensure_all_started(:xlsxir)

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, fn _repo -> QuestionsExporter.process() end)
    end
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
        |> Enum.reject(&(&1 == @extra_questions_file))
        |> Enum.map(&Path.join(dir, &1))

      {:error, _} ->
        IO.puts("No prediction directory at #{dir} — skipping entrant import.")
        []
    end
  end

  @doc """
  Imports one entrant's workbook (group + playoff predictions and the champion /
  third-place picks), skipping players already present.

  The three exporters run inside a single transaction so a crash mid-import
  (e.g. a large workbook exhausting memory) rolls back the player row instead of
  leaving a half-imported player that future seeds would skip as "already
  imported". A failed import is logged and the seed continues with the next file.
  """
  def import_entrant(path) do
    name = GroupStageExporter.parse_name(path)

    if Repo.get_by(Player, name: name) do
      IO.puts("#{name}: already imported — skipping.")
    else
      try do
        Repo.transaction(fn ->
          GroupStageExporter.process(path)
          PlayoffStageExporter.process(path)
          WinnerExporter.process(path)
        end)

        IO.puts("#{name}: imported predictions + winner picks.")
      rescue
        e ->
          IO.puts(
            "#{name}: import failed — rolled back, will retry next seed. (#{Exception.message(e)})"
          )
      end
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
