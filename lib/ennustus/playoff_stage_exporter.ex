defmodule Ennustus.PlayoffStageExporter do
  import Ecto.Query

  alias Ennustus.Repo
  alias Ennustus.Games.Player
  alias Ennustus.Games.Prediction

  def load_file(filename) do
    Xlsxir.peek(filename, 2, 39)
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
        game_number: data_map["AY10"],
        home_team: data_map["AZ10"],
        away_team: data_map["AZ11"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: data_map["AY14"],
        home_team: data_map["AZ14"],
        away_team: data_map["AZ15"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: data_map["AY18"],
        home_team: data_map["AZ18"],
        away_team: data_map["AZ19"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: data_map["AY22"],
        home_team: data_map["AZ22"],
        away_team: data_map["AZ23"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: data_map["AY26"],
        home_team: data_map["AZ26"],
        away_team: data_map["AZ27"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: data_map["AY30"],
        home_team: data_map["AZ30"],
        away_team: data_map["AZ31"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: data_map["AY34"],
        home_team: data_map["AZ34"],
        away_team: data_map["AZ35"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: data_map["AY38"],
        home_team: data_map["AZ38"],
        away_team: data_map["AZ39"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      # 1/8
      %{
        game_number: data_map["BF12"],
        home_team: data_map["BG12"],
        away_team: data_map["BG13"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: data_map["BF20"],
        home_team: data_map["BG20"],
        away_team: data_map["BG21"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: data_map["BF28"],
        home_team: data_map["BG28"],
        away_team: data_map["BG29"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: data_map["BF36"],
        home_team: data_map["BG36"],
        away_team: data_map["BG37"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      # 1/2
      %{
        game_number: data_map["BM16"],
        home_team: data_map["BN16"],
        away_team: data_map["BN17"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        game_number: data_map["BM32"],
        home_team: data_map["BN32"],
        away_team: data_map["BN33"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      # final
      %{
        game_number: data_map["BT23"],
        home_team: data_map["BU23"],
        away_team: data_map["BU24"],
        player_id: player.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      # 3rd
      %{
        game_number: data_map["BT35"],
        home_team: data_map["BU35"],
        away_team: data_map["BU36"],
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
    game_numbers = 49..64 |> Enum.to_list()

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
