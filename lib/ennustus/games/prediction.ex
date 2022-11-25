defmodule Ennustus.Games.Prediction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "predictions" do
    field :game_number, :integer
    field :home_team, :string
    field :away_team, :string
    field :home_goals, :integer
    field :away_goals, :integer
    field :player_id, :integer

    timestamps()
  end

  @doc false
  def changeset(prediction, attrs) do
    prediction
    |> cast(attrs, [:game_number, :home_team, :away_team, :home_goals, :away_goals, :player_id])
    |> validate_required([
      :game_number,
      :home_team,
      :away_team,
      :home_goals,
      :away_goals,
      :player_id
    ])
  end
end
