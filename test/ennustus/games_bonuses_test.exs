defmodule Ennustus.GamesBonusesTest do
  use Ennustus.DataCase

  alias Ennustus.Games
  alias Ennustus.Games.{Match, Player, Question}
  alias Ennustus.Repo

  defp match(attrs) do
    Repo.insert!(struct(Match, Map.merge(%{status: :not_started}, Map.new(attrs))))
  end

  defp question(attrs) do
    {:ok, player} = Repo.insert(Player.changeset(%Player{}, %{name: "p#{System.unique_integer([:positive])}"}))

    Repo.insert!(
      struct(Question, Map.merge(%{player_id: player.id, correct: false}, Map.new(attrs)))
    )
  end

  describe "actual_winner/1" do
    test "returns home team when home wins a finished match" do
      match(game_number: 104, home_team: "France", away_team: "Spain", home_goals: 2, away_goals: 1, status: :finished)
      assert Games.actual_winner(104) == "France"
    end

    test "returns away team when away wins" do
      match(game_number: 104, home_team: "France", away_team: "Spain", home_goals: 0, away_goals: 1, status: :finished)
      assert Games.actual_winner(104) == "Spain"
    end

    test "returns nil for a draw" do
      match(game_number: 104, home_team: "France", away_team: "Spain", home_goals: 1, away_goals: 1, status: :finished)
      assert Games.actual_winner(104) == nil
    end

    test "returns nil when match not finished" do
      match(game_number: 104, home_team: "France", away_team: "Spain", home_goals: 2, away_goals: 1, status: :in_progress)
      assert Games.actual_winner(104) == nil
    end

    test "returns nil when match is missing" do
      assert Games.actual_winner(104) == nil
    end
  end

  describe "apply_winner_bonuses/0" do
    test "marks champion (q9) and third-place (q10) picks correct against actual results" do
      match(game_number: 104, home_team: "France", away_team: "Portugal", home_goals: 1, away_goals: 2, status: :finished)
      match(game_number: 103, home_team: "Spain", away_team: "England", home_goals: 2, away_goals: 1, status: :finished)

      right_champion = question(question_number: 9, answer: "Portugal")
      wrong_champion = question(question_number: 9, answer: "France")
      right_third = question(question_number: 10, answer: "Spain")
      wrong_third = question(question_number: 10, answer: "England")

      Games.apply_winner_bonuses()

      assert Repo.reload!(right_champion).correct == true
      assert Repo.reload!(wrong_champion).correct == false
      assert Repo.reload!(right_third).correct == true
      assert Repo.reload!(wrong_third).correct == false
    end

    test "leaves picks untouched when the deciding match is not finished" do
      match(game_number: 104, home_team: "France", away_team: "Portugal", status: :not_started)
      champion = question(question_number: 9, answer: "Portugal")

      Games.apply_winner_bonuses()

      assert Repo.reload!(champion).correct == false
    end
  end
end
