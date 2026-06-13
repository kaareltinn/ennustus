defmodule EnnustusWeb.Games.QuestionsLive do
  use EnnustusWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:questions, Ennustus.Games.extra_questions())
      |> assign(:entrants, Ennustus.Games.extra_answers_by_player())

    {:ok, socket}
  end

  @doc """
  Cell background for a player's answer. Untinted when the answer is missing or
  the question's correct answer is unknown; otherwise green when correct, red
  when incorrect.
  """
  def cell_class(nil, _answer_known), do: ""
  def cell_class(_cell, false), do: ""
  def cell_class(%{correct: true}, true), do: "cell-correct"
  def cell_class(%{correct: false}, true), do: "cell-wrong"

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
