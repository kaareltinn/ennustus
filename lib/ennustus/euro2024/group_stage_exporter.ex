defmodule Ennustus.Euro2024.GroupStageExporter do
  alias Ennustus.Games.Player
  alias Ennustus.Games.Prediction
  alias Ennustus.Repo

  def load_file(filename) do
    Xlsxir.peek(filename, 0, 41)
  end

  def parse_name(filename) do
    filename
    |> String.split("/")
    |> List.last()
    |> String.split(".")
    |> Enum.at(0)
  end

  # Run in production:
  # GroupStageExporter.import_all("../lib/ennustus-0.1.0/priv/data/euro2024")
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
    {:ok, player} = Repo.insert(Player.changeset(%Player{}, %{name: player_name}))

    data_map = Xlsxir.get_map(ref)

    columns = [
      ["A", "B", "C"],
      ["D", "E", "F"],
      ["G", "H", "I"],
      ["J", "K", "L"],
      ["M", "N", "O"],
      ["P", "Q", "R"]
    ]

    rows = [[11, 13, 14], [16, 18, 19], [21, 23, 24], [26, 28, 29], [31, 33, 34], [38, 40, 41]]

    data =
      for [col_n, col1, col2] <- columns, [row_n, row1, row2] <- rows do
        %{
          game_number: data_map["#{col_n}#{row_n}"] |> trunc(),
          home_team: data_map["#{col1}#{row1}"],
          home_goals: trunc(data_map["#{col1}#{row2}"] || 0),
          away_team: data_map["#{col2}#{row1}"],
          away_goals: trunc(data_map["#{col2}#{row2}"] || 0),
          player_id: player.id,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        }
      end

    Repo.insert_all(Prediction, data)

    close_file(ref)

    data
  end

  def reset() do
    Repo.delete_all(Prediction)
    Repo.delete_all(Player)
  end

  def close_file(ref) do
    Xlsxir.close(ref)
  end
end
