defmodule Ennustus.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :answer, :string
      add :correct, :boolean, default: false, null: false
      add :question_number, :integer, null: false
      add :player_id, references(:players, on_delete: :nothing)

      timestamps()
    end

    create index(:questions, [:player_id])
    create unique_index(:questions, [:player_id, :question_number])
  end
end
