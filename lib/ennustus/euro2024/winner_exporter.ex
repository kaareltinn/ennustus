defmodule Ennustus.Euro2024.WinnerExporter do
  alias Ennustus.Games.Question
  alias Ennustus.Games.Player

  alias Ennustus.Repo

  import Ecto.Query

  def load_file(filename) do
    Xlsxir.peek(filename, 0, 84)
  end

  def parse_name(filename) do
    filename
    |> String.split("/")
    |> List.last()
    |> String.split(".")
    |> Enum.at(0)
  end

  # WinnerExporter.import_all("../lib/ennustus-0.1.0/priv/data/euro2024")
  def import_all(dirname) do
    {:ok, files} = File.ls(dirname)

    files
    |> Enum.reject(fn filename -> filename == "Lisaküsimused.xlsx" end)
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

    %Question{}
    |> Question.changeset(%{
      answer: data_map["R84"],
      question_number: 9,
      correct: false,
      player_id: player.id
    })
    |> Repo.insert()

    close_file(ref)

    :ok
  end

  def reset() do
    query = from q in Question, where: q.question_number == 9
    Repo.delete_all(query)
  end

  def close_file(ref) do
    Xlsxir.close(ref)
  end
end
