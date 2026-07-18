defmodule EnnustusWeb.Games.PredictionsLiveTest do
  use EnnustusWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Ennustus.Games.Match
  alias Ennustus.Games.Player
  alias Ennustus.Games.Prediction
  alias Ennustus.Games.Question
  alias Ennustus.Repo

  test "third-place column shows the predicted third-place winner, not the game 103 teams", %{
    conn: conn
  } do
    {:ok, player} = Repo.insert(Player.changeset(%Player{}, %{name: "Alice Example"}))

    Repo.insert!(%Match{game_number: 103, status: :not_started})

    Repo.insert!(%Prediction{
      player_id: player.id,
      game_number: 103,
      home_team: "France",
      away_team: "Germany"
    })

    Repo.insert!(%Question{player_id: player.id, question_number: 10, answer: "Brazil"})

    {:ok, _view, html} = live(conn, ~p"/")

    # The cell shows the third-place pick...
    assert html =~ "fi-br"
    # ...instead of the two teams predicted to reach game 103.
    refute html =~ "fi-fr"
    refute html =~ "fi-de"
  end

  test "third-place column shows the 25-point bonus when the pick is correct", %{conn: conn} do
    {:ok, player} = Repo.insert(Player.changeset(%Player{}, %{name: "Alice Example"}))

    Repo.insert!(%Match{game_number: 103, status: :not_started})

    Repo.insert!(%Prediction{
      player_id: player.id,
      game_number: 103,
      home_team: "France",
      away_team: "Germany"
    })

    Repo.insert!(%Question{
      player_id: player.id,
      question_number: 10,
      answer: "Brazil",
      correct: true
    })

    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ ~r/score-pos[^>]*>\s*25\s*</
  end

  test "winner pick shows its bonus score behind the prediction", %{conn: conn} do
    {:ok, player} = Repo.insert(Player.changeset(%Player{}, %{name: "Alice Example"}))

    Repo.insert!(%Match{game_number: 103, status: :not_started})

    Repo.insert!(%Prediction{
      player_id: player.id,
      game_number: 103,
      home_team: "France",
      away_team: "Germany"
    })

    Repo.insert!(%Question{
      player_id: player.id,
      question_number: 9,
      answer: "Spain",
      correct: true
    })

    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ "fi-es"
    assert html =~ ~r/score-pos[^>]*>\s*30\s*</
  end
end
