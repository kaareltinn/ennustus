defmodule Ennustus.Worldcup2026.GroupStageExporter do
  alias Ennustus.Games.Player
  alias Ennustus.Games.Prediction
  alias Ennustus.Repo

  # The 12 groups are laid out side by side, each occupying three columns:
  # the game-number column, the home-team column and the away-team column.
  @group_number_cols ~w(A D G J M P S V Y AB AE AH)

  # Within a group block the six matches sit at these rows.
  @game_number_rows [11, 16, 21, 26, 31, 36]
  @team_rows [13, 18, 23, 28, 33, 38]
  @goal_rows [14, 19, 24, 29, 34, 39]

  # The 2026 workbook has many sheets; Xlsxir.peek/3 cannot handle it, so we
  # extract every sheet and keep only the first ("World Cup"), closing the rest.
  def load_file(filename) do
    [{:ok, ref} | rest] = Xlsxir.multi_extract(filename, nil, false, extract_to: :memory)
    Enum.each(rest, fn {:ok, r} -> Xlsxir.close(r) end)
    {:ok, ref}
  end

  def parse_name(filename) do
    filename
    |> String.split("/")
    |> List.last()
    |> String.split(".")
    |> Enum.at(0)
  end

  # Run in production:
  # GroupStageExporter.import_all("../lib/ennustus-0.1.0/priv/data/worldcup2026")
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
    {:ok, player} = Repo.insert(Player.changeset(%Player{}, %{name: player_name}))

    data_map = Xlsxir.get_map(ref)

    data =
      for number_col <- @group_number_cols,
          {game_row, team_row, goal_row} <-
            Enum.zip([@game_number_rows, @team_rows, @goal_rows]) do
        home_col = shift(number_col, 1)
        away_col = shift(number_col, 2)

        %{
          game_number: data_map["#{number_col}#{game_row}"] |> trunc(),
          home_team: data_map["#{home_col}#{team_row}"],
          home_goals: trunc(data_map["#{home_col}#{goal_row}"] || 0),
          away_team: data_map["#{away_col}#{team_row}"],
          away_goals: trunc(data_map["#{away_col}#{goal_row}"] || 0),
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
