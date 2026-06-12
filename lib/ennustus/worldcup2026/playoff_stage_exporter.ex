defmodule Ennustus.Worldcup2026.PlayoffStageExporter do
  import Ecto.Query

  alias Ennustus.Repo
  alias Ennustus.Games.Player
  alias Ennustus.Games.Prediction

  # Each knockout round is a list of base (game-number) columns plus the row
  # holding the game number, the row holding the two picked teams, and the
  # column offsets from the base column to the home and away team cells.
  #
  # {base_cols, number_row, team_row, home_offset, away_offset}
  @rounds [
    {~w(A D G J M P S V Y AB AE AH AK AN AQ AT), 48, 50, 1, 2},
    {~w(A D G J M P S V), 58, 60, 1, 2},
    {~w(B H N T), 68, 70, 1, 3},
    {~w(E Q), 78, 80, 1, 3},
    {~w(K), 86, 88, 1, 3},
    {~w(K), 96, 98, 1, 3}
  ]

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

  def import_all(dirname) do
    {:ok, files} = File.ls(dirname)

    files
    |> Enum.filter(fn filename -> String.ends_with?(filename, ".xlsx") end)
    |> Enum.each(fn filename ->
      process("#{dirname}/#{filename}")
    end)
  end

  def process(filename) do
    {:ok, ref} = load_file(filename)

    player_name = parse_name(filename)
    player = Repo.get_by(Player, name: player_name)
    data_map = Xlsxir.get_map(ref)

    data =
      for {base_cols, number_row, team_row, home_offset, away_offset} <- @rounds,
          base_col <- base_cols do
        %{
          game_number: data_map["#{base_col}#{number_row}"] |> trunc(),
          home_team: data_map["#{shift(base_col, home_offset)}#{team_row}"],
          away_team: data_map["#{shift(base_col, away_offset)}#{team_row}"],
          player_id: player.id,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        }
      end

    Repo.insert_all(Prediction, data)

    close_file(ref)

    :ok
  end

  def reset do
    game_numbers = 73..104 |> Enum.to_list()

    from(
      p in Prediction,
      where: p.game_number in ^game_numbers,
      select: p
    )
    |> Repo.delete_all()
  end

  defp close_file(ref) do
    Xlsxir.close(ref)
  end

  # Spreadsheet column-letter arithmetic, e.g. shift("Z", 1) == "AA".
  defp shift(col, offset), do: number_to_col(col_to_number(col) + offset)

  defp col_to_number(col) do
    col
    |> String.to_charlist()
    |> Enum.reduce(0, fn char, acc -> acc * 26 + (char - ?A + 1) end)
  end

  defp number_to_col(0), do: ""
  defp number_to_col(n), do: number_to_col(div(n - 1, 26)) <> <<rem(n - 1, 26) + ?A>>
end
