defmodule Foobar.GroupStageExporter do
  alias Foobar.Games.Player
  alias Foobar.Games.Prediction
  alias Foobar.Repo

  def load_file(filename) do
    Xlsxir.peek("lib/data/#{filename}", 2, 54)
  end

  def parse_name(filename) do
    filename
    |> String.split(".")
    |> Enum.at(0)
  end

  def import_all do
    {:ok, files} = File.ls("lib/data")

    files
    |> Enum.each(fn filename ->
      process(filename)
    end)
  end

  def process(filename) do
    {:ok, ref} = load_file(filename)

    player_name = parse_name(filename)
    {:ok, player} = Repo.insert(Player.changeset(%Player{}, %{name: player_name}))

    IO.puts("Parsing: #{player_name}")

    data =
      Xlsxir.get_list(ref)
      |> Enum.slice(5, 48)
      |> Enum.map(fn data ->
        %{
          game_number: Enum.at(data, 0),
          home_team: Enum.at(data, 4),
          home_goals: trunc(Enum.at(data, 5)),
          away_team: Enum.at(data, 7),
          away_goals: trunc(Enum.at(data, 6)),
          player_id: player.id,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        }
      end)

    Repo.insert_all(Prediction, data)

    close_file(ref)

    :ok
  end

  def reset() do
    Repo.delete_all(Prediction)
    Repo.delete_all(Player)
  end

  def close_file(ref) do
    Xlsxir.close(ref)
  end
end