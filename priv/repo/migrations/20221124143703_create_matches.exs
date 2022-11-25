defmodule Foobar.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :game_number, :integer, null: false
      add :home_team, :string
      add :away_team, :string
      add :home_goals, :integer
      add :away_goals, :integer
      add :status, :string, null: false

      timestamps()
    end

    create unique_index(:matches, :game_number)
  end
end
