defmodule Ennustus.Worldcup2026.ExportersTest do
  use Ennustus.DataCase

  alias Ennustus.Games.Player
  alias Ennustus.Games.Prediction
  alias Ennustus.Games.Question
  alias Ennustus.Repo

  alias Ennustus.Worldcup2026.GroupStageExporter
  alias Ennustus.Worldcup2026.MatchesExporter
  alias Ennustus.Worldcup2026.PlayoffStageExporter
  alias Ennustus.Worldcup2026.WinnerExporter

  @sample_file Path.join(File.cwd!(), "priv/data/worldcup2026/kaarel_tinn.xlsx")

  defp predictions(player_id, game_numbers) do
    Repo.all(from p in Prediction, where: p.player_id == ^player_id, select: p)
    |> Enum.filter(&(&1.game_number in game_numbers))
    |> Map.new(&{&1.game_number, &1})
  end

  describe "MatchesExporter" do
    test "seeds 72 group fixtures with real teams" do
      MatchesExporter.export(:group_stage)
      matches = Repo.all(Ennustus.Games.Match)
      assert length(matches) == 72
      numbers = matches |> Enum.map(& &1.game_number) |> Enum.sort()
      assert numbers == Enum.to_list(1..72)
      first = Enum.find(matches, &(&1.game_number == 1))
      assert {first.home_team, first.away_team} == {"Mexico", "South Africa"}
    end

    test "seeds 32 knockout placeholders" do
      MatchesExporter.export(:playoffs)
      matches = Repo.all(Ennustus.Games.Match)
      numbers = matches |> Enum.map(& &1.game_number) |> Enum.sort()
      assert numbers == Enum.to_list(73..104)
      assert Enum.all?(matches, &is_nil(&1.home_team))
    end
  end

  describe "prediction exporters against the example file" do
    setup do
      GroupStageExporter.process(@sample_file)
      player = Repo.get_by!(Player, name: "kaarel_tinn")
      {:ok, player: player}
    end

    test "group stage imports 72 predictions with teams and goals", %{player: player} do
      preds = predictions(player.id, 1..72)
      assert map_size(preds) == 72

      g1 = preds[1]
      assert {g1.home_team, g1.home_goals, g1.away_goals, g1.away_team} ==
               {"Mexico", 1, 1, "South Africa"}
    end

    test "playoff stage imports 32 knockout team picks", %{player: player} do
      PlayoffStageExporter.process(@sample_file)
      preds = predictions(player.id, 73..104)
      assert map_size(preds) == 32

      assert {preds[74].home_team, preds[74].away_team} == {"Germany", "Australia"}
      assert {preds[104].home_team, preds[104].away_team} == {"France", "Portugal"}
      assert {preds[103].home_team, preds[103].away_team} == {"Spain", "England"}
    end

    test "winner exporter imports champion and third-place winner picks", %{player: player} do
      WinnerExporter.process(@sample_file)

      champion = Repo.get_by(Question, player_id: player.id, question_number: 9)
      third = Repo.get_by(Question, player_id: player.id, question_number: 10)

      assert champion.answer == "Portugal"
      assert third.answer == "Spain"
    end
  end
end
