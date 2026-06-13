defmodule EnnustusWeb.Games.PredictionsLive do
  use EnnustusWeb, :live_view

  import Ennustus.Countries

  def mount(_params, _session, socket) do
    matches = Ennustus.Games.list_matches()
    predictions = Ennustus.Games.predictions_by_player()
    questions = Ennustus.Games.question_scores()
    winner_predictions = Ennustus.Games.winner_predictions()
    third_place_predictions = Ennustus.Games.third_place_predictions()

    scored_predictions =
      Ennustus.Games.Scorer.score(
        matches,
        predictions,
        questions,
        winner_predictions,
        third_place_predictions
      )

    matches_index = Map.new(matches, &{&1.game_number, &1})

    socket =
      socket
      |> assign(:predictions, scored_predictions)
      |> assign(:winner_predictions, winner_predictions)
      |> assign(:matches, matches)
      |> assign(:matches_index, matches_index)
      |> assign(:selected_player, nil)

    {:ok, socket}
  end

  def handle_event("select_player", %{"id" => player_id_str}, socket) do
    player_id = String.to_integer(player_id_str)
    selected = Enum.find(socket.assigns.predictions, fn [{pid, _}, _, _] -> pid == player_id end)
    {:noreply, assign(socket, :selected_player, selected)}
  end

  def handle_event("close_player", _params, socket) do
    {:noreply, assign(socket, :selected_player, nil)}
  end

  @doc "Tone class for a points value."
  def score_class(score) when score > 0, do: "score-pos"
  def score_class(score) when score < 0, do: "score-neg"
  def score_class(_), do: "score-zero"

  @doc "Podium colour for a rank number (0-indexed)."
  def rank_class(0), do: "rank-1"
  def rank_class(1), do: "rank-2"
  def rank_class(2), do: "rank-3"
  def rank_class(_), do: "text-[var(--ink-faint)]"

  @doc "Podium accent for the standings rail (0-indexed)."
  def rail_class(0), do: "rail-1"
  def rail_class(1), do: "rail-2"
  def rail_class(2), do: "rail-3"
  def rail_class(_), do: ""
end
