defmodule EnnustusWeb.Games.PredictionsLive do
  use EnnustusWeb, :live_view

  def mount(_params, _session, socket) do
    matches = Ennustus.Games.list_matches()
    predictions = Ennustus.Games.predictions_by_player()
    scored_predictions = Ennustus.Games.Scorer.score(matches, predictions)

    socket =
      socket
      |> assign(:predictions, scored_predictions)
      |> assign(:matches, matches)

    {:ok, socket}
  end
end
