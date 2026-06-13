defmodule EnnustusWeb.Admin.MatchesLiveTest do
  use EnnustusWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Ennustus.Games
  alias Ennustus.Games.Match
  alias Ennustus.Repo

  defp basic_auth(conn) do
    creds = Application.fetch_env!(:ennustus, :admin_auth)
    Plug.Conn.put_req_header(conn, "authorization", Plug.BasicAuth.encode_basic_auth(creds[:username], creds[:password]))
  end

  test "GET /admin without credentials is unauthorized", %{conn: conn} do
    conn = get(conn, ~p"/admin")
    assert conn.status == 401
  end

  test "GET /admin with credentials renders the admin page", %{conn: conn} do
    Repo.insert!(%Match{game_number: 1, home_team: "Mexico", away_team: "South Africa", status: :not_started})

    {:ok, _view, html} =
      conn
      |> basic_auth()
      |> live(~p"/admin")

    assert html =~ "MATCH RESULTS"
    assert html =~ "Mexico"
  end

  test "saving a match updates its result", %{conn: conn} do
    match =
      Repo.insert!(%Match{game_number: 1, home_team: "Mexico", away_team: "South Africa", status: :not_started})

    {:ok, view, _html} = conn |> basic_auth() |> live(~p"/admin")

    view
    |> form(~s(form[phx-submit="save_match"]), %{
      "match_id" => match.id,
      "home_team" => "Mexico",
      "away_team" => "South Africa",
      "home_goals" => "3",
      "away_goals" => "1",
      "status" => "finished"
    })
    |> render_submit()

    updated = Repo.get!(Match, match.id)
    assert updated.home_goals == 3
    assert updated.away_goals == 1
    assert updated.status == :finished
  end

  test "saving an extra answer marks matching player answers correct", %{conn: conn} do
    {:ok, player} =
      Repo.insert(Ennustus.Games.Player.changeset(%Ennustus.Games.Player{}, %{name: "p1"}))

    q =
      Repo.insert!(%Ennustus.Games.Question{
        player_id: player.id,
        question_number: 11,
        answer: "Argentiina",
        correct: false
      })

    {:ok, view, _html} = conn |> basic_auth() |> live(~p"/admin")

    view
    |> form("#extra-q-11", %{"question_number" => "11", "answer" => "argentiina"})
    |> render_submit()

    assert Repo.reload!(q).correct == true
  end

  test "apply winner bonuses marks matching champion pick correct", %{conn: conn} do
    Repo.insert!(%Match{
      game_number: 104,
      home_team: "France",
      away_team: "Portugal",
      home_goals: 1,
      away_goals: 2,
      status: :finished
    })

    {:ok, player} =
      Repo.insert(Ennustus.Games.Player.changeset(%Ennustus.Games.Player{}, %{name: "p1"}))

    q =
      Repo.insert!(%Ennustus.Games.Question{
        player_id: player.id,
        question_number: 9,
        answer: "Portugal",
        correct: false
      })

    {:ok, view, _html} = conn |> basic_auth() |> live(~p"/admin")

    view |> element("button", "Apply winner bonuses") |> render_click()

    assert Repo.reload!(q).correct == true
    assert Games.actual_winner(104) == "Portugal"
  end
end
