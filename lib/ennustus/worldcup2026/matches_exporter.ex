defmodule Ennustus.Worldcup2026.MatchesExporter do
  alias Ennustus.Games.Match

  alias Ennustus.Repo

  import Ecto.Query

  def export(:group_stage) do
    matches =
      [
        [1, "Mexico", "South Africa"],
        [2, "Rep. of Korea", "Czech Rep."],
        [3, "Canada", "Bosnia/Herzeg."],
        [4, "USA", "Paraguay"],
        [5, "Haiti", "Scotland"],
        [6, "Australia", "Turkey"],
        [7, "Brazil", "Morocco"],
        [8, "Qatar", "Switzerland"],
        [9, "Ivory Coast", "Ecuador"],
        [10, "Germany", "Curaçao"],
        [11, "Netherlands", "Japan"],
        [12, "Sweden", "Tunisia"],
        [13, "Saudi Arabia", "Uruguay"],
        [14, "Spain", "Cape Verde"],
        [15, "IR Iran", "New Zealand"],
        [16, "Belgium", "Egypt"],
        [17, "France", "Senegal"],
        [18, "Iraq", "Norway"],
        [19, "Argentina", "Algeria"],
        [20, "Austria", "Jordan"],
        [21, "Ghana", "Panama"],
        [22, "England", "Croatia"],
        [23, "Portugal", "DR Congo"],
        [24, "Uzbekistan", "Colombia"],
        [25, "Czech Rep.", "South Africa"],
        [26, "Switzerland", "Bosnia/Herzeg."],
        [27, "Canada", "Qatar"],
        [28, "Mexico", "Rep. of Korea"],
        [29, "Brazil", "Haiti"],
        [30, "Scotland", "Morocco"],
        [31, "Turkey", "Paraguay"],
        [32, "USA", "Australia"],
        [33, "Germany", "Ivory Coast"],
        [34, "Ecuador", "Curaçao"],
        [35, "Netherlands", "Sweden"],
        [36, "Tunisia", "Japan"],
        [37, "Uruguay", "Cape Verde"],
        [38, "Spain", "Saudi Arabia"],
        [39, "Belgium", "IR Iran"],
        [40, "New Zealand", "Egypt"],
        [41, "Norway", "Senegal"],
        [42, "France", "Iraq"],
        [43, "Argentina", "Austria"],
        [44, "Jordan", "Algeria"],
        [45, "England", "Ghana"],
        [46, "Panama", "Croatia"],
        [47, "Portugal", "Uzbekistan"],
        [48, "Colombia", "DR Congo"],
        [49, "Scotland", "Brazil"],
        [50, "Morocco", "Haiti"],
        [51, "Switzerland", "Canada"],
        [52, "Bosnia/Herzeg.", "Qatar"],
        [53, "Czech Rep.", "Mexico"],
        [54, "South Africa", "Rep. of Korea"],
        [55, "Curaçao", "Ivory Coast"],
        [56, "Ecuador", "Germany"],
        [57, "Japan", "Sweden"],
        [58, "Tunisia", "Netherlands"],
        [59, "Turkey", "USA"],
        [60, "Paraguay", "Australia"],
        [61, "Norway", "France"],
        [62, "Senegal", "Iraq"],
        [63, "Egypt", "IR Iran"],
        [64, "New Zealand", "Belgium"],
        [65, "Cape Verde", "Saudi Arabia"],
        [66, "Uruguay", "Spain"],
        [67, "Panama", "England"],
        [68, "Croatia", "Ghana"],
        [69, "Algeria", "Austria"],
        [70, "Jordan", "Argentina"],
        [71, "Colombia", "Portugal"],
        [72, "DR Congo", "Uzbekistan"]
      ]
      |> Enum.map(fn [game_number, hteam, ateam] ->
        %{
          game_number: game_number,
          home_team: hteam,
          away_team: ateam,
          status: :not_started,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        }
      end)

    Repo.insert_all(Match, matches)
  end

  def export(:playoffs) do
    matches =
      73..104
      |> Enum.map(fn game_number ->
        %{
          game_number: game_number,
          home_team: nil,
          away_team: nil,
          status: :not_started,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        }
      end)

    Repo.insert_all(Match, matches)
  end

  def reset(:playoffs) do
    game_numbers = 73..104 |> Enum.to_list()

    from(
      m in Match,
      where: m.game_number in ^game_numbers,
      select: m
    )
    |> Repo.delete_all()
  end
end
