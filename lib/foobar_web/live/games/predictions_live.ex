defmodule FoobarWeb.Games.PredictionsLive do
  use FoobarWeb, :live_view

  def mount(_params, _session, socket) do
    matches = Foobar.Games.list_matches()
    predictions = Foobar.Games.predictions_by_player()
    scored_predictions = Foobar.Games.Scorer.score(matches, predictions)

    socket =
      socket
      |> assign(:predictions, scored_predictions)
      |> assign(:matches, matches)

    {:ok, socket}
  end
end
