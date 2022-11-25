defmodule Foobar.Repo.Migrations.CreatePredictions do
  use Ecto.Migration

  def change do
    create table(:predictions) do
      add :game_number, :integer, null: false
      add :home_team, :string
      add :away_team, :string
      add :home_goals, :integer
      add :away_goals, :integer
      add :user_id, references(:users)

      timestamps()
    end
  end
end
