defmodule Ennustus.Games.ScorerTest do
  use ExUnit.Case, async: true

  alias Ennustus.Games.Scorer

  describe "score_prediction/2 (group stage)" do
    test "not started match scores 0" do
      prediction = %{home_goals: 2, away_goals: 1}
      match = %{status: :not_started, home_goals: 0, away_goals: 0}
      assert Scorer.score_prediction(prediction, match) == 0
    end

    test "exact score scores 12" do
      prediction = %{home_goals: 2, away_goals: 1}
      match = %{status: :finished, home_goals: 2, away_goals: 1}
      assert Scorer.score_prediction(prediction, match) == 12
    end

    test "correct outcome but off goals scores 10 minus goal diffs" do
      prediction = %{home_goals: 3, away_goals: 1}
      match = %{status: :finished, home_goals: 2, away_goals: 1}
      assert Scorer.score_prediction(prediction, match) == 9
    end

    test "wrong outcome scores negative goal diff" do
      prediction = %{home_goals: 2, away_goals: 1}
      match = %{status: :finished, home_goals: 1, away_goals: 2}
      assert Scorer.score_prediction(prediction, match) == -2
    end
  end

  describe "score_playoff_prediction/3 (WC2026 stages)" do
    # game_number -> stage coefficient mapping for World Cup 2026
    # round_of_32 73..88 = 10, round_of_16 89..96 = 12, quarter 97..100 = 15,
    # semi 101..102 = 18, third 103 = 22, final 104 = 20
    @cases [
      {80, :round_of_32, 10},
      {90, :round_of_16, 12},
      {98, :quarter, 15},
      {101, :semi, 18},
      {103, :third, 22},
      {104, :final, 20}
    ]

    for {game_number, stage, coef} <- @cases do
      test "game #{game_number} (#{stage}): one correct team scores #{coef}" do
        prediction = %{home_team: "Brazil", away_team: "Nowhere"}
        matches_by_stage = %{unquote(stage) => [%{home_team: "Brazil", away_team: "Spain"}]}

        assert Scorer.score_playoff_prediction(prediction, unquote(game_number), matches_by_stage) ==
                 unquote(coef)
      end

      test "game #{game_number} (#{stage}): two correct teams scores #{2 * coef}" do
        prediction = %{home_team: "Brazil", away_team: "Spain"}
        matches_by_stage = %{unquote(stage) => [%{home_team: "Brazil", away_team: "Spain"}]}

        assert Scorer.score_playoff_prediction(prediction, unquote(game_number), matches_by_stage) ==
                 unquote(2 * coef)
      end
    end

    test "no correct teams scores 0" do
      prediction = %{home_team: "Wrong", away_team: "AlsoWrong"}
      matches_by_stage = %{round_of_32: [%{home_team: "Brazil", away_team: "Spain"}]}
      assert Scorer.score_playoff_prediction(prediction, 80, matches_by_stage) == 0
    end
  end

  describe "score_winner/2 (champion bonus)" do
    test "correct champion pick scores 30" do
      assert Scorer.score_winner(1, %{1 => %{correct: true}}) == 30
    end

    test "incorrect champion pick scores 0" do
      assert Scorer.score_winner(1, %{1 => %{correct: false}}) == 0
    end

    test "missing champion pick scores 0" do
      assert Scorer.score_winner(1, %{}) == 0
    end
  end

  describe "score_third_place/2 (third place winner bonus)" do
    test "correct third place winner pick scores 25" do
      assert Scorer.score_third_place(1, %{1 => %{correct: true}}) == 25
    end

    test "incorrect third place winner pick scores 0" do
      assert Scorer.score_third_place(1, %{1 => %{correct: false}}) == 0
    end

    test "missing third place winner pick scores 0" do
      assert Scorer.score_third_place(1, %{}) == 0
    end
  end
end

defmodule Ennustus.Games.ScorerOverrideTest do
  use ExUnit.Case, async: true

  alias Ennustus.Games.Scorer

  # Standings rows have the shape [{player_id, name}, total, scored_predictions].
  defp row(id, name, total), do: [{id, name}, total, []]

  describe "apply_overrides/2" do
    test "disabled leaves standings untouched" do
      standings = [row(1, "Alice", 40), row(2, "Remi Kõivik", 30)]
      assert Scorer.apply_overrides(standings, false) == standings
    end

    test "enabled forces Remi Kõivik's total to -67 and re-sorts" do
      standings = [row(1, "Alice", 40), row(2, "Remi Kõivik", 30), row(3, "Bob", 10)]

      result = Scorer.apply_overrides(standings, true)

      assert [[{1, "Alice"}, 40, _], [{3, "Bob"}, 10, _], [{2, "Remi Kõivik"}, -67, _]] = result
    end

    test "enabled but no Remi Kõivik present is a no-op" do
      standings = [row(1, "Alice", 40), row(3, "Bob", 10)]
      assert Scorer.apply_overrides(standings, true) == standings
    end
  end
end
