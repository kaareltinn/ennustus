defmodule Ennustus.Worldcup2026.WinnerExporter do
  alias Ennustus.Games.Question
  alias Ennustus.Games.Player

  alias Ennustus.Repo

  import Ecto.Query

  # The champion pick lives in a dedicated cell. The third-place winner is not a
  # dedicated cell: it is whichever team the player predicted to win the
  # third-place match (game 103, teams in L88/N88, goals in L89/N89).
  @champion_cell "R98"
  @third_place_home_team "L88"
  @third_place_home_goals "L89"
  @third_place_away_team "N88"
  @third_place_away_goals "N89"

  @champion_question 9
  @third_place_question 10

  def load_file(filename) do
    Ennustus.Worldcup2026.Workbook.load(filename)
  end

  def parse_name(filename) do
    filename
    |> String.split("/")
    |> List.last()
    |> String.split(".")
    |> Enum.at(0)
  end

  # WinnerExporter.import_all("../lib/ennustus-0.1.0/priv/data/worldcup2026")
  def import_all(dirname) do
    {:ok, files} = File.ls(dirname)

    files
    |> Enum.filter(fn filename -> String.ends_with?(filename, ".xlsx") end)
    |> Enum.each(fn filename ->
      process("#{dirname}/#{filename}")
    end)
  end

  def process(filename) do
    IO.puts("Parsing: #{filename}")

    {:ok, ref} = load_file(filename)

    player_name = parse_name(filename)
    player = Repo.get_by(Player, name: player_name)
    data_map = Xlsxir.get_map(ref)

    insert_question(data_map[@champion_cell], @champion_question, player.id)
    insert_question(third_place_winner(data_map), @third_place_question, player.id)

    close_file(ref)

    :ok
  end

  def reset() do
    query = from q in Question, where: q.question_number in [@champion_question, @third_place_question]
    Repo.delete_all(query)
  end

  def close_file(ref) do
    Xlsxir.close(ref)
  end

  defp third_place_winner(data_map) do
    home_goals = trunc(data_map[@third_place_home_goals] || 0)
    away_goals = trunc(data_map[@third_place_away_goals] || 0)

    if home_goals >= away_goals do
      data_map[@third_place_home_team]
    else
      data_map[@third_place_away_team]
    end
  end

  defp insert_question(answer, question_number, player_id) do
    %Question{}
    |> Question.changeset(%{
      answer: answer,
      question_number: question_number,
      correct: false,
      player_id: player_id
    })
    |> Repo.insert()
  end
end
