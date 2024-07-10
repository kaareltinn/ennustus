defmodule Ennustus.Games.Scorer do
  def total_score(predictions) do
    Enum.reduce(predictions, 0, fn %{score: score}, acc -> acc + score end)
  end

  def score(matches, predictions, questions, winner_predictions) do
    matches_by_game_number =
      matches
      |> Enum.group_by(fn %{game_number: game_number} -> game_number end)

    matches_by_stage =
      matches
      |> Enum.group_by(fn %{game_number: game_number} -> get_playoff_stage(game_number) end)

    Enum.reduce(predictions, [], fn {{player_id, name}, predictions}, acc ->
      scored_predictions =
        Enum.map(predictions, fn prediction ->
          [match] = matches_by_game_number[prediction.game_number]

          if prediction.game_number < 37 do
            Map.merge(
              prediction,
              %{
                score: score_prediction(prediction, match)
              }
            )
          else
            Map.merge(
              prediction,
              %{
                score: score_playoff_prediction(prediction, match.game_number, matches_by_stage)
              }
            )
          end
        end)

      questions_score = Map.get(questions, player_id, [%{score: 0}]) |> List.first()
      winner_score = score_winner(player_id, winner_predictions)
      total = total_score(scored_predictions) + questions_score.score + winner_score

      [[{player_id, name}, total, scored_predictions] | acc]
    end)
    |> Enum.sort_by(fn [_, total, _] -> total end, :desc)
  end

  def score_prediction(_, %{status: :not_started}) do
    0
  end

  def score_prediction(prediction, match) do
    case {result(prediction), result(match)} do
      {:home_win, :home_win} ->
        compute_score(prediction, match)

      {:away_win, :away_win} ->
        compute_score(prediction, match)

      {:draw, :draw} ->
        compute_score(prediction, match)

      _ ->
        -abs(prediction.home_goals - match.home_goals) -
          abs(prediction.away_goals - match.away_goals)
    end
  end

  def score_playoff_prediction(prediction, game_number, matches_by_stage) do
    stage = get_playoff_stage(game_number)
    matches = matches_by_stage[stage]

    teams =
      matches
      |> Enum.flat_map(fn %{home_team: home_team, away_team: away_team} ->
        [home_team, away_team]
      end)

    correct =
      MapSet.intersection(
        MapSet.new([prediction.home_team, prediction.away_team]),
        MapSet.new(teams)
      )

    count = Enum.count(correct)
    count * get_playoff_stage_coef(stage)
  end

  def score_winner(player_id, winner_predictions) do
    prediction = winner_predictions[player_id]

    case prediction do
      %{correct: true} -> 30
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
    home_goals_diff = abs(prediction.home_goals - match.home_goals)
    away_goals_diff = abs(prediction.away_goals - match.away_goals)

    case {home_goals_diff, away_goals_diff} do
      {0, 0} -> 12
      {_, _} -> 10 - home_goals_diff - away_goals_diff
    end
  end

  defp get_playoff_stage(game_number) when game_number in 1..36, do: :group
  defp get_playoff_stage(game_number) when game_number in 37..44, do: :eigth
  defp get_playoff_stage(game_number) when game_number in 45..48, do: :quarter
  defp get_playoff_stage(game_number) when game_number in 49..50, do: :semi
  # defp get_playoff_stage(63), do: :third
  defp get_playoff_stage(51), do: :final

  defp get_playoff_stage_coef(stage) do
    case stage do
      :eigth -> 10
      :quarter -> 12
      :semi -> 15
      :final -> 18
    end
  end
end
