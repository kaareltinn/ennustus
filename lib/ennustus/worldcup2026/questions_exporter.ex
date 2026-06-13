defmodule Ennustus.Worldcup2026.QuestionsExporter do
  @moduledoc """
  Imports the consolidated extra-questions workbook
  (`LISAKÜSIMUSTE VASTUSED.xlsx`): a single sheet where row 0 is the header,
  column 0 is the player name and columns 1–15 hold each player's free-text
  answer to the 15 extra questions.

  The answers are stored as `Question` rows numbered 11–25 (column N → question
  N+10), keeping them clear of the champion (9) and third-place (10) picks. Each
  correctly answered extra question is worth 10 points (see
  `Ennustus.Games.question_scores/0`).
  """

  alias Ennustus.Games.Player
  alias Ennustus.Games.Question
  alias Ennustus.Repo

  import Ecto.Query

  @app :ennustus
  @file_name "LISAKÜSIMUSTE VASTUSED.xlsx"

  # column N in the sheet → question_number N + 10. Titles are the workbook's
  # Estonian header labels, kept here as the source of truth for the admin page.
  @questions [
    {11, "Kaardid"},
    {12, "Esimene punane"},
    {13, "Karistuslöök"},
    {14, "Löödud väravad"},
    {15, "Lastud väravad"},
    {16, "Tõrjutud penalti"},
    {17, "Väravasöödud"},
    {18, "Hat-trick"},
    {19, "Omaväravad"},
    {20, "Golden Boot"},
    {21, "Golden Ball"},
    {22, "Golden Glove"},
    {23, "FIFA Young Player"},
    {24, "Messi/Ronaldo/Neymar/Džeko"},
    {25, "Mbappe/Kane/Vini Jr/Haaland/Yamal"}
  ]

  @doc """
  The 15 extra questions as `{question_number, title}`, ordered by number.
  """
  def questions, do: @questions

  @doc "Default path to the consolidated extra-questions workbook."
  def file_path do
    Path.join(Application.app_dir(@app, "priv/data/worldcup2026"), @file_name)
  end

  @doc """
  Imports the extra-question answers from the default workbook. See `process/1`.
  """
  def process, do: process(file_path())

  @doc """
  Imports the extra-question answers from `filename`.

  Idempotent: players already absent from the workbook import are skipped with a
  log line, and players who already have their extra answers are left untouched
  (so admin correctness markings survive a re-run).
  """
  def process(filename) do
    IO.puts("Parsing extra questions: #{filename}")

    {:ok, ref} = Xlsxir.multi_extract(filename, 0, false, extract_to: :memory)

    Xlsxir.get_mda(ref)
    |> Enum.reject(fn {row_index, row} -> row_index == 0 || is_nil(row[0]) end)
    |> Enum.each(fn {_row_index, row} -> import_row(row) end)

    Xlsxir.close(ref)
    :ok
  end

  defp import_row(row) do
    name = row[0]

    case Repo.get_by(Player, name: name) do
      nil ->
        IO.puts("#{name}: no workbook import — skipping extra questions.")

      player ->
        if already_imported?(player.id) do
          IO.puts("#{name}: extra questions already imported — skipping.")
        else
          Repo.insert_all(Question, question_rows(row, player.id))
          IO.puts("#{name}: imported extra question answers.")
        end
    end
  end

  defp already_imported?(player_id) do
    numbers = Enum.map(@questions, fn {number, _title} -> number end)

    Repo.exists?(
      from q in Question, where: q.player_id == ^player_id and q.question_number in ^numbers
    )
  end

  defp question_rows(row, player_id) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    Enum.map(@questions, fn {number, _title} ->
      %{
        answer: format_answer(row[number - 10]),
        correct: false,
        question_number: number,
        player_id: player_id,
        inserted_at: now,
        updated_at: now
      }
    end)
  end

  defp format_answer(nil), do: ""
  defp format_answer(value) when is_float(value), do: value |> trunc() |> Integer.to_string()
  defp format_answer(value) when is_integer(value), do: Integer.to_string(value)
  defp format_answer(value) when is_binary(value), do: value
end
