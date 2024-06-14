defmodule Ennustus.Euro2024.MatchesExporter do
  alias Ennustus.Games.Match

  alias Ennustus.Repo

  def export(:group_stage) do
    matches =
      [
        [1, "Germany", "Scotland"],
        [2, "Hungary", "Switzerland"],
        [14, "Germany", "Hungary"],
        [13, "Scotland", "Switzerland"],
        [25, "Switzerland", "Germany"],
        [26, "Scotland", "Hungary"],
        [3, "Spain", "Croatia"],
        [4, "Italy", "Albania"],
        [15, "Croatia", "Albania"],
        [16, "Spain", "Italy"],
        [27, "Albania", "Spain"],
        [28, "Croatia", "Italy"],
        [6, "Slovenia", "Denmark"],
        [5, "Serbia", "England"],
        [18, "Slovenia", "Serbia"],
        [17, "Denmark", "England"],
        [29, "England", "Slovenia"],
        [30, "Denmark", "Serbia"],
        [7, "Poland", "Netherlands"],
        [8, "Austria", "France"],
        [19, "Poland", "Austria"],
        [20, "Netherlands", "France"],
        [31, "Netherlands", "Austria"],
        [32, "France", "Poland"],
        [10, "Romania", "Ukraine"],
        [9, "Belgium", "Slovakia"],
        [21, "Slovakia", "Ukraine"],
        [22, "Belgium", "Romania"],
        [33, "Slovakia", "Romania"],
        [34, "Ukraine", "Belgium"],
        [11, "Türkiye", "Georgia"],
        [12, "Portugal", "Czechia"],
        [24, "Georgia", "Czechia"],
        [23, "Türkiye", "Portugal"],
        [35, "Georgia", "Portugal"],
        [36, "Czechia", "Türkiye"]
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
end
