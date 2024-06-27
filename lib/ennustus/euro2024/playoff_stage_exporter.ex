defmodule Ennustus.Euro2024.PlayoffStageExporter do
  import Ecto.Query

  alias Ennustus.Repo
  alias Ennustus.Games.Player
  alias Ennustus.Games.Prediction

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

  def import_all(dirname) do
    {:ok, files} = File.ls(dirname)

    files
    |> Enum.reject(fn filename -> filename == "Lisaküsimused.xlsx" end)
    |> Enum.each(fn filename ->
      process("#{dirname}/#{filename}")
    end)
  end

  def process(filename) do
    {:ok, ref} = load_file(filename)

    player_name = parse_name(filename)
    player = Repo.get_by(Player, name: player_name)
    data_map = Xlsxir.get_map(ref)

    [
      # 1/16
      %{
        game_number: 37,
        home_team: data_map["E54"],
        away_team: data_map["F54"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: 38,
        home_team: data_map["W54"],
        away_team: data_map["X54"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: 39,
        home_team: data_map["B54"],
        away_team: data_map["C54"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: 40,
        home_team: data_map["T54"],
        away_team: data_map["U54"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: 41,
        home_team: data_map["H54"],
        away_team: data_map["I54"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: 42,
        home_team: data_map["K54"],
        away_team: data_map["L54"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: 43,
        home_team: data_map["N54"],
        away_team: data_map["O54"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: 44,
        home_team: data_map["Q54"],
        away_team: data_map["R54"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      # 1/8
      %{
        game_number: 45,
        home_team: data_map["C64"],
        away_team: data_map["E64"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: 46,
        home_team: data_map["I64"],
        away_team: data_map["K64"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: 47,
        home_team: data_map["O64"],
        away_team: data_map["Q64"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: 48,
        home_team: data_map["U64"],
        away_team: data_map["W64"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      # 1/2
      %{
        game_number: 49,
        home_team: data_map["F74"],
        away_team: data_map["H74"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: 50,
        home_team: data_map["R74"],
        away_team: data_map["T74"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      # final
      %{
        game_number: 51,
        home_team: data_map["L84"],
        away_team: data_map["N84"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    ]
    |> insert_all()

    close_file(ref)

    :ok
  end

  def reset do
    game_numbers = 37..51 |> Enum.to_list()

    from(
      p in Prediction,
      where: p.game_number in ^game_numbers,
      select: p
    )
    |> Repo.delete_all()
  end

  defp insert_all(data) do
    Repo.insert_all(Prediction, data)
  end

  defp close_file(ref) do
    Xlsxir.close(ref)
  end
end
