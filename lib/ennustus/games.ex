defmodule Ennustus.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias Ennustus.Repo

  alias Ennustus.Games.Prediction
  alias Ennustus.Games.Player
  alias Ennustus.Games.Match

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
    query =
      from m in Match,
        order_by: m.game_number

    Repo.all(query)
  end

  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
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
    query = from pl in Player, join: pre in Prediction, on: pl.id == pre.player_id

    query =
      from [pl, pre] in query,
        order_by: pre.game_number,
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
    |> Enum.group_by(fn pred -> pred.name end)
  end
end
