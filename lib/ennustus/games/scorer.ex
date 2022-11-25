defmodule Ennustus.Games.Scorer do
  def total_score(predictions) do
    Enum.reduce(predictions, 0, fn %{score: score}, acc -> acc + score end)
  end

  def score(matches, predictions) do
    matches_by_game_number =
      matches
      |> Enum.group_by(fn %{game_number: game_number} -> game_number end)

    Enum.reduce(predictions, [], fn {player, predictions}, acc ->
      scored_predictions =
        Enum.map(predictions, fn prediction ->
          [match] = matches_by_game_number[prediction.game_number]

          Map.merge(
            prediction,
            %{
              score: score_prediction(prediction, match)
            }
          )
        end)

      [[player, total_score(scored_predictions), scored_predictions] | acc]
    end)
    |> Enum.sort_by(fn [_, total, _] -> total end, :desc)
  end

  def score_prediction(_, %{status: :not_started}) do
    0
  end

  def score_prediction(prediction, match) do
    case {result(prediction), result(match)} do
      {:home_win, :home_win} -> compute_score(prediction, match)
      {:away_win, :away_win} -> compute_score(prediction, match)
      {:draw, :draw} -> compute_score(prediction, match)
      _ -> 0
    end
  end

  defp result(%{home_goals: home_goals, away_goals: away_goals}) do
    cond do
      home_goals > away_goals -> :home_win
      home_goals < away_goals -> :away_win
      home_goals == away_goals -> :draw
    end
  end

  defp compute_score(prediction, match) do
    10 - abs(prediction.home_goals - match.home_goals) -
      abs(prediction.away_goals - match.away_goals)
  end
end
