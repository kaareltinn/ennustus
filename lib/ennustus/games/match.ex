defmodule Ennustus.Games.Match do
  use Ecto.Schema
  import Ecto.Changeset

  schema "matches" do
    field :game_number, :integer
    field :home_team, :string
    field :away_team, :string
    field :home_goals, :integer
    field :away_goals, :integer

    field :status, Ecto.Enum,
      values: [:not_started, :in_progress, :finished],
      default: :not_started

    timestamps()
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:home_team, :away_team, :home_goals, :away_goals, :status])
  end
end
