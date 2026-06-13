defmodule EnnustusWeb.Games.QuestionsLiveTest do
  use EnnustusWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Ennustus.Games
  alias Ennustus.Games.Player
  alias Ennustus.Games.Question
  alias Ennustus.Repo

  test "GET /questions lists entrants, answers and extra-question score", %{conn: conn} do
    {:ok, player} = Repo.insert(Player.changeset(%Player{}, %{name: "Alice Example"}))

    Repo.insert!(%Question{player_id: player.id, question_number: 11, answer: "Argentiina", correct: false})
    Repo.insert!(%Question{player_id: player.id, question_number: 12, answer: "Holland", correct: false})
    Games.set_extra_answer(11, "Argentiina")

    {:ok, _view, html} = live(conn, ~p"/questions")

    assert html =~ "EXTRA QUESTIONS"
    assert html =~ "Kaardid"
    assert html =~ "Alice Example"
    assert html =~ "Argentiina"
    # 10 points for the one correct answer.
    assert html =~ ">10</span>"
  end
end
