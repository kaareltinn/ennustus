defmodule EnnustusWeb.Admin.MatchesLive do
  use EnnustusWeb, :live_view

  import Ennustus.Countries

  alias Ennustus.Games

  @statuses [:not_started, :in_progress, :finished]

  def mount(_params, _session, socket) do
    {:ok, assign_data(socket)}
  end

  def handle_event("save_match", %{"match_id" => id} = params, socket) do
    match = Enum.find(socket.assigns.matches, &(to_string(&1.id) == id))

    case Games.update_match(match, params) do
      {:ok, _match} ->
        {:noreply,
         socket
         |> put_flash(:info, "Saved game ##{match.game_number}")
         |> assign_data()}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not save game ##{match.game_number}")}
    end
  end

  def handle_event("apply_bonuses", _params, socket) do
    Games.apply_winner_bonuses()

    {:noreply,
     socket
     |> put_flash(:info, "Winner bonuses applied from games 103 and 104")
     |> assign_data()}
  end

  def status_label(:not_started), do: "Not started"
  def status_label(:in_progress), do: "In progress"
  def status_label(:finished), do: "Finished"

  defp assign_data(socket) do
    matches = Games.list_matches() |> Enum.sort_by(& &1.game_number)

    grouped =
      matches
      |> Enum.chunk_by(&stage(&1.game_number))
      |> Enum.map(fn games -> {stage(hd(games).game_number), games} end)

    socket
    |> assign(:matches, matches)
    |> assign(:grouped, grouped)
    |> assign(:statuses, @statuses)
    |> assign(:teams, world_cup_2026_teams())
    |> assign(:champion, Games.actual_winner(104))
    |> assign(:third_place, Games.actual_winner(103))
  end
end
