defmodule Ennustus.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias Ennustus.Repo

  alias Ennustus.Games.Prediction
  alias Ennustus.Games.Player
  alias Ennustus.Games.Match
  alias Ennustus.Games.Question
  alias Ennustus.Games.AnswerKey
  alias Ennustus.Worldcup2026.QuestionsExporter

  # The 15 extra questions (imported by QuestionsExporter) are stored as
  # question_number 11–25; each correct answer is worth 10 points.
  @extra_question_numbers Enum.map(QuestionsExporter.questions(), fn {number, _title} -> number end)

  @games_order [
    1..72, # group stage
    73..88, # 1/16
    89..96, # 1/8
    97..100, # 1/4
    101..102, # 1/2
    [103], # third place
    [104] # final
  ] |> Enum.flat_map(&Enum.to_list/1)

  @order_index @games_order |> Enum.with_index() |> Map.new()

  # Display position of a game number within @games_order (DB-agnostic ordering).
  defp order_index(game_number), do: Map.get(@order_index, game_number, length(@games_order))

  @doc """
  Returns the list of predictions.

  ## Examples

      iex> list_predictions()
      [%Prediction{}, ...]

  """
  def list_predictions do
    Repo.all(Prediction)
  end

  def list_matches do
    Match
    |> Repo.all()
    |> Enum.sort_by(&order_index(&1.game_number))
  end

  defp list_matches_by_game_numbers(game_numbers) do
    from(
      m in Match,
      where: m.game_number in ^game_numbers,
      select: m
    )
    |> Repo.all()
  end

  def list_playoff_matches do
    49..64
    |> Enum.to_list()
    |> list_matches_by_game_numbers()
  end

  def list_playoff_matches(:eigth) do
    49..56
    |> Enum.to_list()
    |> list_matches_by_game_numbers()
  end

  def list_playoff_matches(:quarter) do
    57..60
    |> Enum.to_list()
    |> list_matches_by_game_numbers()
  end

  def list_playoff_matches(:semi) do
    61..62
    |> Enum.to_list()
    |> list_matches_by_game_numbers()
  end

  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns the team that won a finished match, or nil when the match is missing,
  unfinished, scoreless or a draw.
  """
  def actual_winner(game_number) do
    case Repo.get_by(Match, game_number: game_number) do
      %Match{status: :finished, home_goals: hg, away_goals: ag} = match
      when is_integer(hg) and is_integer(ag) ->
        cond do
          hg > ag -> match.home_team
          ag > hg -> match.away_team
          true -> nil
        end

      _ ->
        nil
    end
  end

  @champion_question 9
  @third_place_question 10

  @doc """
  Recomputes the champion (game 104) and third-place (game 103) bonus picks,
  marking each player's question correct when their answer matches the actual
  winner. Deciding matches that are not finished are left untouched.
  """
  def apply_winner_bonuses do
    mark_question_correctness(@champion_question, actual_winner(104))
    mark_question_correctness(@third_place_question, actual_winner(103))
  end

  defp mark_question_correctness(_question_number, nil), do: :noop

  defp mark_question_correctness(question_number, winning_team) do
    from(q in Question, where: q.question_number == ^question_number and q.answer == ^winning_team)
    |> Repo.update_all(set: [correct: true])

    from(q in Question, where: q.question_number == ^question_number and q.answer != ^winning_team)
    |> Repo.update_all(set: [correct: false])
  end

  @doc """
  Gets a single prediction.

  Raises `Ecto.NoResultsError` if the Prediction does not exist.

  ## Examples

      iex> get_prediction!(123)
      %Prediction{}

      iex> get_prediction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_prediction!(id), do: Repo.get!(Prediction, id)

  @doc """
  Creates a prediction.

  ## Examples

      iex> create_prediction(%{field: value})
      {:ok, %Prediction{}}

      iex> create_prediction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prediction(attrs \\ %{}) do
    %Prediction{}
    |> Prediction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a prediction.

  ## Examples

      iex> update_prediction(prediction, %{field: new_value})
      {:ok, %Prediction{}}

      iex> update_prediction(prediction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_prediction(%Prediction{} = prediction, attrs) do
    prediction
    |> Prediction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a prediction.

  ## Examples

      iex> delete_prediction(prediction)
      {:ok, %Prediction{}}

      iex> delete_prediction(prediction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_prediction(%Prediction{} = prediction) do
    Repo.delete(prediction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prediction changes.

  ## Examples

      iex> change_prediction(prediction)
      %Ecto.Changeset{data: %Prediction{}}

  """
  def change_prediction(%Prediction{} = prediction, attrs \\ %{}) do
    Prediction.changeset(prediction, attrs)
  end

  def predictions_by_player do
    query =
      from pl in Player,
        join: pre in Prediction,
        on: pl.id == pre.player_id,
        select: %{
          name: pl.name,
          game_number: pre.game_number,
          home_team: pre.home_team,
          home_goals: pre.home_goals,
          away_goals: pre.away_goals,
          away_team: pre.away_team,
          player_id: pre.player_id
        }

    Repo.all(query)
    |> Enum.group_by(fn pred -> {pred.player_id, pred.name} end)
    |> Map.new(fn {key, preds} -> {key, Enum.sort_by(preds, &order_index(&1.game_number))} end)
  end

  def question_scores do
    sub =
      from q in Question,
        where: q.correct == true and q.question_number in ^@extra_question_numbers,
        group_by: q.player_id,
        select: %{player_id: q.player_id, count: count(q.id)}

    Repo.all(
      from p in Player,
        join: c in subquery(sub),
        on: p.id == c.player_id,
        select: %{player_id: p.id, name: p.name, score: c.count * 10}
    )
    |> Enum.group_by(& &1.player_id)
  end

  def winner_predictions do
    query =
      from q in Question,
        where: q.question_number == 9

    Repo.all(query)
    |> Map.new(&{&1.player_id, &1})
  end

  def third_place_predictions do
    query =
      from q in Question,
        where: q.question_number == 10

    Repo.all(query)
    |> Map.new(&{&1.player_id, &1})
  end

  @doc """
  The 15 extra questions as `[%{number, title, answer}]`, where `answer` is the
  admin's stored canonical answer (nil when not yet set).
  """
  def extra_questions do
    keys =
      from(k in AnswerKey, select: {k.question_number, k.answer})
      |> Repo.all()
      |> Map.new()

    Enum.map(QuestionsExporter.questions(), fn {number, title} ->
      %{number: number, title: title, answer: Map.get(keys, number)}
    end)
  end

  @doc """
  All entrants' extra-question answers as
  `[%{player_id, name, score, answers}]`, ranked by `score` (10 points per
  correct answer) descending. `answers` maps each question_number (11–25) to
  `%{answer, correct}`.
  """
  def extra_answers_by_player do
    query =
      from q in Question,
        join: p in Player,
        on: p.id == q.player_id,
        where: q.question_number in ^@extra_question_numbers,
        select: %{
          player_id: p.id,
          name: p.name,
          question_number: q.question_number,
          answer: q.answer,
          correct: q.correct
        }

    Repo.all(query)
    |> Enum.group_by(& &1.player_id)
    |> Enum.map(fn {player_id, rows} ->
      answers = Map.new(rows, &{&1.question_number, %{answer: &1.answer, correct: &1.correct}})
      score = rows |> Enum.count(& &1.correct) |> Kernel.*(10)
      %{player_id: player_id, name: hd(rows).name, score: score, answers: answers}
    end)
    |> Enum.sort_by(& &1.score, :desc)
  end

  @doc """
  Stores the canonical correct `answer` for an extra question and re-marks every
  player's answer: `correct` when it matches `answer` ignoring case and
  surrounding whitespace, otherwise `false`. A blank answer clears all markings.
  """
  def set_extra_answer(question_number, answer) do
    upsert_answer_key(question_number, answer)
    mark_extra_correctness(question_number, answer)
  end

  defp upsert_answer_key(question_number, answer) do
    %AnswerKey{}
    |> AnswerKey.changeset(%{question_number: question_number, answer: answer})
    |> Repo.insert(
      on_conflict: {:replace, [:answer, :updated_at]},
      conflict_target: :question_number
    )
  end

  # Matching is done in Elixir, not SQL: SQLite's built-in lower() is ASCII-only
  # and would not case-fold the non-ASCII characters (Š, Ž, Õ, ...) common in the
  # Estonian answers.
  defp mark_extra_correctness(question_number, answer) do
    normalized = normalize_answer(answer)

    {correct, incorrect} =
      from(q in Question, where: q.question_number == ^question_number)
      |> Repo.all()
      |> Enum.split_with(fn q -> normalized != "" and normalize_answer(q.answer) == normalized end)

    set_correctness(Enum.map(correct, & &1.id), true)
    set_correctness(Enum.map(incorrect, & &1.id), false)
  end

  defp set_correctness([], _correct), do: :noop

  defp set_correctness(ids, correct) do
    from(q in Question, where: q.id in ^ids)
    |> Repo.update_all(set: [correct: correct])
  end

  defp normalize_answer(answer), do: answer |> to_string() |> String.trim() |> String.downcase()
end
