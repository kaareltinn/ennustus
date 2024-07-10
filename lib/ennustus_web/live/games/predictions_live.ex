defmodule EnnustusWeb.Games.PredictionsLive do
  use EnnustusWeb, :live_view

  import Ennustus.Countries

  def mount(_params, _session, socket) do
    matches = Ennustus.Games.list_matches()
    predictions = Ennustus.Games.predictions_by_player()
    questions = Ennustus.Games.question_scores()
    winner_predictions = Ennustus.Games.winner_predictions()

    scored_predictions =
      Ennustus.Games.Scorer.score(matches, predictions, questions, winner_predictions)

    socket =
      socket
      |> assign(:predictions, scored_predictions)
      |> assign(:winner_predictions, winner_predictions)
      |> assign(:matches, matches)

    {:ok, socket}
  end
end
